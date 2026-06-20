#!/usr/bin/env python3
"""Escaneo de salud de la flota SABIO — versión portable (Windows · macOS · Linux).

Recorre tu **Centro de Mando Sabio** y/o una carpeta de **proyectos**, y produce:
  - `estado-flota.json`          (datos crudos)
  - `panel/datos/estado-flota.js` + `panel/datos/historial.js`  (los lee el panel offline)
  - `historial-flota.jsonl`      (snapshots datados para los sparklines de tendencia)

Solo LEE metadatos de salud/configuración (git, tamaño de CLAUDE.md, grafo del vault, MCP
declarados, último backup). NUNCA lee el contenido de las bóvedas ni mezcla conocimiento entre
proyectos (respeta el aislamiento de Capa 1). Es idempotente: re-ejecutarlo solo regenera la salida.

Uso (rutas configurables — sin valores horneados):
  python escanear-flota.py --centro "/ruta/a/Centro de Mando Sabio" --proyectos "/ruta/a/Proyectos"
  python escanear-flota.py --proyectos "/ruta/a/Proyectos" --abrir
  python escanear-flota.py --centro "C:\\Centro de Mando Sabio"

Equivalente multiplataforma de `Escanear-Flota.ps1` (mismo `estado-flota.json`).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import webbrowser
from datetime import datetime, timezone
from pathlib import Path

AQUI = Path(__file__).resolve().parent

UMBRAL_CORPUS = 40                       # subcarpeta de una Sala con >= N .md = corpus importado
AUTORIA = {"fichas", "registros"}        # subcarpetas de autoría: nunca cuentan como corpus
SALAS_FED = ("04-Recursos/02-Catalogo", "04-Recursos/03-Referencia", "04-Recursos/04-Aprendizaje")
PRUNE = {"node_modules", ".git", ".obsidian", ".understand-anything", "03-Backups",
         "01-Vault Obsidian", ".next", "dist", "build", ".venv", "venv", "out",
         "coverage", "__pycache__", ".vercel", ".svelte-kit"}
RX_WIKILINK = re.compile(r"\[\[([^\]]+)\]\]")
RX_ENV = re.compile(r"(^|/)\.env(\.(local|production|prod|staging|secret))?$", re.IGNORECASE)
RX_KEY = re.compile(
    r"(^|/)([^/]*\.(pem|key|pfx|p12)|id_rsa|id_dsa|credentials\.json"
    r"|service[-_]?account[^/]*\.json|secrets?\.(json|ya?ml|env))$", re.IGNORECASE)


# --------------------------------------------------------------------------- git
def run_git(ruta: Path, args: list[str]) -> str | None:
    try:
        r = subprocess.run(["git", "-C", str(ruta), *args],
                           capture_output=True, text=True, encoding="utf-8", errors="replace")
        if r.returncode != 0:
            return None
        return r.stdout.strip("\n")
    except (OSError, ValueError):
        return None


def git_info(ruta: Path) -> dict:
    if not (ruta / ".git").exists():
        return {"esRepo": False}
    remoto = run_git(ruta, ["remote", "get-url", "origin"])
    rama = run_git(ruta, ["rev-parse", "--abbrev-ref", "HEAD"])
    commits = run_git(ruta, ["rev-list", "--count", "HEAD"])
    status = run_git(ruta, ["status", "--porcelain"])
    sucios = len([l for l in status.split("\n") if l.strip()]) if status else 0
    ahead = run_git(ruta, ["rev-list", "--count", "@{u}..HEAD"])
    last = run_git(ruta, ["log", "-1", "--format=%H%x1f%an%x1f%cI%x1f%s"])
    ultimo = None
    if last:
        p = last.split("\x1f")
        ultimo = {
            "hash": p[0][:8] if len(p) >= 1 else None,
            "autor": p[1] if len(p) >= 2 else None,
            "fecha": p[2] if len(p) >= 3 else None,
            "mensaje": p[3] if len(p) >= 4 else None,
        }
    return {
        "esRepo": True,
        "tieneRemoto": bool(remoto),
        "remoto": remoto,
        "rama": rama,
        "commits": int(commits) if commits else 0,
        "sucio": sucios > 0,
        "archivosSucios": sucios,
        "sinPush": int(ahead) if (ahead is not None and ahead.strip() != "") else None,
        "ultimoCommit": ultimo,
    }


# --------------------------------------------------------------------- seguridad
def seguridad(ruta: Path) -> dict:
    if not (ruta / ".git").exists():
        return {"tieneGitignore": False, "secretos": []}
    tiene_gitignore = (ruta / ".gitignore").exists()
    tracked = run_git(ruta, ["ls-files"])
    secretos = []
    if tracked:
        for f in tracked.split("\n"):
            ff = f.strip()
            if not ff:
                continue
            low = ff.lower()
            if RX_ENV.search(low) or RX_KEY.search(low):
                secretos.append(ff)
    return {"tieneGitignore": bool(tiene_gitignore), "secretos": secretos}


# ------------------------------------------------------------------------- vault
def _iter_md(base: Path):
    for p in base.rglob("*.md"):
        parts = set(p.parts)
        if parts & {"node_modules", ".git", ".obsidian"}:
            continue
        yield p


def vault_info(ruta: Path) -> dict:
    federado = 0
    federado_corpus = 0
    for sala in SALAS_FED:
        sp = ruta / sala
        if not sp.exists():
            continue
        md = list(_iter_md(sp))
        federado += len(md)
        grupos: dict[str, int] = {}
        for f in md:
            rel = f.relative_to(sp).parts
            grupo = rel[0] if len(rel) > 1 else ""
            grupos[grupo] = grupos.get(grupo, 0) + 1
        for nombre, cuenta in grupos.items():
            if nombre and cuenta >= UMBRAL_CORPUS and nombre not in AUTORIA:
                federado_corpus += cuenta

    # raíces de vault Obsidian: padre de cada .obsidian (excluyendo backups / node_modules)
    vault_roots = []
    for ob in ruta.rglob(".obsidian"):
        fp = str(ob)
        if "03-Backups" in ob.parts or "node_modules" in ob.parts:
            continue
        vault_roots.append(ob.parent)
    vault_roots = sorted(set(vault_roots))

    if not vault_roots:
        return {"notas": 0, "huerfanas": 0, "rotos": 0, "federado": federado,
                "federadoCorpus": federado_corpus, "rawNotas": 0, "tieneVault": False}

    all_md = []
    for root in vault_roots:
        all_md.extend(root.rglob("*.md"))
    all_md = sorted(set(all_md))

    excl = re.compile(r"[\\/](raw|templates|\.obsidian|\.understand-anything|\.trash)[\\/]")
    files = [f for f in all_md
             if not excl.search(str(f)) and f.name not in ("CLAUDE.md", "log.md")]
    raw_notas = len(all_md) - len(files)

    if not files:
        return {"notas": 0, "huerfanas": 0, "rotos": 0, "federado": federado,
                "federadoCorpus": federado_corpus, "rawNotas": raw_notas, "tieneVault": True}

    names = {f.stem.lower() for f in files}
    inbound: dict[str, int] = {}
    outbound: dict[str, int] = {}
    rotos = 0

    for f in files:
        key = f.stem.lower()
        try:
            content = f.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        # ignorar [[wikilinks]] dentro de código (``` ``` y `..`): son ejemplos, no aristas
        content = re.sub(r"```[\s\S]*?```", "", content)
        content = re.sub(r"`[^`]*`", "", content)
        for m in RX_WIKILINK.finditer(content):
            target = m.group(1).split("|")[0].split("#")[0]
            target = re.split(r"[\\/]", target)[-1].strip().lower()
            if not target:
                continue
            outbound[key] = outbound.get(key, 0) + 1
            if target in names:
                inbound[target] = inbound.get(target, 0) + 1
            else:
                rotos += 1

    huerfanas = sum(1 for f in files
                    if inbound.get(f.stem.lower(), 0) == 0 and outbound.get(f.stem.lower(), 0) == 0)

    return {"notas": len(files), "huerfanas": huerfanas, "rotos": rotos, "federado": federado,
            "federadoCorpus": federado_corpus, "rawNotas": raw_notas, "tieneVault": True}


# --------------------------------------------------------------------------- mcp
def mcp_info(ruta: Path) -> list[str]:
    f = ruta / ".mcp.json"
    if not f.exists():
        return []
    try:
        j = json.loads(f.read_text(encoding="utf-8"))
        return list(j.get("mcpServers", {}).keys())
    except (OSError, ValueError):
        return []


# ------------------------------------------------------------------------ backup
def backup_info(ruta: Path) -> dict:
    b = ruta / "03-Backups"
    if not b.exists():
        return {"existe": False, "ultimo": None, "dias": None, "archivos": 0}
    fs = [p for p in b.rglob("*") if p.is_file()]
    if not fs:
        return {"existe": True, "ultimo": None, "dias": None, "archivos": 0}
    ult = max(fs, key=lambda p: p.stat().st_mtime)
    mtime = datetime.fromtimestamp(ult.stat().st_mtime, tz=timezone.utc)
    dias = round((datetime.now(timezone.utc) - mtime).total_seconds() / 86400, 1)
    return {"existe": True, "ultimo": mtime.isoformat(), "dias": dias, "archivos": len(fs)}


# ------------------------------------------------------------------------ claude
def claude_md(ruta: Path) -> dict:
    f = ruta / "CLAUDE.md"
    if not f.exists():
        return {"existe": False, "bytes": 0, "lineas": 0}
    data = f.read_bytes()
    return {"existe": True, "bytes": len(data),
            "lineas": data.decode("utf-8", "replace").count("\n") + 1}


def descripcion(ruta: Path) -> str | None:
    for name in ("CLAUDE.md", "README.md"):
        f = ruta / name
        if not f.exists():
            continue
        try:
            lines = f.read_text(encoding="utf-8", errors="replace").splitlines()[:80]
        except OSError:
            continue
        en_codigo = False
        for ln in lines:
            t = ln.strip()
            if not t:
                continue
            if t.startswith("```"):
                en_codigo = not en_codigo
                continue
            if en_codigo:
                continue
            if t[0] in "#><|!" or t.startswith("---") or t.startswith("- ") or t.startswith("* "):
                continue
            t = t.replace("**", "").replace("`", "")
            return (t[:237] + "...") if len(t) > 240 else t
    return None


# ------------------------------------------------------ walk pruneado (stack/deploy)
def find_archivos(raiz: Path, nombres: set[str], max_depth: int = 5) -> list[Path]:
    res: list[Path] = []
    stack = [(raiz, 0)]
    while stack:
        cur, depth = stack.pop()
        try:
            kids = list(cur.iterdir())
        except OSError:
            continue
        for k in kids:
            if k.is_dir():
                if depth < max_depth and k.name not in PRUNE:
                    stack.append((k, depth + 1))
            elif k.name in nombres:
                res.append(k)
    return res


def stack(ruta: Path) -> dict:
    lenguajes: list[str] = []
    paquetes: list[str] = []
    manifests = find_archivos(ruta, {"package.json", "requirements.txt", "pyproject.toml"})
    pkgs = sorted([m for m in manifests if m.name == "package.json"],
                  key=lambda p: (len(p.parts), len(str(p))))
    reqs = sorted([m for m in manifests if m.name == "requirements.txt"],
                  key=lambda p: (len(p.parts), len(str(p))))
    pys = [m for m in manifests if m.name == "pyproject.toml"]
    if pkgs:
        lenguajes.append("Node")
        try:
            j = json.loads(pkgs[0].read_text(encoding="utf-8"))
            if j.get("engines", {}).get("node"):
                lenguajes.append("node " + j["engines"]["node"])
            for grp in ("dependencies", "devDependencies"):
                for n in (j.get(grp) or {}):
                    if len(paquetes) < 14 and n not in paquetes:
                        paquetes.append(n)
        except (OSError, ValueError):
            pass
    if reqs or pys:
        if "Python" not in lenguajes:
            lenguajes.append("Python")
    if reqs:
        try:
            for line in reqs[0].read_text(encoding="utf-8", errors="replace").splitlines():
                l = re.split(r"[#;]", line)[0].strip()
                if l:
                    n = re.split(r"[=<>!~\[ ]", l)[0].strip()
                    if n and len(paquetes) < 20 and n not in paquetes:
                        paquetes.append(n)
        except OSError:
            pass
    return {"lenguajes": lenguajes, "paquetes": paquetes}


def _claude_dir(cl: Path) -> dict:
    agentes, skills, comandos = [], [], []
    if cl.exists():
        ag = cl / "agents"
        if ag.exists():
            agentes = [p.stem for p in ag.rglob("*.md")]
        sk = cl / "skills"
        if sk.exists():
            skills = [d.name for d in sk.iterdir() if d.is_dir()]
            skills += [p.stem for p in sk.glob("*.md")]
        cm = cl / "commands"
        if cm.exists():
            comandos = [p.stem for p in cm.rglob("*.md")]
    return {"agentes": agentes, "skills": skills, "comandos": comandos}


def agentes_skills(ruta: Path) -> dict:
    return _claude_dir(ruta / ".claude")


def deploy(ruta: Path) -> list[str]:
    prune = PRUNE - {".vercel"}   # .vercel es un marcador a detectar, no a podar aquí
    vercel = supa = False
    stack_ = [(ruta, 0)]
    while stack_:
        cur, depth = stack_.pop()
        try:
            kids = list(cur.iterdir())
        except OSError:
            continue
        for k in kids:
            if k.is_dir():
                if k.name == ".vercel":
                    vercel = True
                    continue
                if k.name in ("supabase", ".supabase"):
                    supa = True
                    continue
                if depth < 4 and k.name not in prune:
                    stack_.append((k, depth + 1))
            elif k.name == "vercel.json":
                vercel = True
        if vercel and supa:
            break
    d = []
    if vercel:
        d.append("Vercel")
    if supa:
        d.append("Supabase")
    return d


def global_claude() -> dict:
    perfil = os.environ.get("USERPROFILE") or os.environ.get("HOME") or str(Path.home())
    return _claude_dir(Path(perfil) / ".claude")


# -------------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(description="Escaneo de salud de la flota SABIO (portable).")
    ap.add_argument("--centro", help="Ruta a tu Centro de Mando Sabio (el hub). Opcional.")
    ap.add_argument("--proyectos", help="Carpeta que contiene tus proyectos (se escanea cada subcarpeta). Opcional.")
    ap.add_argument("--salida", default=str(AQUI), help="Dónde escribir la salida (por defecto, junto a este script).")
    ap.add_argument("--abrir", action="store_true", help="Abre el panel al terminar.")
    args = ap.parse_args()

    # Fallback: si no se pasan rutas, leer flota.config.json (junto al script) — para doble-clic.
    if not args.centro and not args.proyectos:
        cfg = AQUI / "flota.config.json"
        if cfg.exists():
            try:
                c = json.loads(cfg.read_text(encoding="utf-8-sig"))  # tolera BOM (editores Windows)
                args.centro = args.centro or c.get("centro")
                args.proyectos = args.proyectos or c.get("proyectos")
            except (OSError, ValueError):
                pass
    if not args.centro and not args.proyectos:
        ap.error("indica --centro y/o --proyectos, o crea flota.config.json (copia flota.config.example.json). "
                 "Sin valores por defecto horneados: tú decides qué flota escanear.")

    salida_dir = Path(args.salida).resolve()
    items: list[dict] = []
    if args.centro:
        c = Path(args.centro).resolve()
        if c.exists():
            items.append({"nombre": c.name, "ruta": c, "tipo": "control"})
        else:
            print(f"AVISO: no existe el Centro de Mando: {c}", file=sys.stderr)
    if args.proyectos:
        pd = Path(args.proyectos).resolve()
        if pd.exists():
            for d in sorted([x for x in pd.iterdir() if x.is_dir()], key=lambda p: p.name):
                items.append({"nombre": d.name, "ruta": d, "tipo": "proyecto"})
        else:
            print(f"AVISO: no existe la carpeta de proyectos: {pd}", file=sys.stderr)

    print(f"Escaneando {len(items)} elemento(s)...", file=sys.stderr)
    proyectos = []
    for it in items:
        print(f"  - {it['nombre']}", file=sys.stderr)
        r = it["ruta"]
        proyectos.append({
            "nombre": it["nombre"],
            "tipo": it["tipo"],
            "ruta": str(r),
            "descripcion": descripcion(r),
            "git": git_info(r),
            "vault": vault_info(r),
            "stack": stack(r),
            "agentesSkills": agentes_skills(r),
            "deploy": deploy(r),
            "mcps": mcp_info(r),
            "backup": backup_info(r),
            "claudeMd": claude_md(r),
            "seguridad": seguridad(r),
        })

    salida = {
        "generado": datetime.now(timezone.utc).astimezone().isoformat(),
        "raiz": args.centro or args.proyectos,
        "totalProyectos": len(proyectos),
        "globalClaude": global_claude(),
        "proyectos": proyectos,
    }

    salida_dir.mkdir(parents=True, exist_ok=True)
    (salida_dir / "estado-flota.json").write_text(
        json.dumps(salida, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"OK -> {salida_dir / 'estado-flota.json'}", file=sys.stderr)

    # historial JSONL append-only (últimos 50) para los sparklines
    snap = {"fecha": salida["generado"], "proyectos": {}}
    for p in proyectos:
        g = p["git"]
        snap["proyectos"][p["nombre"]] = {
            "notas": p["vault"]["notas"], "rotos": p["vault"]["rotos"],
            "huerfanas": p["vault"]["huerfanas"],
            "commits": g["commits"] if g["esRepo"] else 0,
            "sucios": g["archivosSucios"] if g["esRepo"] else 0,
            "backupDias": p["backup"]["dias"],
        }
    hist_path = salida_dir / "historial-flota.jsonl"
    lines = []
    if hist_path.exists():
        lines = [l for l in hist_path.read_text(encoding="utf-8").splitlines() if l.strip()]
    lines.append(json.dumps(snap, ensure_ascii=False, separators=(",", ":")))
    lines = lines[-50:]
    hist_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    hist_json = "[" + ",".join(lines) + "]"

    # datos del panel (window.X) — los carga panel/index.html en file://
    datos = salida_dir / "panel" / "datos"
    datos.mkdir(parents=True, exist_ok=True)
    (datos / "estado-flota.js").write_text(
        "window.FLOTA = " + json.dumps(salida, ensure_ascii=False) + ";\n", encoding="utf-8")
    (datos / "historial.js").write_text(
        "window.HISTORIAL = " + hist_json + ";\n", encoding="utf-8")
    print(f"OK -> {datos} (estado-flota.js, historial.js)", file=sys.stderr)

    if args.abrir:
        panel = salida_dir / "panel" / "index.html"
        if panel.exists():
            webbrowser.open(panel.as_uri())
    return 0


if __name__ == "__main__":
    sys.exit(main())
