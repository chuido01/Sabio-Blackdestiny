#!/usr/bin/env python3
"""Validador de registros de aprendizaje - Sala D, perfil agentico (esquema v2.0). Stdlib only.

Valida cada registro de registros/ contra ESQUEMA.md:
  - frontmatter completo y vocabulario controlado
  - coherencia de la maquina de estados y gobernanza por umbral (0.8)
  - integridad referencial: cada ID de relacionado: existe en su Sala duena, segun el
    indice de indices (activo:->B, investigacion:->A, norma:->C, aprendizaje:->D)
Regenera _index.json (indice autoritativo del prefijo aprendizaje:).

Uso: python tools/validar-aprendizaje.py
Salida: avisos/errores por archivo; exit 1 si hay errores. Cero dependencias.
"""
import json, os, re, sys

AQUI = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(AQUI)                 # .../04-Recursos/04-Aprendizaje
RECURSOS = os.path.dirname(BASE)             # .../04-Recursos
REGISTROS = os.path.join(BASE, "registros")

UMBRAL_CONFIANZA = 0.8
RESULTADOS = {"exito", "fallo", "parcial"}
ESTADOS = {"pendiente", "revisado", "promovido", "descartado"}
ORIGENES = {"construccion", "operacion-agentica"}
TIPOS = {"error", "tecnica", "resultado", "laguna"}
PROMOCIONES = {"mejora-activo", "activo-nuevo", "nota-investigacion", "nuevo-vinculo"}
PROMOCIONES_ACTIVO = {"mejora-activo", "activo-nuevo"}
OBLIGATORIOS = ["esquema", "version_esquema", "id", "fecha", "agente", "origen", "contexto",
                "tipo", "resultado", "reclama_novedad", "relacionado", "confianza",
                "estado", "verificado", "sintetico"]

# prefijo de espinazo -> carpeta de la Sala duena (relativa a 04-Recursos)
SALAS = {
    "activo": "02-Catalogo",
    "norma": "03-Referencia",
    "aprendizaje": os.path.join("04-Aprendizaje", "registros"),
    # "investigacion" se resuelve aparte: la boveda tiene nombre variable
}

KEY = re.compile(r"^([a-z][a-z0-9_]*):\s*(.*)$")
ID_PAT = re.compile(r"^aprendizaje:apr-\d{8}-\d{3}$")


def parse_frontmatter(path):
    lines = open(path, encoding="utf-8").read().split("\n")
    if not lines or lines[0].strip() != "---":
        return None
    data = {}
    for ln in lines[1:]:
        if ln.strip() == "---":
            return data
        if ln.lstrip().startswith("#") or not ln.strip():
            continue
        m = KEY.match(ln)
        if m:
            data[m.group(1)] = m.group(2).strip()
    return None  # frontmatter sin cierre


def parse_val(v):
    """Convierte el escalar YAML basico a tipo Python."""
    if v in ("null", "~", ""):
        return None
    if v in ("true", "false"):
        return v == "true"
    if v.startswith("[") or v.startswith("{"):
        try:
            return json.loads(v)
        except Exception:
            return v
    if v.startswith('"') and v.endswith('"') and len(v) >= 2:
        return v[1:-1]
    try:
        return float(v) if "." in v else int(v)
    except ValueError:
        return v


def ids_en_carpeta(carpeta):
    """Set de 'id:' de todos los .md bajo carpeta (lee su frontmatter). None si no existe."""
    if not carpeta or not os.path.isdir(carpeta):
        return None
    encontrados = set()
    for raiz, _, archivos in os.walk(carpeta):
        for fn in archivos:
            if fn.endswith(".md"):
                fm = parse_frontmatter(os.path.join(raiz, fn))
                if fm and "id" in fm:
                    encontrados.add(parse_val(fm["id"]))
    return encontrados


def carpeta_boveda():
    """La Sala A vive en 01-Vault Obsidian/<boveda>/wiki (la boveda tiene nombre variable)."""
    vault = os.path.join(RECURSOS, "01-Vault Obsidian")
    if not os.path.isdir(vault):
        return None
    subs = sorted(d for d in os.listdir(vault) if os.path.isdir(os.path.join(vault, d)))
    return os.path.join(vault, subs[0], "wiki") if subs else None


def main():
    cache = {}  # prefijo -> set de ids (o None si la Sala no existe)

    def ids_de_sala(pref):
        if pref not in cache:
            if pref == "investigacion":
                carpeta = carpeta_boveda()
            elif pref in SALAS:
                carpeta = os.path.join(RECURSOS, SALAS[pref])
            else:
                carpeta = None
            cache[pref] = ids_en_carpeta(carpeta)
        return cache[pref]

    errores, avisos, registros = [], [], []
    archivos = sorted(f for f in os.listdir(REGISTROS) if f.endswith(".md")) if os.path.isdir(REGISTROS) else []

    ids_vistos = set()
    for fn in archivos:
        path = os.path.join(REGISTROS, fn)

        def err(msg):
            errores.append(fn + ": " + msg)

        raw = parse_frontmatter(path)
        if raw is None:
            err("frontmatter ausente o sin cierre '---'")
            continue
        d = {k: parse_val(v) for k, v in raw.items()}

        for k in OBLIGATORIOS:
            if k not in d:
                err("falta campo obligatorio '" + k + "'")
        if d.get("esquema") != "aprendizaje-operativo":
            err("esquema != aprendizaje-operativo")
        rid = d.get("id", "")
        if not ID_PAT.match(str(rid)):
            err("id no cumple aprendizaje:apr-AAAAMMDD-NNN: " + str(rid))
        if "aprendizaje:" + fn[:-3] != str(rid):
            err("id != 'aprendizaje:' + nombre de archivo")
        if rid in ids_vistos:
            err("id duplicado")
        ids_vistos.add(rid)
        if d.get("origen") not in ORIGENES:
            err("origen invalido: " + str(d.get("origen")))
        if d.get("tipo") not in TIPOS:
            err("tipo invalido: " + str(d.get("tipo")))
        if d.get("resultado") not in RESULTADOS:
            err("resultado invalido: " + str(d.get("resultado")))
        estado = d.get("estado")
        if estado not in ESTADOS:
            err("estado invalido: " + str(estado))
        conf = d.get("confianza")
        if not isinstance(conf, (int, float)) or isinstance(conf, bool) or not (0.0 <= float(conf) <= 1.0):
            err("confianza fuera de [0,1]: " + str(conf))

        # --- integridad referencial: cada ref existe en su Sala duena ---
        rel = d.get("relacionado")
        if rel is not None and not isinstance(rel, list):
            err("relacionado debe ser una lista JSON inline, p.ej. [\"activo:x\"]")
            rel = []
        for ref in (rel or []):
            if not isinstance(ref, str) or ":" not in ref:
                err("relacionado sin prefijo de espinazo: " + str(ref))
                continue
            pref = ref.split(":", 1)[0]
            ids = ids_de_sala(pref)
            if ids is None:
                avisos.append(fn + ": Sala de '" + pref + ":' no existe aun (ref no verificable: " + ref + ")")
            elif ref not in ids:
                err("referencia rota: " + ref + " no existe en la Sala '" + pref + "'")

        # --- maquina de estados / gobernanza por umbral ---
        rev_por = d.get("revisado_por")
        if estado == "pendiente" and (rev_por or d.get("promocion_tipo")):
            err("pendiente no puede tener revision/promocion")
        if estado in ("revisado", "promovido", "descartado"):
            if not rev_por:
                err(estado + " exige revisado_por")
            if not d.get("revision_fecha"):
                err(estado + " exige revision_fecha")
        if estado == "descartado" and not d.get("motivo_descarte"):
            err("descartado exige motivo_descarte")
        if estado == "promovido":
            pt = d.get("promocion_tipo")
            if pt not in PROMOCIONES:
                err("promocion_tipo invalido: " + str(pt))
            if not d.get("promocion_destino"):
                err("promovido exige promocion_destino")
            es_humano = "humano" in str(rev_por or "")
            if pt in PROMOCIONES_ACTIVO and not es_humano:
                err("gobernanza: " + str(pt) + " (toca un activo) exige aprobacion humana")
            if pt in ("nota-investigacion", "nuevo-vinculo") and not es_humano:
                if not (isinstance(conf, (int, float)) and float(conf) >= UMBRAL_CONFIANZA):
                    err("gobernanza: aprobacion solo-agente exige confianza >= " + str(UMBRAL_CONFIANZA))
        if d.get("verificado") is True and estado == "pendiente":
            err("verificado:true incompatible con estado pendiente")

        registros.append({
            "id": rid, "origen": d.get("origen"), "tipo": d.get("tipo"),
            "resultado": d.get("resultado"), "reclama_novedad": bool(d.get("reclama_novedad")),
            "confianza": conf, "estado": estado, "promocion_tipo": d.get("promocion_tipo"),
            "sintetico": bool(d.get("sintetico")), "creado": str(d.get("fecha")),
            "ruta": "registros/" + fn,
        })

    # --- _index.json (autoritativo del prefijo aprendizaje:) ---
    reales = [r for r in registros if not r["sintetico"]]
    index = {
        "esquema": "aprendizaje-operativo",
        "version_esquema": "2.0",
        "umbral_confianza": UMBRAL_CONFIANZA,
        "nota": "Indice autoritativo del prefijo aprendizaje:. Los sintetico:true validan el esquema y se excluyen de las metricas.",
        "totales": {
            "registros": len(registros),
            "reales": len(reales),
            "sinteticos": len(registros) - len(reales),
            "por_estado_reales": {e: sum(1 for r in reales if r["estado"] == e) for e in sorted(ESTADOS)},
        },
        "registros": registros,
    }
    with open(os.path.join(BASE, "_index.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=2)

    print("registros:", len(registros), "(reales:", len(reales), "| sinteticos:", len(registros) - len(reales), ")")
    for a in avisos:
        print("AVISO:", a)
    if errores:
        print("ERRORES:", len(errores))
        for e in errores:
            print("  -", e)
        sys.exit(1)
    print("0 errores. _index.json regenerado.")


if __name__ == "__main__":
    main()
