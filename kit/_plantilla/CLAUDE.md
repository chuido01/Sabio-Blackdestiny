# <NombreBoveda> — Esquema del Wiki LLM (Capa 2)

> **Qué es esto:** las reglas maestras (el "córtex frontal") que sigue Claude Code para
> ingerir fuentes, redactar notas atómicas, enlazarlas y mantener este wiki.
> Patrón base: **«LLM Wiki» de Andrej Karpathy** (Markdown local, SIN RAG vectorial) +
> una **capa de tipado ligera** (estilo Infinite Brain).
> Plataforma: Claude Code + Obsidian · Volumen objetivo: < 2.000 págs.

---

## 1. Propósito del sistema

Esta es la **base de conocimiento persistente (Capa 2)** de **este proyecto**. Su objetivo es
acumular investigación de forma que **crezca como interés compuesto**: cada fuente nueva no se
pierde, se integra al cuerpo existente y lo hace más valioso. Claude actúa como **bibliotecario**:
lee `raw/`, extrae conceptos y los compila en notas atómicas en `wiki/`.

Es **independiente** de la Capa 1 (gestión de contexto nativa de Claude Code). Aquí NO se arreglan
los dolores operativos del día a día; aquí se construye conocimiento navegable a largo plazo.

> Decisión de arquitectura: **NO RAG vectorial**. A este volumen basta un `index.md` leído por el
> LLM. No hay embeddings ni chunking. (Si algún día superas ~2.000 págs, reevalúa esta decisión.)

> **Rol en el conocimiento federado:** esta bóveda es la **Sala A (investigación curada)** del
> proyecto. Catálogos de activos, referencia externa voluminosa y telemetría de agentes **no van
> aquí**: pertenecen a las salas B/C/D de `04-Recursos/` (ver el `00-INDICE-DE-INDICES.md` del
> proyecto). Si una nota necesita citarlos, referencia su **ID** (`activo:…`, `norma:…`,
> `aprendizaje:…`) en vez de copiar su contenido. Una bóveda «poco poblada» no está enferma:
> es una bóveda que no absorbe conocimiento que pertenece a otra sala.
> *(Salas A–D = tipos de conocimiento; Capa 1/2 = arquitectura del sistema.)*

> **Bóveda multi-dominio (solo en el plano global / hub):** la bóveda del **Centro de Mando** (no la
> de un proyecto normal) puede ser **transversal y multi-dominio**: aloja investigación de varios
> dominios promovida desde los proyectos. Un dominio externo se marca con la clave **`dominio: <slug>`**
> en el frontmatter **+ una nota-índice (MOC)** dentro de la **única** bóveda; **nunca** se crea una
> bóveda nueva por tema (`sabio-shared` expone una sola — otra quedaría invisible para la flota). En la
> bóveda **local de un proyecto** esto no aplica: es de un solo dominio y la clave `dominio:` se omite.

---

## 2. Estructura de directorios

```
<NombreBoveda>/
  raw/         # SOLO LECTURA. Fuentes originales. La IA las lee, nunca las edita ni borra.
  wiki/        # Notas atómicas tipadas e interconectadas. Las crea y mantiene la IA.
  templates/   # Plantillas de notas (consistencia visual/estructural).
  index.md     # Mapa maestro: 1 línea por nota. Se consulta ANTES de responder.
  log.md       # Registro cronológico append-only de cada operación de ingesta/linting.
  CLAUDE.md    # Este archivo: el esquema/reglas.
```

**Regla de oro de `raw/`:** todo lo que está en `raw/` es **inmutable**. Se consulta para extraer
conocimiento; **jamás** se modifica ni se borra. Es la fuente de verdad verificable.

> **Acceso (nativo):** estando dentro del proyecto, Claude edita estos `.md` **directamente** con las
> herramientas de archivo (leer/escribir/buscar/`grep`). **No se usa MCP** — no aporta valor extra
> aquí. La segmentación la garantizan el **aislamiento del proyecto** y la regla «Acceso a Obsidian»
> del `CLAUDE.md` del proyecto (la única bóveda permitida es ésta; no mezclar datos de otros proyectos).

---

## 3. Taxonomía — tipos de nota (nodos)

Cada nota de `wiki/` se clasifica en **exactamente UN** tipo. Usamos un **subconjunto pragmático**.
Si algún día hace falta otro tipo, se documenta aquí antes de usarlo.

| `tipo:` | Para qué | Ejemplo |
|---|---|---|
| `concepto` | Definición de una idea o abstracción | "Context Rot", "Gestión de contexto" |
| `hecho` | Dato objetivo, cifra o hallazgo verificado | "−39 % de rendimiento multi-turno" |
| `decision` | Elección concreta ya tomada y su porqué | "No usar RAG vectorial" |
| `hipotesis` | Suposición aún por validar | "El volumen crecerá > 2.000 págs" |
| `pregunta` | Interrogante abierto que requiere investigación | "¿Conviene el MCP de Obsidian?" |
| `fuente` | Una fuente original de `raw/` (paper, video, repo) | "Paper Lost in the Middle" |
| `referencia` | Material de apoyo / enlace externo de contexto | Gist, artículo externo |
| `nota` | Apunte general que no encaja en lo anterior | — |

---

## 4. Taxonomía — tipos de enlace (edges)

Un enlace **no** dice solo "están relacionados": define la **naturaleza lógica** de la relación,
para que la IA navegue el grafo de forma deductiva. Se escriben como tag inline junto al wikilink.

| Edge (tag) | Significado |
|---|---|
| `#apoya` | Esta nota respalda / da validez a la otra (*supports*) |
| `#contradice` | Esta nota se opone a la otra (*contradicts*) — **clave para detectar inconsistencias** |
| `#depende_de` | La otra debe ser válida/ejecutarse primero (*depends_on*) |
| `#derivado_de` | Esta nota se extrajo o concluyó a partir de la otra (*derived_from*) |
| `#parte_de` | Pertenencia jerárquica: es componente de algo mayor (*part_of*) |
| `#relacionado` | Asociación general, sin lógica más específica (*related_to*) |
| `#fuente` | Atribución a la fuente original de `raw/` (*authored / source*) |

> No inventes edges nuevos sin registrarlos antes en esta tabla.

---

## 5. Reglas de redacción de una nota atómica

1. **Una nota = un concepto.** NO crees una nota por fuente; crea una nota por cada idea, hecho o
   decisión. Una sola fuente de `raw/` puede generar 5–10 notas.
2. **Longitud atómica: 50–300 PALABRAS** (son *palabras*, no líneas). Si el tema es más extenso,
   divídelo en partes (`tema (parte 1)`, `tema (parte 2)`).
3. **Resumen de UNA frase obligatorio**, al inicio del cuerpo y en el frontmatter (`resumen:`). La
   IA lee primero ese resumen (≈ 50 tokens) y decide si profundiza. Esto es lo que ahorra tokens.
4. **Cita siempre la fuente** de `raw/` que respalda cada afirmación (sección `## Fuentes`).
5. **Distingue verificado vs inferido:** `verificado: true` solo si lo respalda una fuente primaria
   citada. Si es una inferencia de la IA, `verificado: false` y `autor: IA`.
6. **Nombre de archivo = slug en kebab-case**, en español, basado en el concepto: `context-rot.md`,
   `decision-no-rag.md`. Sin acentos ni espacios en el nombre de archivo.

### Frontmatter estándar (YAML)

```yaml
---
tipo: concepto              # uno de los tipos de la §3
resumen: "Frase única que resume la nota."
fuentes:                    # rutas dentro de raw/ (o URL si es externa)
  - "raw/<carpeta-fuente>/<documento>.md"
autor: IA                   # Humano | IA | Humano+IA
verificado: false           # true solo si hay fuente primaria citada
creado: AAAA-MM-DD
tags: [tag1, tag2]
dominio: <slug>             # OPCIONAL — solo en la bóveda multi-dominio del hub/plano global; omítela en proyectos
---
```

### Cuerpo estándar

```markdown
**Resumen:** <la misma frase del frontmatter>.

<Cuerpo de 50–300 palabras. Claro, sin relleno.>

## Enlaces
- #apoya [[otra-nota]] — por qué la apoya
- #contradice [[nota-rival]] — en qué punto choca

## Fuentes
- [[documento-fuente]] (raw/) — sección X
```

Plantilla lista para copiar: `templates/_plantilla-nota-atomica.md`.

---

## 6. Flujo de ingesta (cuando llega algo nuevo a `raw/`)

Cuando el usuario deposite una fuente en `raw/` y pida compilarla:

1. **Leer** la fuente completa para entender el contexto global.
2. **Extraer** conceptos, hechos, decisiones, hipótesis y preguntas clave.
3. **Crear o actualizar** notas en `wiki/` — **por concepto, no por fuente**. Si el concepto ya
   existe, **actualiza** la nota existente (no dupliques); añade la nueva fuente a `fuentes:`.
4. **Enlazar** las notas nuevas con las existentes usando los edges de la §4. Enlaza con generosidad:
   un `[[destino]]` a una nota que aún no existe es válido (marca algo por escribir, no un error).
5. **Actualizar** `index.md` (añadir/mover la línea de cada nota) y **añadir** una entrada a `log.md`.
6. **No tocar** los archivos de `raw/`.

> Para corpus grandes, planifica primero el **grafo completo** (lista de notas + enlaces) leyendo
> todas las fuentes, y luego redacta en paralelo. Así los enlaces quedan resueltos de entrada.

---

## 7. Comportamiento de consulta (Q&A)

- **Antes de responder, lee `index.md`** (el mapa maestro). Abre solo las notas cuyo `resumen:` sea
  relevante. NO cargues todo el wiki.
- **Cita la fuente** de `raw/` de cada afirmación. Si no hay fuente, dilo explícitamente.
- **Si hay contradicciones** entre notas (`#contradice`), **lístalas**; no las ocultes ni promedies.
- **Marca lo no verificado:** distingue hecho verificado por humano de inferencia de la IA.
- Sintetiza desde el wiki estructurado, no desde fragmentos sueltos (no es RAG).

---

## 8. Mantenimiento (linting) — pedir periódicamente

Cuando el usuario pida "lint" o "revisa la salud del wiki":

- **Notas huérfanas:** sin enlaces entrantes ni salientes → proponer enlaces o archivar.
- **Enlaces rotos:** `[[destino]]` cuyo archivo no existe → crear la nota o corregir el enlace.
- **Contradicciones:** pares `#contradice` → reportarlos para que el usuario decida.
- **Duplicados:** dos notas del mismo concepto → fusionar en una, conservando todas las `fuentes:`.
- **Lagunas:** nodos con pocas conexiones → sugerir nuevas investigaciones para `raw/`.
- **Coherencia de `index.md`:** que toda nota de `wiki/` esté en el índice y viceversa.

---

## 9. Anti-alucinación (no negociable)

- **No inventes** cifras, fechas, atribuciones ni fuentes. Si no está en `raw/`, no es un hecho.
- Si tu investigación de origen tiene errores conocidos, **documenta las correcciones** (una sección
  "⚠️ Correcciones verificadas" en la fuente de `raw/`) y **respétalas** en todas las notas.
- Ante duda entre dos fuentes, crea ambas notas y enlázalas con `#contradice`. No elijas por ti.

---

## Compact instructions
Al compactar, conserva: estas reglas de esquema (§3–§9), la ubicación de `raw/`/`wiki/`/`index.md`,
y qué fuentes ya se ingirieron (según `log.md`).
