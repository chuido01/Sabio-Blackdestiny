# Guía SABIO — en cristiano

> La puerta de entrada humana a SABIO. Explica el sistema sin tecnicismos.
> (Para todo el sistema en un solo documento, ver `resumen-consolidado.md`.)

## En una frase

**SABIO es tu memoria a largo plazo trabajando con IA:** un sitio ordenado donde cada cosa que
investigas o decides queda guardada **una sola vez**, etiquetada, y se puede volver a encontrar — sin
que un proyecto se contamine con los datos de otro.

SABIO = **S**istema de **A**rchivos, **B**óvedas e **Í**ndices **O**rganizados.

---

## 1. El problema que resuelve

La IA tiene dos olvidos y un desorden. SABIO ataca los tres.

- **Olvido 1 — Se pierde dentro del mismo chat.** En conversaciones largas la IA empieza a olvidar lo
  de arriba: la "ventana" de contexto se satura. Esto lo cuida la **Capa 1** (gestión de contexto).
- **Olvido 2 — Olvida entre sesiones.** Cierras el chat y mañana no recuerda lo que decidieron. Lo
  arregla la bóveda de conocimiento, la **Capa 2**.
- **Desorden — Se mezclaban los proyectos.** La paleta o la marca de un proyecto aparecía en otro,
  porque todo vivía junto sin frontera. Lo corta el **aislamiento** por proyecto.

**La apuesta de diseño: sin RAG.** No se usa una base de datos vectorial. A volúmenes moderados
(menos de ~2.000 páginas) basta una wiki en texto que la IA lee directamente. Es más simple y más
barato. Es el patrón "LLM Wiki" de Andrej Karpathy.

---

## 2. El mapa de SABIO (dos niveles)

**Plano global (Centro de Mando Sabio) — compartido, solo lectura.** Lo que es igual para todos vive
aquí una sola vez:
- **Sala A · Investigación (transversal):** la bóveda del Centro, hoy **multi-dominio**: además de la investigación nativa, aloja conocimiento que los proyectos **promueven** para que sirva a todos. Un dominio nuevo se marca con una **etiqueta**, no con una bóveda aparte.
- **Sala C · Referencia:** normas y estándares externos (NIST, ISO, PCI).
- **Sala D · Aprendizaje (transversal):** las lecciones genéricas que un proyecto **promueve** para
  que sirvan a todos.

**Plano local (cada proyecto) — aislado.** Lo propio de cada proyecto, dentro de su caja:
- **Sala A · Investigación:** la bóveda de notas del proyecto. *(Igual que la Sala D, la Sala A vive en los dos planos: local en cada proyecto, y transversal/multi-dominio en el Centro.)*
- **Sala B · Catálogo:** las fichas de activos del proyecto.
- **Sala D · Aprendizaje (captura):** lo que se aprende ahí mismo, al construir o al ejecutar. **La
  captura es siempre local**; solo lo transversal sube al plano global.

**La conexión solo va de arriba hacia abajo y es de solo lectura:** un proyecto puede *consultar* una
norma global (a través del MCP `sabio-shared`), pero **nunca** puede leer la bóveda de otro proyecto.
Ese es el aislamiento.

---

## 3. Las 4 Salas — los cuatro tipos de conocimiento

Cada dato es de un tipo, y por eso vive en una Sala concreta. Son como cuatro estanterías con
etiquetas distintas.

- **Sala A · Investigación** — Lo que estudias e investigas. Es la bóveda Obsidian: notas cortas (una
  idea por nota) enlazadas entre sí. La del Centro es **multi-dominio**: un dominio nuevo se añade como
  una **etiqueta** + un mapa, **nunca** como una bóveda aparte. Etiqueta: `investigacion:<tema>`.
- **Sala B · Catálogo** — Tus herramientas y activos. Fichas de lo que tienes: qué es, para qué sirve,
  qué cuesta. Etiqueta: `activo:<cosa>`.
- **Sala C · Referencia (global)** — Normas y estándares externos (NIST, ISO, PCI). Son iguales para
  todos, así que viven una sola vez en el plano global y todos los consultan. Etiqueta:
  `norma:<marco>:<código>`.
- **Sala D · Aprendizaje** — Lecciones de lo que pasó, para no repetir errores: "la próxima vez, hazlo
  así". Se llena de **dos formas**: al **construir** —con `/aprender` (rápido) o **`/sabio-reflector`** (reflexiona con feedback externo e infiere la causa)— y, en
  proyectos con agentes, **automáticamente** cuando un agente ejecuta. Etiqueta: `aprendizaje:<id>`.

> **Dos perfiles, según el proyecto.** Un proyecto de documentación usa el perfil **base** (captura
> sencilla con `/aprender`). Un proyecto con agentes usa el perfil **agéntico**, que añade un validador
> automático y mide la confianza con números. Es la **misma** Sala D; solo cambia **cuánta maquinaria**
> carga, según lo que el proyecto necesite.

---

## 4. La regla de oro: un dato, un solo hogar

Esto es lo que evita el caos. **Nada se copia.** Si dos sitios necesitan el mismo dato, uno lo
**guarda** y el otro lo **señala con su etiqueta**.

Ejemplo: la norma NIST CSF vive una sola vez en la Sala C global, con la etiqueta `norma:nist:csf`.
Los proyectos no la copian: la **señalan** por esa etiqueta. Si la norma cambia, se actualiza en un
solo sitio y todos ven el cambio.

El **"índice de índices"** (`04-Recursos/00-INDICE-DE-INDICES.md`) es el mapa que dice qué etiqueta
vive en qué Sala. Es el espinazo del sistema: con él, cualquiera que encuentre una etiqueta sabe dónde
resolverla.

---

## 5. Cómo se conectan los documentos (.md)

En el fondo, SABIO son archivos de texto que se apuntan unos a otros. El cableado real tiene dos
niveles de zoom.

### Nivel 1 — El árbol de índices (qué archivo manda sobre cuál)

La raíz de todo es `00-INDICE-DE-INDICES.md`. **No guarda datos**: solo dice qué etiqueta vive en qué
Sala. De ahí cuelga cada Sala con su propio índice:

- `00-INDICE-DE-INDICES.md` (la raíz, el espinazo)
  - **Sala A** → `index.md` (mapa: 1 línea por nota) → `wiki/` (notas .md enlazadas entre sí) ·
    `raw/` (fuentes originales) · `CLAUDE.md` (el esquema/reglas) · `log.md` (bitácora)
  - **Sala B** → `index.md` → `fichas/`
  - **Sala C** → `index.md` (plano global 🌐) → `registros/` (normas .md) · `fuentes/` (PDFs públicos)
  - **Sala D** → `LEEME - Esquema Sala D.md` (el esquema; núcleo + perfiles) → `registros/`
    (aprendizajes .md). El perfil **base** se filtra por estado; el **agéntico** añade `ESQUEMA.md`, un
    validador y un `_index.json`.

Cada `index.md` lista su contenido con una línea por documento. La IA lee el índice primero y solo
abre los documentos que necesita.

### Nivel 2 — Anatomía de una nota, y cómo enlaza con otras

Cada parte de una nota se conecta con algo:

- **Frontmatter** (la cabecera): `tipo:` la clasifica; `resumen:` la frase que la IA lee primero;
  `verificado: false` avisa de que es inferencia de la IA, no un hecho verificado; `fuentes:` apunta al
  archivo de `raw/` que la respalda.
- **Cuerpo**: 50–300 palabras, empezando por la misma frase de resumen.
- **## Enlaces**: aquí la nota apunta a OTRAS notas, diciendo *cómo* se relacionan. Por ejemplo:
  `#apoya [[otra-nota]]` (la respalda), `#relacionado [[otra]]`.
- **## Fuentes**: cita la fuente original intocable: `[[fuente-original]] (raw/)`.

**El vocabulario de los enlaces** (lo que hace el grafo navegable, en vez de un montón de notas
sueltas):

- `#apoya` — esta nota respalda a la otra.
- `#contradice` — esta nota se opone a la otra (clave para cazar inconsistencias).
- `#depende_de` — la otra debe ser válida primero.
- `#derivado_de` — esta nota se extrajo de la otra.
- `#parte_de` — es componente de algo mayor.
- `#relacionado` — asociación general, sin lógica más específica.
- `#fuente` — atribución a la fuente original de `raw/`.

---

## 6. El día a día: cómo guardas y cómo buscas

**Guardar algo nuevo:**
1. Dejas la fuente (PDF, texto, video) en la carpeta `raw/`.
2. Le pides a Claude: "compila esto al wiki".
3. Claude la lee y crea notas cortas (una idea cada una), enlazadas entre sí.
4. Actualiza el `index.md` (el mapa maestro) y registra la operación en `log.md`.

**Buscar o preguntar:**
1. Claude lee primero el `index.md` (una línea por nota).
2. Abre solo las 3–5 notas relevantes, no todo el wiki.
3. Responde citando la fuente, y avisa si algo es inferido y no verificado.
4. Así gasta pocos tokens y no se "marea" con ruido.

**Regla sagrada de `raw/`:** lo que está ahí es la fuente original y **nunca se edita ni se borra**. Es
tu verdad verificable.

---

## 7. Cómo nace un proyecto, y cómo mejora el conjunto

**El Kit — los proyectos nacen iguales.** Un proyecto nuevo se crea con un solo paso y ya viene con
SABIO puesto: las 5 carpetas, git, su regla de aislamiento, la bóveda y las 4 Salas. Es no destructivo
y repetible.

**El volante — el conocimiento se contagia.** Cuando aprendes algo que sirve a todos, el comando
`/promover` lo sube al plano global (una sola copia) y los demás lo consultan por referencia. El
comando `/memory-lint` vigila que nada se duplique entre capas.

---

## 8. Las dos confusiones, aclaradas

- **Capa 1 y Capa 2 = la arquitectura (los cimientos).** Capa 1 = aislamiento + no perderse en el
  chat. Capa 2 = la bóveda que recuerda a largo plazo.
- **Sala A–D = los tipos de conocimiento (las estanterías).** Investigación, Catálogo, Referencia,
  Aprendizaje. No confundir con las Capas.
- **Plano local** = el conocimiento de un proyecto, que no sale de su caja (Salas A y B).
- **Plano global** = el conocimiento compartido por toda la plataforma (la Sala A transversal multi-dominio + Salas C y D), de solo lectura.
- **Federar** = guardar un dato una vez y que los demás lo señalen por su etiqueta, en vez de copiarlo.
- **raw vs wiki** = `raw` son las fuentes originales intocables; `wiki` son las notas que la IA escribe
  a partir de ellas.

---

## 9. Dónde vive cada cosa (dentro de un proyecto)

- Índice de índices: `04-Recursos/00-INDICE-DE-INDICES.md`
- Sala A (bóveda): `04-Recursos/01-Vault Obsidian/<TuBoveda>/`
- Sala B (catálogo): `04-Recursos/02-Catalogo/`
- Sala C (referencia, global): `04-Recursos/03-Referencia/`
- Sala D (aprendizaje): `04-Recursos/04-Aprendizaje/`
- Reglas del esquema del wiki: `04-Recursos/01-Vault Obsidian/<TuBoveda>/CLAUDE.md`

El motor (el Kit) y el puente al plano global (el MCP `sabio-shared`) viven en el repo: ver `kit/` y
`mcp/`.
