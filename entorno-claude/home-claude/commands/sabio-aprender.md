---
description: Captura un aprendizaje en la Sala D local (la ÚNICA puerta de entrada del volante). Por defecto mecánico (lo que dictas o lo de la sesión); con --reflexivo delega en el agente sabio-reflector (Opus) que exige feedback externo e infiere la CAUSA. Append-only, estado:pendiente. La salida es /sabio-promover.
argument-hint: [texto libre | --sesion] [--reflexivo]
model: haiku
---

Suelta un aprendizaje al **buzón local** (Sala D) sin disparar el triaje. Es la **única puerta de entrada**
del volante de aprendizaje; la de salida es `/sabio-promover`. **Captura ≠ triaje:** aquí solo se registra
como hipótesis (`verificado:false`, `estado:pendiente`); el ascenso lo decide el triaje.

## Dos modos, un solo verbo
- **Mecánico (por defecto):** captura directa de lo que dictas o lo que destila la sesión. Rápido, sin
  análisis causal. Es el caso común.
- **`--reflexivo`:** para trabajo **no trivial con feedback externo** real (un test, una ejecución/error,
  tu reacción, el artefacto). Delega en el agente **`sabio-reflector`** (Opus), que **infiere la causa**
  (no el síntoma) antes de escribir. *(Antes era el comando `/sabio-reflector`; ahora es este modo.)*

## 1. Identificar el aprendizaje ("$ARGUMENTS")
- **Texto libre** → ese es el aprendizaje (o el contexto a reflexionar, si `--reflexivo`).
- **`--sesion`** (o sin argumento) → destila **1 aprendizaje concreto** de la sesión: un *gotcha*, un error
  ya resuelto, o el mejor camino para una prueba. Si hay varios, captura el más reutilizable y menciona el resto.
- Redacta **hechos, no opiniones**. Si no hay nada que valga, **dilo y no escribas ruido** (la Sala D no es bitácora).

## 2. Producir el registro según el modo (captura SIEMPRE local)
Escribe en `04-Recursos/04-Aprendizaje/registros/` del **proyecto en curso**. **Nunca** en otro proyecto ni
en el plano global (eso es `/sabio-promover` desde el Centro). Aislamiento (Capa 1).
- **Mecánico:** redacta y escribe el registro (§3) tú mismo.
- **`--reflexivo`:** lanza el agente `sabio-reflector` (Task) con el contexto + **qué feedback externo hay**
  (salida de test, ejecución, verificación adversarial, tu reacción, el artefacto). Que siga su protocolo:
  **exigir feedback externo** (sin señal verificable, no afirma corrección), **inferir la causa**, **acotado**
  (1-2 pasadas, sin bucles), **chequear novedad** contra el índice y los registros (si choca, enlazar
  `#contradice`), y **escribir UN candidato** con el formato de §3.

## 3. El registro (append-only)
Nombre: `<AAAAMMDD-HHMMSS>-<slug>.md` (`Get-Date -Format yyyyMMdd-HHmmss`). Frontmatter del esquema Sala D:

```yaml
---
id: aprendizaje:<AAAAMMDD-HHMMSS>-<slug>
fecha: <AAAA-MM-DD>
agente: "<Claude/modelo, humano, o agente:<id>>"
origen: construccion          # este comando captura SIEMPRE construccion
contexto: "<la tarea que se construía>"
tipo: <error | tecnica | resultado | laguna>
relacionado: [<IDs de otras salas si aplica>]
confianza: <baja | media | alta>   # auto-reportada, honesta
verificado: false             # SIEMPRE nace en false
estado: pendiente
promovido_a: ""
---

<Qué se intentó, qué pasó y por qué vale. En --reflexivo: la CAUSA y el feedback externo que la respalda.>
```

> El otro productor, `origen: operacion-agentica`, lo escribe el agente-software del proyecto al ejecutar
> (no este comando). La forma exacta de la Sala D vive en su `LEEME - Esquema Sala D.md`.

## 4. Reportar (no triar)
Devuelve el `aprendizaje:<id>` creado (o «sin aprendizaje real, no escribí nada»); en `--reflexivo`, qué
feedback externo lo respalda. Queda **`pendiente`**; para graduarlo, `/sabio-promover`. **No** triar,
promover ni verificar aquí.

## Reglas (no negociables)
- **Append-only · local:** solo creas un registro nuevo, en la Sala D del proyecto activo; nunca cruza a otro proyecto ni al global.
- **Sin confianza:** nace `verificado:false`, `estado:pendiente`. El ascenso es del triaje.
- **`--reflexivo` exige feedback externo:** sin señal verificable fuera del propio juicio, no afirma corrección (captura como hipótesis o no captura).
- **Sin ruido:** si no hay aprendizaje real, no escribas nada.
