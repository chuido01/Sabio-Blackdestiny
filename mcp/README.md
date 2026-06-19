# MCP `sabio-shared` — el puente de solo-lectura al plano global

> Un servidor MCP (stdio) que deja a un proyecto **leer** —nunca escribir— el conocimiento común de
> tu **Centro de Mando Sabio** (Salas C y D transversales, investigación compartida, índice de
> índices). Es la **única** excepción al aislamiento entre proyectos.

## Qué expone (4 herramientas, todas read-only)
- `sabio_index` — el espinazo: qué prefijo de ID vive en qué Sala. **Léelo primero.**
- `sabio_list` — lista las entradas de una Sala (A/B/C/D), con paginación.
- `sabio_search` — busca texto en todas las notas del plano global.
- `sabio_get` — resuelve un ID (`norma:…`, `investigacion:…`, `activo:…`, `aprendizaje:…`) o una ruta.

## Seguridad (por diseño)
- **Solo lectura**: no hay ninguna herramienta de escritura.
- **Scope mínimo**: solo expone `04-Recursos/` del plano global. Un guard anti path-traversal
  (`_resolve_safe`) bloquea cualquier ruta que intente salir. Nunca expone otros proyectos, `.git`,
  ni documentación interna.
- **Anti prompt-injection**: devuelve el contenido como **datos**; jamás ejecuta nada derivado de él.

## Instalación
```bash
# desde la carpeta del repo
python -m venv .venv
# Windows:  .venv\Scripts\activate     ·  macOS/Linux:  source .venv/bin/activate
pip install -r mcp/requirements.txt
```
Requisitos: Python 3.10+. Dependencias: `mcp` y `pydantic` (ver `requirements.txt`).

## Registro en un proyecto (`.mcp.json`)
Cada proyecto declara el servidor apuntando a **tu** Centro de Mando Sabio. Ejemplo (Windows):
```json
{
  "mcpServers": {
    "sabio-shared": {
      "command": "C:\\Centro de Mando Sabio\\mcp\\.venv\\Scripts\\python.exe",
      "args": ["C:\\Centro de Mando Sabio\\mcp\\server.py"],
      "env": { "SABIO_GLOBAL_ROOT": "C:\\Centro de Mando Sabio" }
    }
  }
}
```
En macOS/Linux, `command` es el `python` del venv (`.venv/bin/python`) y las rutas usan `/`.
El Kit (`Crear-Proyecto.ps1 -CentroDeMando …`) genera este bloque por ti.

## Variables de entorno (opcionales)
- `SABIO_GLOBAL_ROOT` — raíz del plano global (tu Centro de Mando Sabio). Si no se da, se deriva de
  la ubicación del `server.py` (`<root>/mcp/server.py` → `<root>`).
- `SABIO_VAULT_NAME` — nombre de la carpeta de la bóveda (Sala A). Si no se da, se **autodetecta** la
  única subcarpeta bajo `04-Recursos/01-Vault Obsidian/`.
