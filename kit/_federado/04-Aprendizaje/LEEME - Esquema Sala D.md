<!-- sabio-generacion: 2 -->
# Sala D — Aprendizaje operativo (esquema)

> **Para qué existe esta sala:** capturar lo que el sistema **aprende al construirse o al ejecutarse**
> — errores, técnicas nuevas, resultados, lagunas — para **no repetir errores** y **no alucinar**. Un
> registro **nace sin confianza** (`verificado: false`) y solo se vuelve conocimiento si pasa el **bucle
> de promoción**. NO va en la bóveda (Sala A): mezclaría registros crudos con investigación curada.
>
> *(Salas A–D = tipos de conocimiento; no confundir con Capa 1/2 = arquitectura del sistema.)*

## Dos productores (quién escribe)

1. **Mientras construimos** (`origen: construccion`) — Claude o el humano dejan el *gotcha*, el error
   resuelto o el mejor camino para una prueba, vía `/sabio-aprender`. Baja frecuencia, intencional.
2. **Operación agéntica** (`origen: operacion-agentica`) — un agente-software registra qué funcionó y
   qué no al ejecutar. Alta frecuencia, automática. **Solo en proyectos con el perfil agéntico** (abajo).

## Dos planos (dónde vive)

La **captura es siempre local** (la Sala D del proyecto; nunca cruza a otro — aislamiento Capa 1). Lo
**transversal** se **promueve** a la Sala D **global** del Centro de Mando, consultable read-only por la
flota vía `sabio-shared` — igual que la Sala C. «Global» es solo el **destino de la promoción**.

## Una sola forma física, un flag de comportamiento

**Todos los proyectos llevan la MISMA estructura en disco** (el superconjunto: `ESQUEMA.md` +
`tools/validar-aprendizaje.py` están presentes en **todos**). El **perfil ya no es otra forma física**:
es un **flag de comportamiento** que decide qué se **activa**, no qué archivos existen. Así la federación
nunca se fragmenta y la Sala D es homogénea en toda la flota.

| Aspecto | **base** (flag por defecto) | **agentico** (flag activo) |
|---|---|---|
| Productores que CORREN | ① `/sabio-aprender` | ① `/sabio-aprender` **+** ② runtime de agentes |
| Confianza | cualitativa (`baja/media/alta`) | numérica `0.0–1.0` + umbral (0.8) |
| Promoción | manual (`/sabio-promover`) | gobernada por umbral (ver `ESQUEMA.md`) |
| Validador (`tools/`) | presente, **inerte** (se corre a mano si quieres) | activo (integridad forzada + `_index.json`) |
| Para | docs, apps, proyectos sin agentes | flotas de agentes/skills/plugins |

**Se declara** con una línea en el `CLAUDE.md` del proyecto: `Perfil Sala D: base | agentico` (default
**base**). El `ESQUEMA.md` y el validador **vienen en todos los proyectos**; el flag agéntico solo
**activa** el productor-runtime + el umbral. **Sube el flag a agéntico** cuando el proyecto vaya a
ejecutar agentes/skills/plugins en bucle.

## Estructura

```
04-Aprendizaje/
├── LEEME - Esquema Sala D.md     (este archivo)
├── ESQUEMA.md                    (formato extendido del registro; estándar en TODOS)
├── tools/validar-aprendizaje.py  (validador de integridad; inerte salvo flag agéntico)
├── promociones/                  (buzón de salida hacia el plano global)
└── registros/                    (append-only: un .md por registro; solo avanza `estado:`)
```

## El núcleo (campos comunes a ambos perfiles)

```yaml
---
id: aprendizaje:<id>          # prefijo del espinazo (ver el índice de índices)
fecha: AAAA-MM-DD
agente: ""                    # quién/qué lo generó (Claude, humano, o agente:<id>)
origen: construccion          # construccion | operacion-agentica
contexto: ""                  # la tarea que se construía o ejecutaba
tipo: tecnica                 # error | tecnica | resultado | laguna
relacionado: []               # IDs de otras Salas (se referencian, nunca se copian)
confianza: media              # base: baja|media|alta · agéntico: 0.0–1.0
verificado: false             # SIEMPRE nace en false
estado: pendiente             # pendiente | revisado | promovido | descartado
promovido_a: ""               # ID destino si se gradúa
---

Qué se intentó, qué pasó y por qué vale como aprendizaje. Hechos, no opiniones.
```

> **Campos extendidos (flag agéntico):** `resultado`, `reclama_novedad`, campos de revisión/promoción,
> `sintetico`, y confianza numérica. La especificación completa (con la gobernanza por umbral) vive en
> **`ESQUEMA.md`**, que está **en todos los proyectos**; sus campos se llenan cuando el flag agéntico está activo.

## Máquina de estados (solo hacia adelante; append-only)

```
pendiente ──triage──▶ revisado ──aprobación──▶ promovido
    │                     │
    └──────triage─────────┴──▶ descartado (motivo obligatorio)
```

## El bucle de promoción (lo que separa "logs" de "auto-aprendizaje")

1. **Captura:** automática si la produce un agente (`operacion-agentica`), asistida/manual al construir
   (`construccion`, vía `/sabio-aprender`). Nace como hipótesis (`verificado: false`, `estado: pendiente`).
2. **Triage:** un humano o un agente de mayor confianza deduplica y aplica la **puerta anti-alucinación**
   → `revisado` o `descartado` (con motivo). En el perfil agéntico el validador + el umbral lo gobiernan.
3. **Promoción:** un registro validado se gradúa a UNA de: mejora de ficha B (v+1 con procedencia) ·
   ficha B nueva · nota de investigación A · relación con una norma C. Se anota en `promovido_a:`.
4. **Feedback:** la próxima ejecución/construcción usa el activo mejorado. El bucle se cierra.

## Anti-alucinación (el objetivo del sistema)

- Una captura **nace** `verificado: false`. La confianza auto-reportada **no** es verificación.
- Si un registro **reclama una novedad** (perfil agéntico: `reclama_novedad: true`), el triage comprueba
  contra el catálogo que **no exista ya** — el caso típico de alucinación es "redescubrir lo que ya está".
- Descartar **no es perder**: el registro queda como evidencia de qué alucina el productor.

## Gobernanza (no negociable)

1. **Un aprendizaje NUNCA modifica una ficha B automáticamente** sin pasar el triage (evita la
   auto-degradación por aprendizajes erróneos).
2. **Append-only:** los registros no se editan ni borran (solo su `estado:` avanza). Git = reversible.
3. **Federación por ID:** `relacionado:` referencia otras Salas; nunca copia. El validador del perfil
   agéntico lo **fuerza**: una referencia rota = registro inválido.
4. **Cuándo empezar:** desde el primer día de construcción (`construccion`); el productor agéntico se
   activa con el perfil agéntico, cuando haya agentes ejecutando.
