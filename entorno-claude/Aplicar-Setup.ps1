<#
.SYNOPSIS
  Aplica el entorno IA versionado (home-claude/) a ~/.claude/ de esta maquina. Idempotente, con respaldo.

.DESCRIPTION
  Copia CLAUDE.md + agents/ + commands/ + scripts/ de home-claude/ a ~/.claude/, respaldando lo que pise
  en ~/.claude/backups/. settings.json NO se sobrescribe: se genera ~/.claude/settings.from-sabio.json
  con la ruta del home adaptada a $env:USERPROFILE, para que el usuario lo revise y fusione a mano.

  Solo para Windows (PowerShell). En macOS/Linux, pide a Claude Code que ejecute los pasos
  equivalentes siguiendo INSTALAR.md (copiar las mismas carpetas a ~/.claude/).

.PARAMETER Destino
  Carpeta ~/.claude destino. Por defecto $env:USERPROFILE\.claude.
#>
[CmdletBinding()]
param([string]$Destino = (Join-Path $env:USERPROFILE ".claude"))

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$hc = Join-Path $PSScriptRoot "home-claude"
if (-not (Test-Path $hc)) { throw "No encuentro home-claude/ junto a este script." }
if (-not (Test-Path $Destino)) { New-Item -ItemType Directory -Force -Path $Destino | Out-Null }

$fecha = Get-Date -Format "yyyyMMdd-HHmmss"
$bak = Join-Path $Destino ("backups\sabio-aplicar-" + $fecha)
$huboRespaldo = $false

function Copiar-ConRespaldo($origen, $destino) {
  if (Test-Path $destino) {
    if (-not (Test-Path $script:bak)) { New-Item -ItemType Directory -Force -Path $script:bak | Out-Null }
    Copy-Item $destino (Join-Path $script:bak (Split-Path $destino -Leaf)) -Force -Recurse
    $script:huboRespaldo = $true
  }
  Copy-Item $origen $destino -Force
}

# 1) CLAUDE.md
Copiar-ConRespaldo (Join-Path $hc "CLAUDE.md") (Join-Path $Destino "CLAUDE.md")

# 2) agents / commands / scripts (carpetas curadas = fuente de verdad)
foreach ($sub in @("agents", "commands", "scripts")) {
  $d = Join-Path $Destino $sub
  if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
  Get-ChildItem -File (Join-Path $hc $sub) -ErrorAction SilentlyContinue | ForEach-Object {
    Copiar-ConRespaldo $_.FullName (Join-Path $d $_.Name)
  }
}

# 3) settings.json -> NO se pisa; copia con la ruta del home adaptada para revisar/fusionar.
#    La plantilla usa el marcador <TU_CARPETA_HOME> en las rutas de los hooks.
$st = [System.IO.File]::ReadAllText((Join-Path $hc "settings.json"), [System.Text.Encoding]::UTF8)
$up = $env:USERPROFILE -replace '\\', '\\'   # backslashes duplicados para JSON
$st = $st.Replace('<TU_CARPETA_HOME>', $up)
$out = Join-Path $Destino "settings.from-sabio.json"
[System.IO.File]::WriteAllText($out, $st, $utf8)

Write-Host ""
Write-Host "Entorno IA aplicado a: $Destino" -ForegroundColor Green
Write-Host "  + CLAUDE.md + agents/ + commands/ + scripts/ copiados."
if ($huboRespaldo) { Write-Host "  + respaldo de lo sobrescrito en: $bak" -ForegroundColor DarkGray }
Write-Host "  ! settings.json NO se piso. Revisa/fusiona: $out (rutas ya adaptadas a tu usuario)." -ForegroundColor Yellow
Write-Host ""
