---
description: Promueve un aprendizaje al plano global — el volante de replicación de SABIO. El triaje lo hace el agente sabio-curator (captura en Sala D, decide la Sala dueña, prepara el candidato genérico) y se consuma en el Centro de Mando o se deja listo desde otro proyecto, respetando el aislamiento. Model Opus.
argument-hint: [lección libre | aprendizaje:<id> | --recientes]
model: opus
---

Mueve el **volante de replicación** de SABIO: convierte un aprendizaje en conocimiento que el resto
de la plataforma puede heredar. **Delega el triaje en el agente `sabio-curator`** (Opus).

## 1. Identificar la lección ("$ARGUMENTS")
- Texto libre → un aprendizaje nuevo.
- `aprendizaje:<id>` → cargar uno existente de la Sala D.
- `--recientes` → revisar los últimos registros de la Sala D (`04-Recursos/04-Aprendizaje/registros/`) y/o lo aprendido en la sesión, y elegir.

## 2. Capturar en la Sala D (local, si aún no existe)
Registra el aprendizaje como `aprendizaje:<id>` (append-only) en la Sala D del **proyecto actual**. La captura es **siempre local**.

## 3. Triar — delega en el agente `sabio-curator` (Task)
Que decida, leyendo primero el índice de índices del proyecto y (si está el MCP `sabio-shared`) el plano global:
- ¿La lección es **específica del proyecto** o **genérica/transversal**?
- ¿Ya existe algo equivalente (local o global)? → fusionar en vez de duplicar.
- Antes del veredicto, **lee el `log.md` de la Sala destino** (la bitácora de decisiones), no solo su índice: verifica si este `aprendizaje:<id>` ya fue triado y respeta —o revierte **conscientemente**— una decisión previa (queda-local / fusión / descarte); no la pises en silencio.
- ¿Qué **Sala** es la dueña? (`norma:` C · `investigacion:` A · `activo:` B · `aprendizaje:` D)
- Prepara el **candidato project-neutral** (sin datos confidenciales del proyecto) con **ID propuesto** + procedencia.
- **Veredicto:** promover · fusionar con existente · quedarse local · descartar.

## 4. Consumar según DÓNDE corres (detecta la raíz)
Determina si el proyecto actual es el **Centro de Mando Sabio** (dueño del plano global) o un proyecto normal:

- **En el Centro de Mando** → tienes **escritura** sobre el plano global. Si el veredicto es *promover*:
  escribe la entrada canónica en la Sala global que corresponda (`04-Recursos/...`), asigna el **ID estable**,
  actualiza el índice de esa Sala, y reporta. Aquí también se **materializan** los paquetes traídos de otros proyectos.
  **Si el paquete es investigación de un dominio sin hogar en la Sala A**, materialízalo en la **bóveda global existente** con la clave `dominio:<slug>` + una nota-índice (MOC) — **nunca una bóveda nueva** (`sabio-shared` expone una sola); promueve la síntesis autocontenida, sin copiar wikilinks de la bóveda local de origen.
- **En otro proyecto** → el plano global es **read-only** desde aquí (vía `sabio-shared`). **No escribas** el global.
  Produce un **paquete de promoción** (candidato + Sala destino + ID propuesto + procedencia) como salida, deja el
  registro en la **Sala D local**, e indica: *"para consumar, ejecuta `/promover` en el Centro de Mando con este paquete"*.
  Nunca escribas en otro proyecto ni en el plano global automáticamente (aislamiento).

## 5. Federar de vuelta
Una vez exista el recurso en el plano global, el proyecto deja un **puntero por ID** (p.ej. `federado-global`), **nunca una copia**.

## Reglas (no negociables)
- **Confidencialidad:** solo sube al plano global lo **genérico/project-neutral**; nada confidencial del proyecto.
- **IDs estables:** no renombres un `id:` ya asignado.
- **Una fuente por capa:** un dato vive en UNA Sala; las demás lo referencian por ID (corre `/memory-lint` si dudas de la coherencia).
- **Aislamiento:** captura y triaje son locales; el único canal hacia el global es **escribir desde el Centro** o **leer vía `sabio-shared`**.

## Salida
Reporta: el `aprendizaje:<id>` capturado, el veredicto del triaje (Sala dueña / promover / fusionar / local / descartar),
el candidato genérico con su ID, y — según dónde corriste — lo **consumado en el plano global** o el **paquete listo** para consumar en el Centro de Mando, más el puntero local de federación.
