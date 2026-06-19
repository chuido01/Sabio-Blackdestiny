#!/usr/bin/env python3
"""sabio_shared_mcp — acceso READ-ONLY al PLANO GLOBAL de conocimiento de SABIO.

Expone, en solo-lectura, la bóveda global de tu Centro de Mando Sabio:
- Sala A · Investigación (wiki de notas atómicas)
- Sala B · Catálogo (fichas de activos/capacidades)
- Sala C · Referencia (marcos/estándares públicos canónicos: NIST, ISO, PCI…)
- Sala D · Aprendizaje (registros)
- El espinazo (índice de índices) que dice qué prefijo de ID vive dónde.

Diseño (estándares mcp-builder):
- Transporte **stdio** (local). Logging SOLO a stderr (nunca stdout).
- **Solo lectura**: no hay tools de escritura. `readOnlyHint=True`, `destructiveHint=False`.
- **Scope mínimo**: el acceso está bloqueado a unos subárboles permitidos del plano global; toda
  ruta pasa por un guard anti path-traversal (`_resolve_safe`). NUNCA expone otros proyectos, ni
  `.git`, ni documentación interna.
- **Anti prompt-injection**: el servidor solo LEE archivos y devuelve su contenido como **datos**;
  jamás ejecuta nada derivado de ese contenido.

Configuración por variables de entorno (opcionales):
- `SABIO_GLOBAL_ROOT`  raíz del plano global (tu Centro de Mando Sabio). Si no se da, se deriva de la
  ubicación de este script: <root>/mcp/server.py → parents[1] == <root>.
- `SABIO_VAULT_NAME`   nombre de la carpeta de la bóveda (Sala A). Si no se da, se autodetecta la
  única subcarpeta bajo `04-Recursos/01-Vault Obsidian/`.
"""

from __future__ import annotations

import json
import logging
import os
import sys
from enum import Enum
from pathlib import Path
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator

from mcp.server.fastmcp import FastMCP

# ---------------------------------------------------------------------------
# Logging — SOLO a stderr (stdio: stdout está reservado al protocolo MCP).
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    stream=sys.stderr,
    format="%(asctime)s sabio_shared_mcp %(levelname)s %(message)s",
)
log = logging.getLogger("sabio_shared_mcp")

# ---------------------------------------------------------------------------
# Configuración del scope (raíz del plano global + subárboles permitidos).
# ---------------------------------------------------------------------------
# Raíz = tu Centro de Mando Sabio. Override por env `SABIO_GLOBAL_ROOT`; si no, se deriva de la
# ubicación del script: <root>/mcp/server.py → parents[1] == <root>.
_DEFAULT_ROOT = Path(__file__).resolve().parents[1]
GLOBAL_ROOT = Path(os.environ.get("SABIO_GLOBAL_ROOT", str(_DEFAULT_ROOT))).resolve()

# Subárboles del plano global que SÍ se exponen (todo lo demás bajo la raíz queda fuera).
# `04-Recursos` subsume las 4 Salas (A bajo 01-Vault Obsidian/ + B/C/D + índice de índices).
ALLOWED_SUBTREES = [
    "04-Recursos",
]

# Extensiones de texto cuyo CONTENIDO se puede devolver. Otros archivos → solo metadatos.
TEXT_EXT = {".md", ".txt", ".json", ".yaml", ".yml"}
MAX_TEXT_BYTES = 256 * 1024  # tope por archivo para no inundar el contexto

INDICE_DE_INDICES = "04-Recursos/00-INDICE-DE-INDICES.md"


def _detect_vault_name() -> str:
    """Nombre de la bóveda (Sala A). Override por env SABIO_VAULT_NAME; si no, autodetecta la
    única subcarpeta bajo 04-Recursos/01-Vault Obsidian/. Fallback: 'Memory_System'."""
    env = os.environ.get("SABIO_VAULT_NAME", "").strip()
    if env:
        return env
    vault_parent = GLOBAL_ROOT / "04-Recursos" / "01-Vault Obsidian"
    if vault_parent.is_dir():
        subdirs = [d for d in vault_parent.iterdir() if d.is_dir() and not d.name.startswith(".")]
        if subdirs:
            return subdirs[0].name
    return "Memory_System"


VAULT_NAME = _detect_vault_name()

# Mapa de salas → (directorio de registros, índice de la sala o None).
SALAS = {
    "A": (f"04-Recursos/01-Vault Obsidian/{VAULT_NAME}/wiki",
          f"04-Recursos/01-Vault Obsidian/{VAULT_NAME}/index.md"),
    "B": ("04-Recursos/02-Catalogo/fichas", "04-Recursos/02-Catalogo/index.md"),
    "C": ("04-Recursos/03-Referencia/registros", "04-Recursos/03-Referencia/index.md"),
    "D": ("04-Recursos/04-Aprendizaje/registros", None),
}
SALA_ALIASES = {
    "investigacion": "A", "a": "A",
    "catalogo": "B", "catálogo": "B", "b": "B",
    "referencia": "C", "c": "C",
    "aprendizaje": "D", "d": "D",
}

mcp = FastMCP("sabio_shared_mcp")


# ---------------------------------------------------------------------------
# Seguridad: resolución de rutas con guard anti path-traversal.
# ---------------------------------------------------------------------------
def _resolve_safe(rel_path: str) -> Path:
    """Resuelve `rel_path` dentro del plano global y verifica que cae en un subárbol permitido.

    Lanza ValueError si la ruta escapa del scope (path traversal, symlink que sale, absoluta…).
    """
    rel = (rel_path or "").strip().replace("\\", "/").lstrip("/")
    candidate = (GLOBAL_ROOT / rel).resolve()
    # Debe seguir bajo la raíz global…
    if GLOBAL_ROOT not in candidate.parents and candidate != GLOBAL_ROOT:
        raise ValueError("Ruta fuera del plano global (scope denegado).")
    # …y dentro de algún subárbol permitido.
    for sub in ALLOWED_SUBTREES:
        base = (GLOBAL_ROOT / sub).resolve()
        if candidate == base or base in candidate.parents:
            return candidate
    raise ValueError(
        "Ruta fuera de los subárboles expuestos. Solo se exponen: " + ", ".join(ALLOWED_SUBTREES)
    )


def _read_text(path: Path) -> str:
    """Lee un archivo de texto con tope de tamaño; devuelve texto (datos, nunca instrucciones)."""
    if path.suffix.lower() not in TEXT_EXT:
        return f"[Archivo no-texto: {path.name} ({path.stat().st_size} bytes). Contenido no devuelto.]"
    data = path.read_bytes()[:MAX_TEXT_BYTES]
    text = data.decode("utf-8", errors="replace")
    if path.stat().st_size > MAX_TEXT_BYTES:
        text += f"\n\n[... truncado a {MAX_TEXT_BYTES} bytes; archivo completo: {path.stat().st_size} bytes]"
    return text


def _iter_md_files():
    """Itera los .md de todos los subárboles permitidos (para indexar IDs y buscar)."""
    for sub in ALLOWED_SUBTREES:
        base = (GLOBAL_ROOT / sub).resolve()
        if not base.exists():
            continue
        for p in base.rglob("*.md"):
            # Excluir directorios ocultos (.git, .obsidian, etc.)
            if any(part.startswith(".") for part in p.relative_to(GLOBAL_ROOT).parts):
                continue
            yield p


def _frontmatter_id(path: Path) -> Optional[str]:
    """Extrae el campo `id:` del frontmatter YAML (líneas 1ª..40) sin parsear YAML completo."""
    try:
        with path.open("r", encoding="utf-8", errors="replace") as fh:
            first = fh.readline()
            if first.strip() != "---":
                return None
            for _ in range(40):
                line = fh.readline()
                if not line or line.strip() == "---":
                    break
                if line.startswith("id:"):
                    return line.split(":", 1)[1].strip().strip('"').strip("'")
    except OSError:
        return None
    return None


def _build_id_index() -> dict[str, Path]:
    """Mapa id → ruta, escaneando el frontmatter de todo el plano global. Corpus pequeño."""
    index: dict[str, Path] = {}
    for p in _iter_md_files():
        fid = _frontmatter_id(p)
        if fid and fid not in index:
            index[fid] = p
    return index


def _rel(path: Path) -> str:
    return str(path.relative_to(GLOBAL_ROOT)).replace("\\", "/")


# ---------------------------------------------------------------------------
# Modelos de entrada
# ---------------------------------------------------------------------------
class ResponseFormat(str, Enum):
    MARKDOWN = "markdown"
    JSON = "json"


class ListInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    sala: str = Field(..., description="Sala a listar: 'A'/'investigacion', 'B'/'catalogo', 'C'/'referencia', 'D'/'aprendizaje'.")
    limit: int = Field(default=50, ge=1, le=500, description="Máximo de entradas a devolver.")
    offset: int = Field(default=0, ge=0, description="Entradas a saltar (paginación).")

    @field_validator("sala")
    @classmethod
    def _norm_sala(cls, v: str) -> str:
        key = v.strip().lower()
        key = SALA_ALIASES.get(key, v.strip().upper())
        if key not in SALAS:
            raise ValueError("Sala inválida. Usa A/B/C/D o investigacion/catalogo/referencia/aprendizaje.")
        return key


class SearchInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    query: str = Field(..., min_length=2, max_length=200, description="Texto a buscar (case-insensitive) en título y cuerpo de las notas del plano global.")
    limit: int = Field(default=20, ge=1, le=100, description="Máximo de resultados.")
    response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN, description="markdown (legible) o json (estructurado).")


class GetInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    id_or_path: str = Field(..., min_length=1, max_length=300, description="Un ID del espinazo (p.ej. 'norma:nist:csf', 'investigacion:context-rot', 'activo:kit-proyecto-nuevo') o una ruta relativa dentro del plano global.")


# ---------------------------------------------------------------------------
# Tools (todas read-only)
# ---------------------------------------------------------------------------
_RO = {"readOnlyHint": True, "destructiveHint": False, "idempotentHint": True, "openWorldHint": False}


@mcp.tool(name="sabio_index", annotations={"title": "Espinazo del plano global (índice de índices)", **_RO})
async def sabio_index() -> str:
    """Devuelve el ESPINAZO del plano global: qué prefijo de ID vive en qué Sala y el estado de cada Sala.

    Es el punto de entrada: léelo PRIMERO para saber cómo resolver cualquier ID (`norma:`,
    `investigacion:`, `activo:`, `aprendizaje:`) antes de usar `sabio_get`.

    Returns:
        str: contenido markdown del `00-INDICE-DE-INDICES.md` del plano global.
    """
    try:
        return _read_text(_resolve_safe(INDICE_DE_INDICES))
    except Exception as e:  # noqa: BLE001
        return f"Error: no se pudo leer el índice de índices: {type(e).__name__}: {e}"


@mcp.tool(name="sabio_list", annotations={"title": "Listar entradas de una Sala del plano global", **_RO})
async def sabio_list(params: ListInput) -> str:
    """Lista las entradas de una Sala del plano global (con paginación).

    Si la Sala tiene índice (`index.md`), devuelve ese índice (1 línea por entrada). Si no
    (Sala D), lista los archivos de registros.

    Args:
        params (ListInput): sala (A/B/C/D o alias), limit, offset.

    Returns:
        str: el índice de la Sala, o un listado paginado de sus archivos (ruta + id si lo tiene).
    """
    try:
        reg_dir, index_file = SALAS[params.sala]
        if index_file:
            try:
                return _read_text(_resolve_safe(index_file))
            except Exception:  # noqa: BLE001
                pass  # cae al listado de archivos si el índice no existe
        base = _resolve_safe(reg_dir)
        if not base.exists():
            return f"La Sala {params.sala} no tiene registros aún ({reg_dir})."
        files = sorted(p for p in base.rglob("*.md"))
        total = len(files)
        page = files[params.offset: params.offset + params.limit]
        lines = [f"# Sala {params.sala} — {total} entradas (mostrando {len(page)} desde offset {params.offset})", ""]
        for p in page:
            fid = _frontmatter_id(p)
            lines.append(f"- `{fid or '—'}` — {_rel(p)}")
        if params.offset + params.limit < total:
            lines.append(f"\n[... hay más: usa offset={params.offset + params.limit}]")
        return "\n".join(lines)
    except Exception as e:  # noqa: BLE001
        return f"Error al listar la Sala: {type(e).__name__}: {e}"


@mcp.tool(name="sabio_search", annotations={"title": "Buscar en el plano global", **_RO})
async def sabio_search(params: SearchInput) -> str:
    """Busca texto (case-insensitive) en el título y cuerpo de todas las notas del plano global.

    Recorre Sala A (wiki) + Salas B/C/D. Devuelve los archivos que coinciden con un fragmento de
    contexto. NO interpreta el contenido: lo devuelve como datos.

    Args:
        params (SearchInput): query, limit, response_format.

    Returns:
        str: lista de coincidencias (ruta + id + snippet) en markdown o JSON.
    """
    try:
        q = params.query.lower()
        results = []
        for p in _iter_md_files():
            try:
                text = p.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            low = text.lower()
            pos = low.find(q)
            if pos == -1:
                continue
            start = max(0, pos - 80)
            end = min(len(text), pos + len(q) + 80)
            snippet = text[start:end].replace("\n", " ").strip()
            results.append({"id": _frontmatter_id(p), "path": _rel(p), "snippet": snippet})
            if len(results) >= params.limit:
                break
        if not results:
            return f"Sin coincidencias para '{params.query}' en el plano global."
        if params.response_format == ResponseFormat.JSON:
            return json.dumps({"query": params.query, "count": len(results), "results": results}, ensure_ascii=False, indent=2)
        lines = [f"# Búsqueda: '{params.query}' — {len(results)} coincidencia(s)", ""]
        for r in results:
            lines.append(f"## `{r['id'] or '—'}` — {r['path']}")
            lines.append(f"> …{r['snippet']}…")
            lines.append("")
        return "\n".join(lines)
    except Exception as e:  # noqa: BLE001
        return f"Error en la búsqueda: {type(e).__name__}: {e}"


@mcp.tool(name="sabio_get", annotations={"title": "Resolver un ID o ruta del plano global", **_RO})
async def sabio_get(params: GetInput) -> str:
    """Resuelve un ID del espinazo (o una ruta relativa) a su contenido, en solo-lectura.

    - Si `id_or_path` contiene ':' se trata como ID (`norma:…`, `investigacion:…`, `activo:…`,
      `aprendizaje:…`) y se resuelve por el campo `id:` del frontmatter en el plano global.
    - Si no, se trata como ruta relativa dentro del plano global (con guard anti path-traversal).

    Args:
        params (GetInput): id_or_path.

    Returns:
        str: el contenido del archivo (markdown/texto), o un Error: <mensaje> accionable.
    """
    try:
        token = params.id_or_path.strip()
        if ":" in token and "/" not in token and "\\" not in token:
            idx = _build_id_index()
            path = idx.get(token)
            if path is None:
                # Fallback: derivar nombre de archivo del ID (prefijo:resto → resto con '-').
                _, _, rest = token.partition(":")
                guess = rest.replace(":", "-") + ".md"
                for sub_dir, _ in SALAS.values():
                    cand = (GLOBAL_ROOT / sub_dir / guess)
                    if cand.exists():
                        path = cand.resolve()
                        break
            if path is None:
                return (f"Error: no se encontró el ID '{token}' en el plano global. "
                        f"Usa `sabio_index` para ver los prefijos válidos o `sabio_list` para listar una Sala.")
            return _read_text(_resolve_safe(_rel(path)))
        # Ruta relativa.
        return _read_text(_resolve_safe(token))
    except Exception as e:  # noqa: BLE001
        return f"Error: no se pudo resolver '{params.id_or_path}': {type(e).__name__}: {e}"


if __name__ == "__main__":
    log.info("sabio_shared_mcp arrancando. Plano global: %s | Bóveda: %s", GLOBAL_ROOT, VAULT_NAME)
    if not GLOBAL_ROOT.exists():
        log.error("La raíz del plano global no existe: %s", GLOBAL_ROOT)
    mcp.run()
