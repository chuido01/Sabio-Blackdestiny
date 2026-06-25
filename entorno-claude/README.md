# Entorno de Claude Code para SABIO (`home-claude/`)

> Versiona la capa **`~/.claude/`** (la configuración de Claude Code a nivel **usuario**, transversal a
> todos tus proyectos): preferencias, agentes, comandos y hooks. Aplícala en cualquier máquina para
> tener el mismo entorno de trabajo con IA.

## Qué contiene (`home-claude/`)
- `CLAUDE.md` — preferencias transversales (plantilla: ajústala a tu idioma y tu forma de trabajar).
- `settings.json` — permisos y **hooks** de sesión (sin secretos; las rutas usan el marcador `<TU_CARPETA_HOME>`).
- `agents/` — 7 agentes nivel-usuario: `commit-writer`, `code-reviewer`, `doc-writer`, `research-curator`, `sabio-curator`, `sabio-reflector`, `security-engineer`.
- `commands/` — slash commands: `/aprender`, `/sabio-reflector`, `/promover`, `/memory-lint`, `/disenar`.
- `scripts/` — hooks: `hook-session-start.ps1`, `hook-pre-compact.ps1`.

## Aplicar el entorno en una máquina nueva
- **Windows:**
  ```powershell
  & .\Aplicar-Setup.ps1
  ```
  Copia `CLAUDE.md` + `agents/` + `commands/` + `scripts/` a `~/.claude/` (respaldando lo que pise).
  `settings.json` **no** se pisa: se genera `~/.claude/settings.from-sabio.json` con las rutas ya
  adaptadas a tu usuario, para que lo **revises y fusiones**.
- **macOS / Linux:** pide a Claude Code que haga lo mismo siguiendo `INSTALAR.md` (copiar las mismas
  carpetas a `~/.claude/` y adaptar los hooks). No hace falta PowerShell.

## Mantener tu copia al día (tras editar agentes/hooks/comandos en `~/.claude/`)
- **Windows:** `& .\Sincronizar-Setup.ps1` captura `~/.claude/{curados}` de vuelta a `home-claude/`. Luego commitea.

## Notas
- **Sin secretos.** Aquí no entran credenciales (`~/.claude/.credentials.json`), `settings.local.json`,
  caches ni sesiones.
- **Hooks multiplataforma.** Los hooks son scripts PowerShell (`.ps1`). En macOS/Linux, Claude puede
  traducirlos a su equivalente o puedes omitirlos: son una ayuda (recordatorio de reglas al iniciar y
  checkpoint al compactar), no un requisito.
- **Idempotente y no destructivo:** `Aplicar` siempre respalda antes de pisar (`~/.claude/backups/`).
