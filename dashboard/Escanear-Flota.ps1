<#
.SINOPSIS
    Envoltura Windows del escaner portable (escanear-flota.py). Misma salida, SIN logica duplicada:
    el motor unico es el .py (multiplataforma). Este .ps1 existe por comodidad en Windows.
.USO
    .\Escanear-Flota.ps1                       # usa flota.config.json
    .\Escanear-Flota.ps1 -Abrir
    .\Escanear-Flota.ps1 -Centro "C:\Centro de Mando Sabio" -Proyectos "C:\Mis Proyectos" -Abrir
#>
[CmdletBinding()]
param(
    [string]$Centro,
    [string]$Proyectos,
    [switch]$Abrir
)
$ErrorActionPreference = 'Stop'
$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$a = @()
if ($Centro)    { $a += '--centro';    $a += $Centro }
if ($Proyectos) { $a += '--proyectos'; $a += $Proyectos }
if ($Abrir)     { $a += '--abrir' }
python (Join-Path $aqui 'escanear-flota.py') @a
