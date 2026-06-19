# Índice de índices — <NombreProyecto>

> **SABIO** = *Sistema de Archivos, Bóvedas e Índices Organizados*: el sistema de **memoria y
> conocimiento** del proyecto (**sin RAG** — bóveda-wiki Obsidian estilo Karpathy + 4 Salas federadas).
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
| `investigacion:<slug>` | **Sala A · Investigación** | Una nota atómica del wiki | `01-Vault Obsidian/<NombreBoveda>/wiki/` | `01-Vault Obsidian/<NombreBoveda>/index.md` |
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

---

## Cómo amoldar esto a tu proyecto (sin perder el sentido)

- **Puedes renombrar los prefijos** al vocabulario de tu dominio (p. ej. `activo:` → `herramienta:`,
  `norma:` → `regla:`), **una sola vez y al inicio**, actualizando esta tabla.
- **No puedes** fusionar dos salas en una, copiar datos entre salas, ni dar a un prefijo dos almacenes.
- El **sentido de cada sala** (qué tipo de conocimiento guarda y por qué vive separada) está en el
  `LEEME - Esquema` dentro de cada carpeta. Léelo antes de usarla por primera vez.
