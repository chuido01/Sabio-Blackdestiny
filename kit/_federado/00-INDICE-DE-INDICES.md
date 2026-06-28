<!-- sabio-generacion: 1 -->
<!-- sabio:canonico:inicio — NO edites entre estos marcadores: la convergencia del Kit re-proyecta esta región. Lo tuyo va DEBAJO del cierre. -->
# Índice de índices — <NombreProyecto>

> **SABIO** = *Sistema de Archivos, Bóvedas e Índices Organizados*: el sistema de **memoria y
> conocimiento** del proyecto (**sin RAG** — bóveda-wiki estilo Karpathy + 4 Salas federadas).
>
> **Este archivo es el espinazo de SABIO.** Dice **qué prefijo de ID vive en qué sala**. Es lo que
> convierte cuatro carpetas sueltas en *un* cerebro: cualquier agente (o humano) que encuentre un ID
> sabe aquí dónde resolverlo. Creado: <fecha>.
>
> **Nomenclatura:** *Capa 1/2* = arquitectura del sistema · *Sala A/B/C/D* = tipos de conocimiento.

---

## Namespace de IDs (los prefijos)

| Prefijo | Sala | Qué identifica | Almacén físico | Índice de esa sala |
|---|---|---|---|---|
| `investigacion:<slug>` | **Sala A · Investigación** | Una nota atómica del wiki | `01-Boveda/<NombreBoveda>/wiki/` | `01-Boveda/<NombreBoveda>/index.md` |
| `activo:<slug>` | **Sala B · Catálogo** | Una ficha de capacidad/activo/producto | `02-Catalogo/fichas/` | `02-Catalogo/index.md` |
| `norma:<marco>:<codigo>` | **Sala C · Referencia** | Una entrada de estándar/normativa externa | `03-Referencia/registros/` | `03-Referencia/index.md` |
| `aprendizaje:<id>` | **Sala D · Aprendizaje** | Un aprendizaje operativo (al **construir** o al **ejecutar**) | `04-Aprendizaje/registros/` | *(perfil base: sin índice, se filtra por `estado:`; perfil agéntico: `_index.json`)* |

---

## Reglas del espinazo (no negociables)

1. **Un dato vive en UNA sola sala** (su dueña). Las demás lo **referencian por ID**, nunca lo copian.
2. **Los IDs son estables**: una vez asignado, un ID no se renombra (las referencias se romperían).
3. **Cadena de razonamiento típica:** contexto → activo que aplica (B) → normas que satisface (C) →
   aprendizajes previos sobre ese activo (D) → investigación de fondo (A).
4. Si una sala aún no se usa, **su prefijo ya está reservado** — no inventes otros formatos de ID.
5. **Reparto local↔global (Sala C):** la referencia externa que solo usa este proyecto vive **local**; la **oficial/pública/inmutable/no-confidencial** que toque a más de un proyecto se promueve al **plano global** (Centro de Mando) vía `/sabio-promover`, etiquetada por **`ambito:`** — `universal` · `jurisdiccion: <ISO-3166>` · `sector: <slug>`. El criterio es **alcance-de-uso × naturaleza**, **no** internacional-vs-nacional. Este proyecto resuelve del global lo `universal` + lo que matchee su **perfil de aplicabilidad** (declarado en el `CLAUDE.md`).

---

## Cómo amoldar esto a tu proyecto (sin perder el sentido)

- **Puedes renombrar los prefijos** al vocabulario de tu dominio (p. ej. `activo:` → `herramienta:`,
  `norma:` → `regla:`), **una sola vez y al inicio**, actualizando esta tabla.
- **No puedes** fusionar dos salas en una, copiar datos entre salas, ni dar a un prefijo dos almacenes.
- El **sentido de cada sala** (qué tipo de conocimiento guarda y por qué vive separada) está en el
  `LEEME - Esquema` dentro de cada carpeta. Léelo antes de usarla por primera vez.
<!-- sabio:canonico:fin -->

---

## Estado de las Salas en este proyecto (LOCAL — tuyo, edítalo libremente)

> Esta sección es **tuya**: la convergencia del Kit **no la toca** (está fuera de la región canónica de
> arriba). Anota aquí qué Salas están activas, tus **dominios** (`dominio:<slug>` de la Sala A), tu
> **perfil de aplicabilidad** (`jurisdiccion:`/`sector:` para resolver la Sala C global) y los conteos vivos.

| Sala | Estado en este proyecto |
|---|---|
| A · Investigación | <RELLENAR> |
| B · Catálogo | <RELLENAR> |
| C · Referencia | <RELLENAR> |
| D · Aprendizaje | <RELLENAR> |
