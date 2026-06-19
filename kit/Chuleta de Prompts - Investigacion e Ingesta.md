# 🗂️ Chuleta de Prompts — Investigación e Ingesta (Capa 2)

> Prompts listos para **copiar y pegar** que pueblan tu bóveda sin que tengas que subir
> documentos uno a uno. Cambia lo que está entre `<...>` por lo tuyo y envíalo.
> Úsala **dentro del proyecto** cuya bóveda quieres poblar (el aislamiento es lo que mantiene
> separadas las investigaciones de cada proyecto).

---

## ⭐ Reglas de oro

1. **Tú diriges temas; Claude investiga y compila.** No seas el recolector de PDFs.
2. **En lote, no de uno en uno.** Acumula y procesa en tandas.
3. **Siempre dentro del proyecto.** Cada proyecto trabaja SU propia bóveda.

---

## 1) 🌐 Investigar por web (sin subir nada) — modo por defecto

**A. Investigar un tema y compilarlo**
```
Investiga a fondo el tema «<TU TEMA>» en la web. Cruza varias fuentes, verifica
cifras y atribuciones (marca lo dudoso), y compílalo como notas atómicas en el wiki
según el esquema del CLAUDE.md de la bóveda (50–300 palabras, frontmatter, enlaces
tipados y ## Fuentes). Actualiza index.md y log.md. Si una fuente no lo respalda, no
lo afirmes.
```

**B. Varios temas de una sola vez (lote)**
```
Investiga estos temas y compílalos al wiki, una tanda de notas por tema, deduplicando
contra index.md:
- <tema 1>
- <tema 2>
- <tema 3>
Verifica fuentes, marca lo dudoso, y registra la ingesta en log.md.
```

**C. Pregunta puntual / verificar un dato**
```
Verifica en la web si «<AFIRMACIÓN O DATO>» es correcto. Dame la respuesta con sus
fuentes y, si procede, crea o actualiza la nota correspondiente en el wiki.
```

**D. Investigación profunda (tema grande, varios ángulos)**
```
Haz una investigación profunda de «<TU TEMA>»: varios ángulos, contrasta fuentes y
refuta lo que no se sostenga. Entrégame un resumen con citas y luego compílalo al wiki.
```
*(Para esto puedes apoyarte en la skill `deep-research`.)*

---

## 2) 📥 Ingerir documentos que ya tienes (por lote)

**A. Compilar TODO lo que soltaste en `raw/`**
```
Compila TODO lo nuevo de raw/ al wiki. Procesa en lote, deduplica contra index.md
(no repitas notas existentes) y deja la bitácora en log.md.
```

**B. Desde URLs pegadas (sin descargar nada)**
```
Abre estas URLs, extrae lo relevante y compílalo al wiki como notas atómicas con sus
fuentes:
- <url 1>
- <url 2>
```

**C. Un archivo o fuente concreta**
```
Lee «<nombre del archivo en raw/>», extrae los conceptos/hechos clave y crea las notas
atómicas enlazadas en el wiki. Cita la fuente.
```

> 💡 A `raw/` (o pegado en el chat) le sirve igual: **URLs, enlaces/transcripciones de
> YouTube, texto suelto, capturas, PDF, .md, .docx, .xlsx.** No hace falta «subir» nada formal.

---

## 3) 📝 Cola de pendientes (acumula entre semana, procesa en tandas)

**Crear / llenar la cola**
```
Crea (o abre) raw/_pendientes.md y añade esta entrada con la fecha:
- <url o tema> — <nota de qué me interesa de aquí>
```

**Procesar la cola de golpe**
```
Toma cada enlace/tema de raw/_pendientes.md, investígalo, compílalo al wiki y marca
como hecho (✓) lo ya procesado. Registra todo en log.md.
```

---

## 4) 🔎 Consultar el wiki (recuperar lo guardado)

```
Busca en el wiki qué dijimos sobre «<TEMA>» y resúmemelo con enlaces a las notas.
```
```
Dame un mapa del tema «<TEMA>»: nota central, notas relacionadas y qué fuentes lo apoyan.
```
```
¿Qué huecos o preguntas abiertas hay en el wiki sobre «<TEMA>»?
```

---

## 5) 🩺 Mantenimiento (salud del grafo)

```
Revisa la salud del wiki: enlaces rotos, notas huérfanas, frontmatter incompleto y
duplicados. Propón arreglos antes de aplicarlos.
```
```
Reconstruye index.md a partir de las notas actuales del wiki (1 línea por nota).
```
```
Arregla los enlaces rotos que encuentres y deja constancia en log.md.
```

---

## 🛠️ Cómo personalizar esta chuleta

- Sustituye `<TU TEMA>`, `<url>`, `<AFIRMACIÓN>` por lo tuyo.
- Si tu bóveda tiene otro nombre o reglas, manda igualmente el prompt: Claude lee el
  `CLAUDE.md` de la bóveda y se ajusta al esquema de ESE proyecto.
- Empieza por el **bloque 1** (investigar por web). Es el que más tiempo te ahorra.
