# Hook PreCompact - checkpoint de estado ANTES de compactar.
# (1) Deja un registro durable en ~/.claude/checkpoints/precompact.log (sobrevive a la compactacion).
# (2) Su stdout recuerda conservar el estado clave antes de perder contexto.
# ASCII-only a proposito (PowerShell 5.1 + .ps1 sin BOM); nunca falla el hook (errores silenciados).
$ErrorActionPreference = "SilentlyContinue"
$ts  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$dir = Join-Path $env:USERPROFILE ".claude\checkpoints"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
Add-Content -Path (Join-Path $dir "precompact.log") -Value ("$ts | cwd=" + $PWD.Path)
Write-Output "[Checkpoint pre-compactacion $ts] Antes de perder contexto, conserva: la tarea actual y sus pendientes, las decisiones de arquitectura y las rutas clave del proyecto."
