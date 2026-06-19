<#
.SYNOPSIS
  Captura los activos curados de ~/.claude/ de vuelta a home-claude/ (para versionar cambios).

.DESCRIPTION
  Lo contrario de Aplicar-Setup.ps1: copia CLAUDE.md, settings.json, agents/, commands/ y scripts/ de
  ~/.claude/ a home-claude/. Tras correrlo, revisa el diff con git y commitea. NO toca secretos.

.PARAMETER Origen
  Carpeta ~/.claude origen. Por defecto $env:USERPROFILE\.claude.
#>
[CmdletBinding()]
param([string]$Origen = (Join-Path $env:USERPROFILE ".claude"))

$ErrorActionPreference = "Stop"
$hc = Join-Path $PSScriptRoot "home-claude"
foreach ($d in @("$hc\agents", "$hc\commands", "$hc\scripts")) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

Copy-Item (Join-Path $Origen "CLAUDE.md")     (Join-Path $hc "CLAUDE.md")     -Force
Copy-Item (Join-Path $Origen "settings.json") (Join-Path $hc "settings.json") -Force
Copy-Item (Join-Path $Origen "agents\*.md")   (Join-Path $hc "agents\")       -Force
Copy-Item (Join-Path $Origen "commands\*.md") (Join-Path $hc "commands\")     -Force
Copy-Item (Join-Path $Origen "scripts\*.ps1") (Join-Path $hc "scripts\")      -Force

Write-Host ""
Write-Host "Sincronizado ~/.claude -> home-claude/. Revisa el diff (git status/diff) y commitea." -ForegroundColor Green
Write-Host ""
