<!-- sabio-generacion: 1 -->
# ESQUEMA — Registro de aprendizaje · perfil agéntico (Sala D)

> Especificación del formato de un registro de la **Sala D** en el **perfil agéntico**. Markdown +
> frontmatter de campos planos (portables a una tabla/stream `aprendizajes` cuando llegue una BD: cada
> campo plano es una columna). El perfil **base** usa solo el núcleo (ver `LEEME - Esquema Sala D.md`);
> aquí se documentan las **extensiones** que comprueba `tools/validar-aprendizaje.py`.
>
> Derivado del sistema pionero de **05-Agentic Cybersecurity**, generalizado (sin dominio) y unificado a
> la nomenclatura «Sala».

## Identidad y nombre de archivo

- **ID (espinazo):** `aprendizaje:apr-AAAAMMDD-NNN` (secuencial por día).
- **Archivo:** `registros/apr-AAAAMMDD-NNN.md` — el id **sin** el prefijo `aprendizaje:` (porque `:` no
  es válido en nombres de archivo de Windows). El validador comprueba que `id == "aprendizaje:" + nombre`.

## Frontmatter (campos planos, vocabulario controlado)

```yaml
---
esquema: aprendizaje-operativo
version_esquema: "2.0"
id: aprendizaje:apr-20260617-001
fecha: 2026-06-17
agente: "agente:<id>"                # quién capturó (agente:<id> | humano | Claude)
origen: operacion-agentica           # operacion-agentica | construccion
contexto: "<resumen del escenario y el objetivo>"
tipo: tecnica                        # error | tecnica | resultado | laguna
resultado: exito                     # exito | fallo | parcial
reclama_novedad: false               # true si reclama una técnica/activo no catalogado
relacionado: ["activo:<slug>"]       # IDs de otras Salas — el validador verifica que existan
confianza: 0.85                      # 0.0–1.0 auto-reportada por el productor
estado: pendiente                    # pendiente | revisado | promovido | descartado
verificado: false                    # true solo tras revisión que lo confirme
# --- revisión (null hasta el triage) ---
revisado_por: null                   # humano | agente:<id> | humano+agente:<id>
revision_fecha: null
motivo_descarte: null                # OBLIGATORIO si estado: descartado
# --- promoción (null hasta promover) ---
promocion_tipo: null                 # mejora-activo | activo-nuevo | nota-investigacion | nuevo-vinculo
promocion_destino: null              # ID destino (activo:<slug> v+1 | investigacion:<slug> | norma:<...>)
promocion_commit: null               # hash del commit de la promoción (reversibilidad)
sintetico: false                     # true SOLO en ejemplos de esquema (se excluyen de métricas)
---

<Cuerpo libre: qué se intentó, pasos/comandos, salidas, decisiones. Lo que el triage necesita para verificar.>
```

## Máquina de estados (solo hacia adelante; append-only)

```
pendiente ──triage──▶ revisado ──aprobación──▶ promovido
    │                     │
    └──────triage─────────┴──▶ descartado (motivo_descarte obligatorio)
```

| Transición | Quién puede | Requisitos que valida la herramienta |
|---|---|---|
| → `revisado` | agente de confianza o humano | `revisado_por` y `revision_fecha` no nulos |
| → `descartado` | agente de confianza o humano | + `motivo_descarte` no nulo |
| → `promovido` que **toca un activo** (`mejora-activo` / `activo-nuevo`) | **solo humano** | `revisado_por` incluye `humano`; `promocion_tipo/destino` no nulos |
| → `promovido` que **no toca activos** (`nota-investigacion` / `nuevo-vinculo`) | agente si `confianza ≥ umbral`; si no, humano | si aprueba agente solo: `confianza ≥ umbral` |

**Umbral de confianza: `0.8`** (constante del validador; configurable a futuro).

## Destinos de promoción (el aprendizaje se gradúa a UNO)

| `promocion_tipo` | Destino | Efecto |
|---|---|---|
| `mejora-activo` | **Sala B** — parche a una ficha | version+1 + procedencia `aprendizaje:<id>` |
| `activo-nuevo` | **Sala B** — ficha nueva | propuesta completa de activo |
| `nota-investigacion` | **Sala A** — bóveda | nota atómica vía el flujo de ingesta normal |
| `nuevo-vinculo` | **Sala C** — referencia | relación nueva con una norma/estándar canónico |

## Anti-alucinación (heredada del núcleo)

- Un registro **nace** `verificado: false`. La confianza auto-reportada del productor **no** es verificación.
- `reclama_novedad: true` exige que el triage compruebe contra el catálogo (Sala B/C según el índice de
  índices) que lo reclamado **no exista ya** — el caso típico de alucinación es "redescubrir lo que ya está".
- Si el triage no puede reproducir/confirmar la observación → `descartado` con motivo. Descartar no pierde:
  el registro queda como evidencia de qué alucina el productor.

## Integridad referencial (la fuerza el validador)

Cada ID en `relacionado:` debe **existir en su Sala dueña** según el índice de índices: `activo:`→Sala B ·
`investigacion:`→Sala A · `norma:`→Sala C · `aprendizaje:`→Sala D. Una referencia rota = **registro
inválido** (el validador sale con código de error). Así se cumple «una fuente por capa, referenciada por
ID, nunca copiada». Si una Sala destino aún no existe en el proyecto, la referencia se reporta como
**aviso** (no error), para no bloquear proyectos en construcción.

## `sintetico: true`

Registros de ejemplo para **validar el esquema** sin contaminar las métricas ni el conocimiento real: se
excluyen de los totales de `_index.json` y **jamás** se promueven.
