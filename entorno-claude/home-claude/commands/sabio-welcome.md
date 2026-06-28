---
description: Despliega SABIO en un proyecto nuevo de extremo a extremo desde tu Centro de Mando Sabio — ejecuta el Kit contra la ruta indicada, corre el doble-check/test (estructura efectiva + canal del plano global) y, si usas el dashboard, adopta el proyecto re-escaneando la flota. Multi-SO (Claude ejecuta los pasos). Model Opus.
argument-hint: <ruta-destino> [NombreBoveda] [base|agentico]
model: opus
---

Despliegue **end-to-end** de SABIO a un proyecto nuevo: recibes una ruta y dejas el proyecto creado,
**probado** y (si usas el dashboard) **visible** en tu panel de flota — sin declarar nada "hecho" sin
enseñar la prueba. Reutiliza los scripts del repo SABIO; **no reinventes** su lógica.

> **Portabilidad:** este comando lo ejecuta Claude Code, que adapta cada paso a tu sistema
> (Windows / macOS / Linux). En Windows hay scripts `.ps1` listos; en macOS/Linux Claude hace los
> pasos equivalentes (copiar moldes, `git init`, registrar el MCP, leer el índice del plano global).

## Argumentos ("$ARGUMENTS")
1. **ruta-destino** (obligatoria): carpeta raíz del proyecto. Si no existe, el Kit la crea.
2. **NombreBoveda** (opcional): por defecto `Memoria_<carpeta>`.
3. **perfil Sala D** (opcional): `base` (por defecto) o `agentico`.

Si falta la ruta, **pídela**. No asumas una ruta.

## Antes de empezar — localizar las piezas
Necesitas saber dos rutas (pregúntalas al usuario si no las tienes en contexto):
- **`<repo>`**: tu copia del repositorio SABIO (donde están `kit/`, `dashboard/`, `mcp/`).
- **`<centro>`**: tu **Centro de Mando Sabio** (el plano global). Opcional: si el usuario no usa plano
  global, el proyecto se crea **solo-local** (igualmente válido).

## Fase 1 · Guarda + entrada
- Confirma que el despliegue tiene sentido desde aquí: idealmente lo corres teniendo a mano tu
  `<centro>` y tu `<repo>`. Si el destino **ya tiene contenido** (existe un `CLAUDE.md` propio),
  **pausa y confirma** con el usuario antes de seguir (el Kit es no destructivo, pero conviene
  confirmar el destino).

## Fase 2 · Desplegar el Kit
**Windows:**
```powershell
& "<repo>/kit/Crear-Proyecto.ps1" -ProyectoDestino "<ruta-destino>" -CentroDeMando "<centro>"
#   + -NombreBoveda "<...>" y/o -PerfilSalaD <base|agentico> si se indicaron.
#   Omite -CentroDeMando si el proyecto será solo-local (sin plano global).
```
**macOS/Linux:** replica los pasos del Kit siguiendo `INSTALAR.md` (copiar `_plantilla/`, `_federado/`,
`_proyecto/`; sustituir `<NombreProyecto>`, `<NombreBoveda>`,
`<fecha>`, `<PerfilSalaD>`; `git init`; y registrar `sabio-shared` en el `.mcp.json` con rutas reales).

Captura el reporte **HECHO / SIN-CAMBIOS**. El Kit es **idempotente**: re-ejecutarlo solo completa lo que falte.

## Fase 3 · Doble-check + TEST (la prueba real)
**Windows:**
```powershell
& "<repo>/kit/Validar-Despliegue.ps1" -Proyecto "<ruta-destino>"
```
**macOS/Linux:** verifica los mismos artefactos con `test`/`ls` (5 carpetas, git, `.gitignore`,
`CLAUDE.md`, LEEME, bóveda Sala A completa, federado con sus LEEME, `.mcp.json`) y, si el proyecto
declara `sabio-shared`, arranca su `python` importando el `server.py` con `SABIO_GLOBAL_ROOT=<centro>`
y confirma que **lee** el índice de índices del plano global.

El test comprueba: **estructura efectiva**, **aislamiento preservado** (el `CLAUDE.md` conserva
"Acceso a la bóveda" y "Trabaja SOLO con el contexto") y, si hay plano global, el **canal de lectura**
(read-only) hacia tu Centro de Mando. Un proyecto **solo-local** es válido: ahí el canal es WARN, no FAIL.

**Lee el `exit code`** (0 = todos los checks críticos en PASS). Si hay **FAIL**, reporta el estado como
**parcial**, explica qué falló y propón el arreglo — no continúes como si todo estuviera bien.

## Fase 4 · Adoptar en el panel (si usas el dashboard)
Re-escanea la flota para que el proyecto nuevo aparezca:
```bash
python "<repo>/dashboard/escanear-flota.py" --abrir
#   (o, en Windows, doble-clic en dashboard/Abrir-Panel.cmd)
```
El escáner descubre automáticamente cualquier proyecto bajo la carpeta de proyectos configurada en
`dashboard/flota.config.json` — no hay registro manual que mantener. Si no usas el dashboard, omite esta fase.

## Fase 5 · Reporte ("mostrar, no afirmar")
Cierra con un resumen claro: **árbol** de lo creado, **tabla PASS/FAIL** del test (incluido el canal
del plano global si aplica), y — si re-escaneaste — confirmación de que el proyecto aparece en el panel.
Si algo quedó a medias, dilo y márcalo **parcial**, nunca "hecho".

## Reglas (no negociables)
- **Aislamiento:** el Kit **escribe o preserva** la restricción de aislamiento del proyecto; nunca la
  debilita. Un proyecto jamás lee otro; solo puede leer el plano global (read-only) vía `sabio-shared`.
- **No reinventar:** ejecuta `Crear-Proyecto.ps1`, `Validar-Despliegue.ps1` y `escanear-flota.py`; no
  dupliques su lógica.
- **Prueba antes de afirmar:** "desplegado y funcionando" se sostiene en el `exit 0` del test (y, si
  aplica, en el proyecto visible en el escaneo), no en que "no falló".
