---
description: Escanea los buzones de promoción de toda la flota y materializa en el plano global el paquete que elijas — automatiza el TRANSPORTE del volante /sabio-promover (descubrir + traer), sin tocar el GATE humano. Lee solo la carpeta promociones/ de cada proyecto, nunca su bóveda. Solo corre desde el CDM. Model Opus.
argument-hint: (sin argumentos — lista los pendientes; luego eliges cuál materializar)
model: opus
---

Automatiza el **transporte** del volante de replicación: descubre los paquetes de promoción que la flota
dejó en sus **buzones** y trae el que elijas para materializarlo en el plano global. Mata el copia-pega
manual; **no** toca el juicio de qué sube — ese sigue siendo tuyo (el *gate*).

> **Modelo mental:** el escaneo es el **cartero** — trae los sobres, no los abre ni decide enviarlos.
> Subir al plano global es de alto impacto, así que la **elección** y el **re-triaje** son humanos/
> supervisados. Este comando solo **lee** el buzón `promociones/` de cada proyecto (canal de salida que
> el proyecto llena a propósito); **nunca** su bóveda ni ninguna otra carpeta, y **nunca escribe** en un
> proyecto.

## Fase 0 · Guarda (solo desde el CDM)
Confirma que corres desde el **Centro de Mando** (única sede con escritura sobre el plano global):
- Debe existir `.tools\sabio-shared\server.py` y el `additionalDirectories → <TU-CARPETA-DE-PROYECTOS>`
  en `.claude\settings.local.json`.
- Si **no** estás en el CDM, **detente**: *«/sabio-promover-buzon solo se ejecuta desde el Centro de
  Mando (dueño del plano global)»*. No intentes escribir el global desde otro proyecto.

## Fase 1 · Escanear los buzones (solo lectura, inofensivo)
Recorre **solo** la carpeta-buzón de cada proyecto de la flota:
```
<TU-CARPETA-DE-PROYECTOS>\*\04-Recursos\04-Aprendizaje\promociones\*.md
```
**Descúbrelos con `Get-ChildItem -Recurse` de PowerShell (o `find`), NUNCA con Glob/Grep:** el `.gitignore` de cada proyecto ignora `04-Recursos/` con un patrón `/*`, y las herramientas tipo ripgrep **saltan los archivos ignorados** → el buzón se ve **vacío cuando no lo está** (falso negativo). Lee **únicamente** esos archivos. **Prohibido** abrir cualquier otra carpeta de cualquier proyecto
(bóveda Sala A, demás Salas, código, datos) — aislamiento. De cada paquete extrae: `origen` (proyecto),
`fecha`, los **candidatos** (con su Sala destino e **IDs propuestos**) y `estado`.

## Fase 2 · Cruzar contra el plano global (sin ledger extra)
Para cada paquete, comprueba si sus **IDs propuestos ya existen** en el plano global del CDM (el propio
global es el registro — una fuente por capa):
- `norma:` → `04-Recursos/03-Referencia/registros/` (o su `index.md`).
- `investigacion:` → bóveda `…/Memoria_Global/index.md` y `wiki/`.
- `aprendizaje:` → `04-Recursos/04-Aprendizaje/registros/`.
- `activo:` → `04-Recursos/02-Catalogo/index.md`.

Clasifica cada paquete:
- **PENDIENTE de materializar** — ninguno de sus IDs está aún en el global.
- **YA EN EL GLOBAL** — todos sus IDs existen → solo falta **federar de vuelta** en el proyecto de origen.
- **PARCIAL / revisar** — algunos sí, otros no (materialización incompleta o IDs cambiados).

## Fase 3 · Listar y dejar que el humano elija (el GATE)
Muestra una lista **numerada** y clara, en español, p. ej.:
```
Buzones de promoción — flota · escaneo <fecha>

PENDIENTES de materializar
  [1] <proyecto> · <paquete>
      <N> candidatos: <resumen por Sala> · depositado <fecha> · 0 de <N> IDs en el global
  ...

YA EN EL GLOBAL (solo falta cerrar en el origen)
  [k] <proyecto> · <paquete> → <ID> ya existe → marca "promovido" en <proyecto>

→ Elige un número para materializar, varios, o "nada".
```
**No materialices nada por tu cuenta.** Espera la elección del usuario. Si responde "nada", cierra sin
escribir. (El comando es jurisdicción-agnóstico: trata cada paquete por su contenido, no por su origen.)

## Fase 4 · Materializar lo elegido (re-triaje, NO volcado)
Para cada paquete que el usuario elija, **delega en el agente `sabio-curator`** y sigue el **mismo flujo
que `/sabio-promover` en su rama "En el Centro de Mando"**: re-tría **uno por uno** (¿transversal de plataforma,
de una jurisdicción/sector, o propio del proyecto?), asigna la **etiqueta de ámbito** que corresponda
(`ambito: universal` · `jurisdiccion: <ISO-3166>` · `sector: <slug>`; ver `03-Referencia/LEEME - Esquema
Sala C.md`), materializa en la Sala global dueña con su **ID estable**, deposita fuentes oficiales si las
hay, actualiza el índice de esa Sala y el `log.md`, y **verifica 0 enlaces rotos**. Desconfía de los lotes
grandes: lo de dominio/proyecto **no** sube. El paquete entra por su ruta en el buzón (ya autorizada por
este comando); **no** salgas a leer nada más del proyecto.

## Fase 5 · Federar de vuelta — ESTADO DERIVADO (sin escribir el origen, sin avance manual)
El CDM **no escribe** en los proyectos. Al cerrar, **devuelve al usuario** los **IDs estables** resultantes.
**No hay que avanzar ningún registro a mano:** el estado de federación se **deriva** — si el ID ya existe en
el plano global, ese aprendizaje está **federado**; si no, sigue **pendiente**. La próxima corrida de
`/sabio-promover` en el proyecto de origen lo **computa en vivo** vía `sabio-shared` y lo reporta como
*ya-federado* (no hay máquina de 5 estados ni viaje del ID — ahí estaba el ping-pong). El paquete del buzón
queda como copia autocontenida recuperable; su `estado:` es informativo.

## Reglas (no negociables)
- **Solo lectura del buzón:** leo **únicamente** `…/04-Aprendizaje/promociones/` de cada proyecto; jamás
  otra carpeta (bóveda, Salas, código). **Nunca escribo** en un proyecto. (Excepción de lectura registrada
  en el `CLAUDE.md` del CDM, sección «Sede central de despliegue».)
- **El gate es humano:** el escaneo descubre y lista; **materializa solo lo que el usuario elige**. Nunca
  auto-promuevo.
- **Re-triaje, no volcado:** cada candidato se evalúa de nuevo con el criterio jurisdicción-agnóstico y se
  etiqueta por ámbito. Un volcado en bloque contamina el plano global.
- **Una fuente por capa:** el cruce contra el global evita doble materialización; no creo un ledger aparte.
- **Mostrar, no afirmar:** cuenta real de buzones/paquetes; tras materializar, enseña conteos y 0 enlaces
  rotos. Verificación parcial → estado **parcial**, no "hecho".
