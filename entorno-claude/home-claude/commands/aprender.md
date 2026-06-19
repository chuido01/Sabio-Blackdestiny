---
description: Captura un aprendizaje en la Sala D local (puerta de ENTRADA, ligera). Complementa a /promover (la salida) — /aprender solo registra; /promover tria y gradúa. Escribe append-only con origen:construccion, estado:pendiente. Mecánico.
argument-hint: [aprendizaje en texto libre | --sesion (destila lo aprendido en esta sesión)]
model: haiku
---

Suelta un aprendizaje al **buzón local** (Sala D) sin disparar el triaje. Es la **puerta de entrada**
del volante de aprendizaje; la de salida es `/promover`. **Captura ≠ triaje:** aquí solo se registra
como hipótesis, nace sin confianza, y el ascenso lo decide después el triaje.

## 1. Identificar el aprendizaje ("$ARGUMENTS")
- **Texto libre** → ese es el aprendizaje.
- **`--sesion`** (o sin argumento) → revisa lo trabajado en la sesión y destila **1 aprendizaje
  concreto**: un *gotcha*, un error ya resuelto, o el mejor camino para una prueba. Si hay varios,
  captura el más reutilizable y menciona el resto.
- Redacta **hechos, no opiniones**. Si no hay nada que de verdad valga la pena, **dilo y no escribas
  ruido** (la Sala D no es una bitácora).

## 2. Localizar la Sala D del proyecto ACTIVO (captura siempre local)
Escribe en `04-Recursos/04-Aprendizaje/registros/` del **proyecto en curso**. **Nunca** en otro
proyecto ni en el plano global (eso es trabajo de `/promover` desde el Centro de Mando). Respeta el
aislamiento (Capa 1).

## 3. Escribir UN registro (append-only)
Nombre del archivo: `<AAAAMMDD-HHMMSS>-<slug>.md` (hora actual; en Windows
`Get-Date -Format yyyyMMdd-HHmmss`). Frontmatter según el esquema de la Sala D:

```yaml
---
id: aprendizaje:<AAAAMMDD-HHMMSS>-<slug>
fecha: <AAAA-MM-DD>
agente: "<quién lo generó: Claude/modelo o el humano>"
origen: construccion          # este comando captura SIEMPRE construccion
contexto: "<la tarea que se construía>"
tipo: <error | tecnica | resultado | laguna>
relacionado: [<IDs de otras salas si aplica, p. ej. activo:...>]
confianza: <baja | media | alta>   # auto-reportada, honesta
verificado: false             # SIEMPRE nace en false
estado: pendiente
promovido_a: ""
---

<Qué se intentó, qué pasó y por qué vale como aprendizaje. Breve y concreto.>
```

> El otro productor, `origen: operacion-agentica`, **NO lo usa este comando**: ese registro lo escribe
> el propio agente-software del proyecto al ejecutar (ver `LEEME - Esquema Sala D.md`).

**Según el perfil del proyecto** (línea `Perfil Sala D:` en su `CLAUDE.md`):
- **base** (o ausente) → el frontmatter de arriba, con confianza cualitativa (`baja/media/alta`).
- **agentico** → el frontmatter **extendido** de `04-Recursos/04-Aprendizaje/ESQUEMA.md` (confianza
  numérica `0.0–1.0`, `resultado`, `reclama_novedad`, campos de revisión/promoción en `null`,
  `sintetico: false`); nombra el archivo `apr-AAAAMMDD-NNN.md`. Tras escribir, puedes validar con
  `python 04-Recursos/04-Aprendizaje/tools/validar-aprendizaje.py`.

## 4. Reportar (no triar)
Devuelve el `aprendizaje:<id>` creado y recuerda: queda **`pendiente`**; para graduarlo, más tarde
`/promover --recientes`. **No** modifiques fichas, **no** promuevas nada y **no** verifiques aquí.

## Reglas (no negociables)
- **Append-only:** no edites ni borres registros; solo creas uno nuevo.
- **Local:** captura en la Sala D del proyecto activo; nunca cruza a otro proyecto ni al plano global.
- **Sin confianza:** nace `verificado: false`, `estado: pendiente`. El ascenso es del triaje, no de aquí.
- **Sin ruido:** si no hay aprendizaje real, no escribas nada.
