<!-- sabio-generacion: 1 -->
<!-- sabio:canonico:inicio — NO edites entre estos marcadores: la convergencia del Kit re-proyecta el esquema. Tu perfil de aplicabilidad y notas locales van DEBAJO del cierre. -->
# Sala C — Referencia externa (esquema)

> **Para qué existe esta sala:** guardar los **estándares, normativas, taxonomías o marcos oficiales**
> de los que el proyecto *deriva* o con los que *cumple*. Es conocimiento **semi-estático que tú no
> escribes: lo ingieres de una fuente oficial**. NO va en la bóveda (Sala A) porque su volumen y su
> naturaleza (texto ajeno, no curado por ti) romperían el wiki.
>
> *(Salas A–D = tipos de conocimiento; no confundir con Capa 1/2 = arquitectura del sistema.)*

## Cuándo empezar a usarla

Cuando el proyecto adopte su **primer marco externo** (una norma, una API oficial, una taxonomía,
un reglamento). Hasta entonces, puede quedar vacía: ya está reservada y con esquema.

## Estructura

```
03-Referencia/
├── LEEME - Esquema Sala C.md    (este archivo)
├── index.md                     (1 línea por entrada: - norma:<marco>:<codigo> — título)
├── fuentes/                     (el documento ORIGINAL, inmutable — como raw/ en la bóveda)
└── registros/                   (una entrada .md por ítem del marco que el proyecto usa)
```

## Esquema de una entrada (`registros/<marco>-<codigo>.md`)

```yaml
---
id: norma:<marco>:<codigo>   # ej. norma:iso27001:A.5.1 — estable, no se renombra
ambito: universal            # universal | jurisdiccion | sector  (al promover, determina quién lo resuelve)
jurisdiccion: ""             # ISO 3166-1 (CL, ES…) — solo si ambito=jurisdiccion
sector: ""                   # slug del rubro (finanzas, salud…) — solo si ambito=sector
marco: ""                    # nombre del estándar/framework
titulo: ""
fuente_oficial: ""           # URL oficial o ruta dentro de fuentes/
version_fuente: ""           # edición/año del estándar
ingerido: AAAA-MM-DD
---

Extracto o resumen FIEL de la entrada (citando la fuente). Sin interpretación propia:
la interpretación va en la Sala A (investigación) referenciando este ID.
```

## Reglas

1. **Solo fuente oficial citada.** Nunca inventar ni "recordar" contenido normativo: si no está en
   `fuentes/` o en la URL oficial, no existe. (Anti-alucinación: igual que `raw/` en la bóveda.)
2. **`fuentes/` es inmutable:** el original se deposita y no se edita jamás.
3. **Tu opinión no va aquí:** el análisis o postura del proyecto sobre una norma es una nota de la
   Sala A que referencia `norma:<marco>:<codigo>`.
4. **Amoldar sin perder el sentido:** el prefijo puede ser `regla:`, `estandar:`, lo que tu dominio
   pida; lo que define a esta sala es: **externo, oficial, inmutable, ingerido — nunca redactado**.
5. **Local vs global (cuándo promover) — criterio NO geográfico:** lo **propio de este proyecto** (corpus
   computado/derivado, regulación que solo este proyecto usa) se queda **local**; lo **oficial, público,
   inmutable y no confidencial** que toque a **más de un proyecto** se promueve al **plano global** (Centro
   de Mando) vía `/sabio-promover`. La legislación de **aplicación general** de tu jurisdicción es transversal,
   no "local por nacional". Al promover, etiqueta el **`ambito:`** (`universal`/`jurisdiccion`/`sector`); la
   flota la resuelve por su **perfil de aplicabilidad** (`CLAUDE.md` del proyecto). Una sola Sala C global
   por etiqueta, **nunca una por país**. Criterio canónico: el `LEEME - Esquema Sala C.md` del Centro (vía
   `sabio-shared`).
<!-- sabio:canonico:fin -->

---

## Perfil de aplicabilidad de este proyecto (LOCAL — tuyo)

> Esta sección es **tuya**: la convergencia **no la toca**. Declara aquí qué resuelve este proyecto del
> plano global de Sala C — `jurisdiccion:` (ISO-3166, p. ej. `CL`) y/o `sector:` (slug) — además de lo
> `universal`. El esquema canónico de arriba describe la **forma**; esto describe **tu alcance**.
