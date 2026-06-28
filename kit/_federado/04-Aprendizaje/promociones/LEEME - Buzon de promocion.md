<!-- sabio-generacion: 1 -->
# Buzón de promoción — el canal de salida hacia el plano global

> **Qué es:** la **bandeja de salida** de este proyecto hacia el conocimiento global de la flota.
> Cuando `/sabio-promover` decide que un aprendizaje es **transversal**, deja aquí un **paquete**
> (`<id>.md`, `estado: pendiente`). El Centro de Mando lo **descubre solo** y lo materializa.

## Reglas del buzón (no negociables)

1. **El CDM lee SOLO esta carpeta.** Por aislamiento (Capa 1), el materializador del Centro de Mando
   puede leer `promociones/` y **ninguna otra carpeta** de este proyecto (ni la bóveda, ni las demás
   Salas, ni el código). Esta carpeta es un canal que el proyecto **llena a propósito**.
2. **Embeber, NO apuntar.** Cada paquete debe ser **autocontenido**: el frontmatter completo **+ el
   cuerpo íntegro** de cada ficha, copiados **dentro** del `.md`. Nunca «Fuente del contenido:
   `…/registros/`» ni una lista de rutas — un paquete que **apunta** es **immaterializable** (el CDM
   no puede abrir esa otra carpeta). Para una norma (`norma:`) copia el articulado completo; la URL
   oficial se cita **además** del texto, no en su lugar.
3. **Chequeo de cierre:** «¿un materializador que SOLO lee este `.md` reconstruye cada ficha sin abrir
   otra carpeta?» Si no, está incompleto.
4. **Máquina de estados (solo avanza):** `pendiente` → `federado-global` (con el ID estable que asigna
   el Centro). Append-only; el auto-cierre de `/sabio-promover` (§5) lo avanza sin viaje manual del ID.

> Lo consume **`/sabio-promover-buzon`** desde el Centro de Mando (escanea la flota, lista, el humano
> elige, materializa solo lo global). Detalle del contrato en el comando `/sabio-promover` (§4).
