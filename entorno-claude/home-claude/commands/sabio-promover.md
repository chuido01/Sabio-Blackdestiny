---
description: Promueve un aprendizaje LOCAL al plano global — el volante de replicación de SABIO. Triaje vía el agente sabio-curator. En un proyecto genera un paquete autocontenido en el buzón; en el CDM escribe el global. El estado de federación se DERIVA del global (no se avanza a mano). Para cosechar TODA la flota desde el CDM usa /sabio-promover-buzon. Model Opus.
argument-hint: [lección libre | aprendizaje:<id> | --recientes]
model: opus
---

Mueve el **volante de replicación**: convierte un aprendizaje **de ESTE proyecto** en conocimiento que la
plataforma hereda. **Triaje delegado en el agente `sabio-curator`** (Opus). Promueve lo del proyecto actual;
para **cosechar los buzones de toda la flota** desde el CDM, usa **`/sabio-promover-buzon`** (no este comando).

## 1. Identificar la lección ("$ARGUMENTS")
- Texto libre → un aprendizaje nuevo. · `aprendizaje:<id>` → uno existente de la Sala D. · `--recientes` → revisa los últimos registros y elige.

## 2. Capturar en la Sala D (local, si aún no existe)
Registra `aprendizaje:<id>` (append-only) en la Sala D del **proyecto actual**. La captura es **siempre local** (aislamiento Capa 1).

## 3. Triar — delega en `sabio-curator` (Task)
Que decida, leyendo el índice de índices del proyecto y —si está `sabio-shared`— el plano global:
- ¿**específico del proyecto** o **genérico/transversal**?
- ¿**ya existe en el global**? (consulta `sabio-shared`, read-only). **Esto es también el chequeo de estado derivado:** si el equivalente ya está arriba, este aprendizaje **ya está federado** → repórtalo y cierra (no re-promuevas). Si existe algo cercano → **fusionar**, no duplicar.
- Lee el `log.md` de la Sala destino (bitácora de decisiones), no solo su índice: no revivas en silencio un «queda-local» previo.
- ¿Qué **Sala** dueña? (`norma:` C · `investigacion:` A · `activo:` B · `aprendizaje:` D). Para Sala C aplica el criterio **jurisdicción-agnóstico** (sube lo oficial/público/inmutable/no-confidencial que toque a más de un proyecto) y etiqueta `ambito:` (`universal` · `jurisdiccion: <ISO-3166>` · `sector: <slug>`). Ver `03-Referencia/LEEME - Esquema Sala C.md`.
- **Veredicto:** promover · fusionar · quedarse local · descartar.

## 4. Consumar según DÓNDE corres
- **En el Centro de Mando** (dueño del global) → si el veredicto es *promover*, escribe la entrada canónica en la Sala global que corresponda, asigna el **ID estable**, actualiza su índice y `log.md`, y verifica **0 enlaces rotos**. (Investigación de un dominio sin hogar: clave `dominio:<slug>` + nota-índice MOC en la **única** bóveda global — nunca una bóveda nueva.)
- **En un proyecto** → el global es **read-only** desde aquí.
  - **Guarda anti-errand-fantasma (primero).** Si el veredicto **NO** es *promover* (local · descartar · fusión que se resuelve local), **no produzcas paquete ni mandes a nadie al CDM**: di «esto se queda local; no hay nada que subir al global» y cierra. Solo *promover* cruza la frontera — mandar al usuario al Centro sin paquete es el ping-pong que esto corta.
  - Si *promover*: **GENERA un paquete autocontenido** leyendo las Salas **de este proyecto** (tu propio contexto, permitido) y **embebe** dentro del `.md` el frontmatter completo + el cuerpo íntegro de cada ficha, ya **project-neutral**. Déjalo en el buzón `04-Recursos/04-Aprendizaje/promociones/<id>.md` (crea `promociones/` si falta; append-only).
    - **Embeber por construcción, NO apuntar.** El materializador del CDM solo lee **ese `.md`**; jamás otra carpeta del proyecto (aislamiento). Para Sala C copia **cada ficha completa** (frontmatter `id`/`marco`/`titulo`/`fuente_oficial`/`version_fuente`/`ingerido` + el resumen fiel), no rutas ni listas de archivos. La URL oficial se cita **además** del texto, no en su lugar.
    - **Chequeo de cierre:** «¿un materializador que SOLO lee este `.md` reconstruye cada ficha sin abrir otra carpeta?» Si no, embebe lo que falte.
    - **Verifica el sobre EN DISCO.** Descúbrelo/léelo con `Get-ChildItem`/`find`, **NUNCA con Glob/Grep** (el `.gitignore` del proyecto ignora `04-Recursos/` con `/*` y las herramientas tipo ripgrep saltan el buzón → falso «0»). Confirma que existe y reléelo: debe reconstruirse solo. **PROHIBIDO** cerrar diciendo «ve al CDM» si el archivo no está escrito y verificado.
  - Cierra: **«Para consumar — en el CDM: corre `/sabio-promover-buzon`»** — lo descubre solo (sin pegar nada), lo re-tría y materializa solo lo global.

## 5. Federación de vuelta — ESTADO DERIVADO (sin avance manual, sin ping-pong)
**No hay máquina de 5 estados ni viaje del ID a mano.** Si el recurso existe en el plano global, está **federado**; si no, está **pendiente** — y eso se **computa en vivo** consultando `sabio-shared` (§3), no se anota ni se «avanza». El paquete del buzón es la **copia autocontenida recuperable**; su campo `estado:` es **informativo**, no la fuente de verdad. El único estado que sí se **escribe** es **`descartado`** (decisión humana de no promover, con motivo). Así el bucle no puede desincronizarse entre sesiones — la causa del ping-pong histórico.

## Reglas (no negociables)
- **Confidencialidad:** solo sube lo **genérico/project-neutral**; nada confidencial del proyecto.
- **IDs estables:** no renombres un `id:` ya asignado.
- **Una fuente por capa:** un dato vive en UNA Sala; las demás lo referencian por ID (corre `/memory-lint` si dudas).
- **Aislamiento:** captura y triaje son locales; el único canal al global es **escribir desde el CDM** o **leer vía `sabio-shared`**.

## Salida
Reporta: el `aprendizaje:<id>`, el veredicto del triaje (Sala dueña / promover / fusionar / local / descartar / **ya-federado**), y — según dónde corriste — lo **escrito en el global** o el **paquete verificado en disco** listo para `/sabio-promover-buzon`.
