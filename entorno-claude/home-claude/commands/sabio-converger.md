---
description: Converge toda la flota al molde canónico del Kit (homogeneidad). Escanea el drift generacional de cada proyecto, lo muestra, y SOLO con tu OK re-proyecta lo atrasado — sin tocar contenido ni lo local. Solo corre desde el CDM. Model Opus.
argument-hint: (sin args = toda la flota dry-run; [ruta] = un proyecto; --aplicar tras revisar la tabla)
model: opus
---

Mantiene la flota **homogénea**: re-proyecta el **molde canónico** (espinazo, esquemas de Sala, buzón,
`CLAUDE.md` de bóveda) sobre cada proyecto que esté **atrasado de generación**, sin pisar el contenido ni
lo local. Es el brazo de homogeneidad del refactor SABIO — el hermano de `/sabio-promover-buzon` (que mueve
conocimiento); éste mueve **andamiaje**.

> **Modelo mental:** una fuente (el Kit), muchos punteros (los proyectos). El Kit es la verdad; este comando
> **proyecta** esa verdad, nunca al revés. Solo escribe **andamiaje regenerable** (archivos sellados
> `<!-- sabio-generacion: N -->`); jamás toca `wiki/`, `registros/`, `fichas/`, índices poblados ni `raw/`.

## Fase 0 · Guarda (solo desde el CDM)
Confirma que corres en el **Centro de Mando** (existe `.tools\sabio-shared\server.py` + `additionalDirectories
→ <TU-CARPETA-DE-PROYECTOS>` en `.claude\settings.local.json`). Si no, **detente**: la convergencia se
orquesta desde el CDM (dueño del molde). El repo publicado y otros no-consumidores se excluyen con `-Excluir`.

## Fase 1 · Escanear el drift (dry-run; inofensivo)
Corre el convergedor en **dry-run** (sin `-Aplicar`):

```powershell
& "<TU-CENTRO-DE-MANDO>\kit\Actualizar-Proyecto.ps1" -Flota
```
*(Para un solo proyecto: `-Destino "<ruta>"`.)* El script compara el sello `generacion:` del Kit contra el
de cada proyecto y reporta por proyecto. **Tres clases** de entrada:
- `~ convergido (puro)` — archivo 100 % canónico atrasado → se re-proyecta entero (LEEME B/D/buzón).
- `~ convergido (mixto, region canonica)` — archivo con marcadores → se re-proyecta **solo** la región canónica; lo local de abajo queda intacto.
- `! … SIN marcadores → requiere migracion inicial (manual)` — archivo mixto legado sin marcadores: **NO se toca**; necesita migración inicial guiada una sola vez (envolver su región canónica en marcadores preservando lo local).

Un archivo sellado `<!-- sabio-generacion: local -->` es **opt-out**: el proyecto lo declaró suyo (p. ej. un
espinazo con namespace propio) y **nunca** se converge.

## Fase 2 · Mostrar la tabla y esperar tu OK (el GATE)
Presenta la **tabla de drift** en español: por proyecto, qué archivos subirían de generación y cuáles piden
migración inicial. **No apliques nada por tu cuenta.** Si todo dice «ya conforme», repórtalo y cierra.

## Fase 3 · Aplicar lo aprobado
Solo con tu OK (`--aplicar` o confirmación explícita), re-corre con `-Aplicar`. Para los marcados «requiere
migración inicial», **hazlos uno por uno** preservando lo local (perfil de aplicabilidad de la Sala C,
secciones «Estado de las Salas», convenciones de bóveda); respalda el original antes de sobrescribir.

## Fase 4 · Verificar (mostrar, no afirmar)
Re-corre el dry-run: cada proyecto debe quedar **«ya conforme (sin cambios)»**. Comprueba que **lo local se
preservó** (grep de los perfiles/secciones locales) y reporta la **tabla final de homogeneidad** (todos en la
generación canónica, 0 enlaces rotos). Verificación parcial → estado **parcial**, no «hecho».

## Reglas (no negociables)
- **Solo andamiaje regenerable:** jamás contenido (`wiki/`, `registros/`, `fichas/`, índices poblados, `raw/`).
- **Lo mixto preserva lo local:** solo se re-proyecta la región entre `sabio:canonico:inicio/fin`; lo de abajo es del proyecto.
- **Opt-out se respeta:** `sabio-generacion: local` nunca se converge.
- **Gate humano:** dry-run → tabla → tu OK → aplicar. Sin OK no se escribe.
- **Aislamiento:** el CDM escribe andamiaje hacia la flota (poder de despliegue), nunca lee su conocimiento.
