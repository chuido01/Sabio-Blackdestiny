# Instalar SABIO con Claude Code

> Esta guía está pensada para que **Claude Code la lea y la ejecute por ti**. No necesitas saber
> PowerShell ni Bash: Claude detecta tu sistema operativo (Windows, macOS o Linux) y hace los pasos
> equivalentes. También puedes seguirla a mano si lo prefieres.

---

## Antes de empezar (requisitos)

| Necesitas | Para qué | Cómo comprobar |
|---|---|---|
| **Claude Code** | Es quien instala y luego usa SABIO. | `claude --version` |
| **git** | Repos aislados por proyecto. | `git --version` |
| **Python 3.10+** | Solo para el MCP `sabio-shared` (el puente al plano global). | `python --version` |

> Si no piensas usar el plano global compartido, **Python es opcional**: SABIO funciona igual con
> solo las Salas locales.

---

## La forma fácil (recomendada)

1. **Clona el repo** y entra en la carpeta:
   ```bash
   git clone https://github.com/<tu-usuario>/sabio-blackdestiny.git
   cd sabio-blackdestiny
   ```
2. **Abre Claude Code** en esa carpeta.
3. **Pega esto** y deja que Claude trabaje:
   ```
   Instala SABIO en esta máquina siguiendo INSTALAR.md. Detecta mi sistema operativo,
   hazlo idempotente (no pises nada sin respaldar) y, al terminar, enséñame qué quedó instalado.
   ```

Claude hará los **4 pasos** de abajo. Es seguro re-ejecutarlo: nunca sobrescribe sin respaldar.

---

## Lo que Claude instala (los 4 pasos)

> 🤖 **Instrucciones para el agente.** Si eres Claude Code ejecutando esta guía, haz exactamente
> esto, en orden, adaptando cada comando al SO del usuario. Respalda antes de pisar. Reporta al
> final un resumen de *hecho / saltado*.

### Paso 1 — El entorno de Claude (`~/.claude/`)

Copia, desde [`entorno-claude/`](entorno-claude/) hacia la carpeta de configuración de usuario de
Claude Code (`~/.claude/` en macOS/Linux, `%USERPROFILE%\.claude\` en Windows):

- `commands/` → los skills `/sabio-aprender`, `/sabio-reflector`, `/sabio-promover`, `/memory-lint`, `/disenar`, y `/sabio-welcome`
  (despliegue end-to-end de un proyecto; se ejecuta desde tu Centro de Mando Sabio).
- `agents/` → los 7 agentes (curador SABIO, reflector de auto-mejora, curador de investigación, revisor de código,
  commit-writer, doc-writer, seguridad).
- `scripts/` → los hooks de sesión (recordatorio de reglas al iniciar, captura al compactar).
- `CLAUDE.md` → preferencias transversales (plantilla genérica; el usuario la edita).

> **Respaldo obligatorio:** antes de pisar cualquier archivo existente en `~/.claude/`, cópialo a
> `~/.claude/backups/sabio-<fecha>/`. En Windows existe el atajo `entorno-claude/Aplicar-Setup.ps1`.

### Paso 2 — El MCP `sabio-shared` (el puente al plano global)

1. Crea un entorno virtual de Python e instala las dependencias de [`mcp/`](mcp/):
   ```bash
   python -m venv .venv
   # Windows:  .venv\Scripts\activate     ·  macOS/Linux:  source .venv/bin/activate
   pip install -r mcp/requirements.txt
   ```
2. El servidor (`mcp/server.py`) **autodetecta** la raíz del plano global y el nombre de la bóveda;
   también acepta la variable de entorno `SABIO_GLOBAL_ROOT` para fijarla.
3. Este MCP se registra **por proyecto** en su `.mcp.json` (lo hace el Kit en el Paso 4, con las
   rutas reales de TU máquina). No hay rutas absolutas incrustadas en el repo.

> Si el usuario no quiere plano global compartido, **omite este paso**.

### Paso 3 — Tu Centro de Mando Sabio (el plano global)

Crea el *hub* que sirve a todos tus proyectos, a partir del molde
[`centro-de-mando-sabio/`](centro-de-mando-sabio/):

- Su `04-Recursos/` con el **índice de índices** y las Salas **C** (Referencia) y **D** (Aprendizaje
  transversal) — el conocimiento compartido vive aquí, una sola vez.
- Pregúntale al usuario **dónde** quiere su Centro de Mando (una carpeta fuera de los proyectos).

### Paso 4 — Crear tu primer proyecto

Usa el Kit ([`kit/`](kit/)) para crear un proyecto completo (Capa 1 + Capa 2):

- **Windows:** `& "kit/Crear-Proyecto.ps1" -ProyectoDestino "<ruta>" -PerfilSalaD base`
- **macOS/Linux** (o si el usuario prefiere no usar PowerShell): replica los pasos del Kit copiando
  los moldes `_plantilla/`, `_federado/`, `_proyecto/`, sustituyendo `<NombreProyecto>`, `<NombreBoveda>`,
  `<fecha>` y `<PerfilSalaD>`. (La Sala D es una sola forma: `ESQUEMA.md` + `tools/` ya vienen en `_federado/04-Aprendizaje/`.)
- Registra el MCP `sabio-shared` en el `.mcp.json` del proyecto, apuntando al `server.py` y al
  Centro de Mando del Paso 3 con **rutas absolutas reales de esta máquina**.
- **Valida el despliegue:** corre `kit/Validar-Despliegue.ps1 -Proyecto "<ruta>"` (Windows) — o los
  chequeos equivalentes en macOS/Linux — para comprobar que se escribió todo (estructura + aislamiento)
  y que el canal del plano global **lee de verdad** el índice del Centro de Mando.

> **Atajo:** el comando `/sabio-welcome <ruta>` hace este Paso 4 + el test + la adopción en el panel,
> en un solo paso. Úsalo desde tu Centro de Mando Sabio una vez instalado el entorno (Paso 1).

> **Perfil del proyecto:** `base` (por defecto, captura sencilla con `/sabio-aprender`) o `agentico`
> (añade validador y confianza numérica). Sube a `agentico` solo si el proyecto ejecuta agentes/skills
> en bucle.

---

## Opcional — Dashboard de flota

Para ver la salud de **todos** tus proyectos de un vistazo (panel offline, sin servidor):
copia `dashboard/flota.config.example.json` a `dashboard/flota.config.json` con tus rutas y ejecuta
`python dashboard/escanear-flota.py --abrir` (en Windows, doble-clic en `dashboard/Abrir-Panel.cmd`).
Detalles en [`dashboard/README.md`](dashboard/README.md).

---

## Comprobar que quedó bien

Pídele a Claude:

```
Verifica la instalación de SABIO: lista los comandos y agentes en ~/.claude, confirma que
el MCP sabio-shared responde, y muéstrame el árbol del proyecto que creaste.
```

Deberías ver: los 6 comandos, los 7 agentes, el MCP `sabio-shared` conectado y un proyecto con sus
5 carpetas + las 4 Salas.

---

## Notas por sistema

- **Windows.** Hay scripts `.ps1` listos (`Crear-Proyecto.ps1`, `Aplicar-Setup.ps1`). Si PowerShell
  bloquea la ejecución, usa `powershell -ExecutionPolicy Bypass -File "<script>.ps1"`.
- **macOS / Linux.** No hay `.ps1`, pero no hacen falta: Claude ejecuta los pasos equivalentes
  (copiar moldes, crear carpetas, `git init`, registrar el MCP). El `server.py` es Python puro y
  corre igual en los tres sistemas.
- **Desinstalar / revertir.** Todo lo pisado quedó respaldado en `~/.claude/backups/`. Los proyectos
  y el Centro de Mando son carpetas normales: bórralas si quieres empezar de cero.
