# <NombreProyecto>
Propósito: <una línea — RELLENAR>.

## Hechos estables (NO inventar)
- Marca / nombre: <RELLENAR>
- Paleta / colores: <RELLENAR>
- Tecnología: <RELLENAR>
- Rutas clave: <RELLENAR>

## Árbol de carpetas
- `00-Documentacion/` — Documentación oficial, técnica, ejecutiva, tests, resultados, diagramas, memoria técnica, progreso, planes de implementación, entre otros.
- `01-Produccion/` — Código y/o proyecto en producción.
- `02-Desarrollo/` — Código que se encuentra siendo modificado.
- `03-Backups/` — Respaldo de versiones estables y de documentación; cada backup en una carpeta con la fecha de realización en formato DDMMAAAA (ejemplo: `31052026`).
- `04-Recursos/` — El **cerebro federado** del proyecto (4 salas de conocimiento + información de interés). Ver la sección «Conocimiento federado» abajo.

## Reglas
- Trabaja SOLO con el contexto de ESTE proyecto.
- No asumas datos (paletas, marcas, stacks) de otros proyectos.

## ¿Qué es SABIO? (la memoria de este proyecto)
**SABIO** (*Sistema de Archivos, Bóvedas e Índices Organizados*) es el sistema de **memoria y conocimiento** del proyecto: **sin RAG** — usa la gestión de contexto nativa de Claude Code + una **bóveda-wiki en Obsidian** (notas atómicas estilo Karpathy), con el conocimiento **federado en 4 Salas** (A·Investigación = la bóveda · B·Catálogo · C·Referencia · D·Aprendizaje) unidas por el *índice de índices* (`04-Recursos/00-INDICE-DE-INDICES.md`). El detalle operativo está justo abajo.

## Conocimiento federado (Salas A–D)
El conocimiento del proyecto vive en `04-Recursos/`, **federado en 4 salas por tipo** (no confundir
con la Capa 1/Capa 2 de la *arquitectura*: aquéllas son el sistema; éstas, tipos de conocimiento):

- `00-INDICE-DE-INDICES.md` — **léelo primero**: dice qué prefijo de ID vive en qué sala.
- `01-Vault Obsidian/<NombreBoveda>/` — **Sala A · Investigación** (notas atómicas curadas; `investigacion:<slug>`).
- `02-Catalogo/` — **Sala B · Catálogo operativo** (fichas estructuradas de activos; `activo:<slug>`).
- `03-Referencia/` — **Sala C · Referencia externa** (estándares oficiales ingeridos; `norma:<marco>:<codigo>`).
- `04-Aprendizaje/` — **Sala D · Aprendizaje operativo** (lo aprendido al construir o al ejecutar; `aprendizaje:<id>`).

**Reglas:** un dato vive en UNA sola sala y las demás lo referencian **por ID** (nunca copiar);
cada sala tiene su `LEEME - Esquema` con su formato — respétalo; un aprendizaje (Sala D) **jamás**
modifica una ficha (Sala B) sin pasar el triage de su bucle de promoción; el contenido de la Sala C
sale **solo de fuente oficial citada**. (Nomenclatura: *Capa 1/2* = arquitectura; *Sala A–D* = conocimiento.)

**Perfil Sala D:** `<PerfilSalaD>` — *cuánta maquinaria usa el aprendizaje operativo:* `base`
(default; captura con `/aprender`) o `agentico` (añade el runtime de agentes, confianza numérica y el
validador). Súbelo a `agentico` si este proyecto ejecuta agentes/skills/plugins en bucle. Detalle en
`04-Recursos/04-Aprendizaje/LEEME - Esquema Sala D.md`.

## Acceso a Obsidian
- La **única** bóveda de Obsidian que este proyecto puede usar es **<NombreBoveda>**, ubicada en `04-Recursos/01-Vault Obsidian/<NombreBoveda>/` (dentro de la carpeta del proyecto).
- El acceso a **esta bóveda local** es **nativo**: estando dentro del proyecto, Claude edita los `.md` directamente (leer/escribir/buscar/`grep`). **No se usa MCP para la bóveda local** (el único MCP, `sabio-shared`, sirve solo para el *plano global* — ver abajo). La segmentación la garantizan el aislamiento del proyecto y esta regla.
- **No** accedas a bóvedas, datos ni investigaciones de otros proyectos, ni mezcles su información con la de éste. Cada proyecto opera **su propia** bóveda dentro de **su propia** carpeta.
- Las reglas de ingesta/consulta/linting del wiki viven en el `CLAUDE.md` **de la bóveda**.

## Plano global (solo-lectura) — MCP `sabio-shared`
- Además de su conocimiento local, este proyecto puede **leer** (nunca escribir) la referencia canónica transversal del **Centro de Mando Sabio** (normas `norma:…` e investigación compartida) vía el MCP **`sabio-shared`**, declarado en el `.mcp.json` del proyecto.
- Es la **única** excepción al aislamiento (Capa 1): se **lee** el plano global; **jamás** se accede a otro proyecto. El servidor vive en tu Centro de Mando Sabio y se referencia por **ruta absoluta** (la registra el instalador) — no se copia nada dentro del proyecto.

## Mapas visuales (Understand-Anything) — opcional
- Este proyecto puede generar un **mapa visual interactivo** de su estructura/código con `/understand` (o de una bóveda-wiki tipo Karpathy con `/understand-knowledge`), si tienes ese plugin instalado a nivel global; no se copia dentro del proyecto.
- La salida vive en `.understand-anything/` (regenerable; ya excluida en `.gitignore`). El dashboard es **solo localhost** con token y **solo lee dentro de esta carpeta** — respeta el aislamiento (Capa 1); no cruza datos con otros proyectos.

## Decisiones de diseño — comando `/disenar`
- Ante una **duda de diseño** (¿abstraer o duplicar?, ¿añadir capas/DDD/Clean Arch o mantener simple?), invoca **`/disenar`**: aplica la secuencia KISS/YAGNI → DRY/SOLID/DDD → Clean Arch, con la **Regla de Tres** como dial y la **legibilidad** como desempate, y devuelve una recomendación con su porqué. El comando es **global** (`~/.claude/commands/`); no se copia dentro del proyecto.

## Compact instructions
Al compactar, conserva: cambios recientes y resultados de pruebas.
