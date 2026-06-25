---
description: Reflexiona sobre un trabajo recién cerrado y deja el aprendizaje en la Sala D — el hermano "inteligente" de /aprender. Delega en el agente sabio-reflector (Opus): exige feedback externo, infiere la CAUSA, chequea novedad y escribe UN candidato verificado:false. Captura local; la salida sigue siendo /promover.
argument-hint: [contexto del trabajo cerrado | --sesion (reflexiona sobre esta sesión)]
model: opus
---

Dispara el patrón **Reflector** de SABIO sobre un trabajo **ya cerrado**. Es el hermano *inteligente* de
`/aprender`: aquél captura mecánicamente lo que tú dictas; **`/sabio-reflector`** mira atrás con el
**feedback externo** en la mano, **infiere la causa** (no el síntoma) y destila el aprendizaje antes de
guardarlo. **Captura ≠ triaje:** deja una hipótesis (`verificado:false`); el ascenso lo decide después
`/promover`.

## 1. Identificar sobre qué reflexionar ("$ARGUMENTS")
- **Texto libre** → ese es el contexto del trabajo cerrado a reflexionar.
- **`--sesion`** (o sin argumento) → reflexiona sobre lo trabajado en esta sesión.

## 2. Delegar en el agente `sabio-reflector` (Task)
Lánzalo con el contexto del trabajo + **qué feedback externo hay disponible** (salida de un test,
ejecución/error, verificación adversarial, tu reacción, el artefacto real). Que siga su protocolo:
- **Exigir feedback externo.** Sin una señal verificable fuera de su propio juicio, **no afirma
  corrección** — captura como hipótesis sin verificar, o no captura.
- **Inferir la causa**, no el síntoma. Hechos, no opiniones.
- **Acotado:** solo tareas no triviales, 1-2 pasadas, sin bucles (proporción).
- **Chequear novedad** contra el índice de índices y los registros de la Sala D — no redescubrir lo ya
  capturado; si choca, enlazar con `#contradice`.
- **Escribir UN candidato** append-only en `04-Recursos/04-Aprendizaje/registros/` del proyecto activo
  (`verificado:false`, `estado:pendiente`), según el perfil de la Sala D (`base` | `agentico`).

## 3. Reportar (no triar)
Devuelve el `aprendizaje:<id>` creado (o "sin aprendizaje real, no escribí nada"), qué **feedback
externo** lo respalda, y recuerda: queda **`pendiente`**; para graduarlo, `/promover`.

## Reglas (no negociables)
- **Local:** captura en la Sala D del proyecto activo; **nunca** cruza a otro proyecto ni al plano global.
- **Nunca auto-promueve** ni modifica fichas (B) ni notas (A): el ascenso es del triaje (`/promover`).
- **Sin feedback externo no hay afirmación de corrección** — la confianza auto-reportada no es verificación.
- **Sin ruido:** si no hay aprendizaje real, no escribas nada (la Sala D no es bitácora).
