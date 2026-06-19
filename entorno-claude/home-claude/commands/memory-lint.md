---
description: Lint del sistema de memoria/conocimiento (SABIO) — gobierna "una fuente por capa" (anti-duplicación y drift). Orquesta el agente sabio-curator y el skill consolidate-memory. Por defecto solo reporta.
argument-hint: [--fix] [A|B|C|D|sabio|auto]
model: sonnet
---

Ejecuta un **lint de memoria/conocimiento** para el **proyecto actual**, haciendo cumplir la regla
**"una fuente por capa"** de SABIO. Por defecto es **solo-reporte** (no aplica cambios).

## Argumentos ("$ARGUMENTS")
- `--fix` → aplica las correcciones **seguras**; mover/fusionar/borrar **solo con confirmación**; los **IDs no se renombran**. Sin `--fix` = dry-run (solo reporta).
- Alcance opcional: `A|B|C|D` (una Sala), `sabio` (todas las Salas + vault), `auto` (solo auto-memoria). Sin alcance = **todo**.

## Qué auditar (las capas)
1. **SABIO — federación del proyecto** (`04-Recursos/` + el vault de la Sala A). **Delega en el agente `sabio-curator`** (vía Task). Que verifique:
   - Un dato vive en **UNA** Sala; las demás lo referencian por **ID** → detecta copias que deberían ser punteros.
   - **IDs** únicos y estables (sin duplicados; sin renombrados que rompan referencias).
   - Grafo del wiki: **`[[enlaces]]` rotos = 0**, notas **huérfanas**, índices al día (`index.md` de la bóveda + `04-Recursos/00-INDICE-DE-INDICES.md`).
   - **Plano global:** si el proyecto declara el MCP `sabio-shared`, comprueba que cada `norma:` (Sala C) sea un **puntero** al plano global, no una **copia** local.
2. **Auto-memoria** (`~/.claude/projects/<proyecto>/memory/` + su `MEMORY.md`). **Invoca el skill `consolidate-memory`** (pase reflexivo: fusiona duplicados, corrige hechos obsoletos, poda el índice).
3. **Cruce entre capas (anti-duplicación):** el **mismo hecho** no debe vivir a la vez en `CLAUDE.md` ↔ una Sala ↔ auto-memoria. Para cada colisión, elige la **fuente canónica** y deja las demás como **referencia**:
   - Preferencia **transversal** (cómo trabajar, gustos) → `~/.claude/CLAUDE.md`.
   - Hecho **específico del proyecto** → el `CLAUDE.md` del proyecto o su Sala (según el tipo).
   - **Conocimiento federado** (investigación, ficha, norma, aprendizaje) → su Sala dueña, referenciado por ID.

## Reglas
- **Aislamiento:** solo el proyecto actual. No leas ni toques otros proyectos (única excepción: **leer** el plano global vía `sabio-shared`).
- **No destructivo por defecto:** sin `--fix` no escribes nada. Con `--fix`, confirma antes de borrar/fusionar/mover; los **IDs no se renombran** (romperían referencias).
- Respeta el `LEEME - Esquema` de cada Sala y el esquema del `CLAUDE.md` de la bóveda.

## Salida
Un **informe** con: duplicados (con la fuente canónica propuesta), *drift*/hechos obsoletos, `[[enlaces]]` rotos, notas huérfanas, colisiones entre capas, y copias que deberían ser punteros al plano global. Si corriste con `--fix`, añade qué se aplicó y qué quedó pendiente de confirmación.
