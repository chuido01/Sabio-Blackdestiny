<#
.SYNOPSIS
  Doble-check / TEST de un despliegue SABIO. Verifica que Crear-Proyecto.ps1 escribio TODOS los
  artefactos esenciales y, si el proyecto esta conectado al plano global, que el canal
  proyecto -> Centro de Mando funciona de verdad.

.DESCRIPTION
  Test determinista y de SOLO LECTURA (no modifica el proyecto). Por cada artefacto emite
  PASS / FAIL (o WARN para lo informativo/opcional) y al final un resumen + exit code:
    exit 0  -> todos los checks criticos en PASS (despliegue efectivo)
    exit N  -> N checks criticos en FAIL

  Comprueba:
   1) ESTRUCTURA: las 5 carpetas, git, .gitignore, CLAUDE.md, LEEME, la boveda Sala A completa y el
      cerebro federado (indice de indices + Salas B/C/D con sus LEEME).
   2) AISLAMIENTO: el CLAUDE.md conserva "Acceso a la bóveda" y "Trabaja SOLO con el contexto de ESTE
      proyecto" (el Kit nunca debe dejar el proyecto con menos aislamiento).
   3) PLANO GLOBAL (opcional): si el .mcp.json declara sabio-shared, arranca el python que ese
      .mcp.json apunta, importa el server.py del Centro de Mando y confirma que LEE el indice de
      indices del plano global (read-only). Si el proyecto es solo-local (sin sabio-shared), este
      bloque es WARN, no FAIL: conectar el plano global es opcional en SABIO.

  Solo Windows (PowerShell). En macOS/Linux, pide a Claude Code que ejecute los chequeos equivalentes
  (Test-Path de los mismos artefactos + arrancar el server.py con SABIO_GLOBAL_ROOT y leer el indice).

.PARAMETER Proyecto
  Ruta raiz del proyecto a validar (el que creo Crear-Proyecto.ps1).

.PARAMETER CentroDeMando
  (Opcional) Raiz de tu Centro de Mando Sabio. Solo se usa como respaldo si el .mcp.json del proyecto
  no trae SABIO_GLOBAL_ROOT. Normalmente no hace falta: el test lee la config real del .mcp.json.

.PARAMETER OmitirCanal
  Salta la prueba viva del canal del plano global (queda como WARN). Util si no hay Python disponible.

.EXAMPLE
  & ".\Validar-Despliegue.ps1" -Proyecto "C:\Mis Proyectos\Mi App"
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Proyecto,
  [string]$CentroDeMando = "",
  [switch]$OmitirCanal
)

$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

if (-not (Test-Path $Proyecto)) { throw "No existe el proyecto a validar: $Proyecto" }
$Proyecto = (Resolve-Path $Proyecto).Path

# ----------------------------------------------------------------- registro de resultados
$resultados = New-Object System.Collections.Generic.List[object]
function Add-Check {
  param([string]$Nombre, [string]$Estado, [string]$Detalle = "", [switch]$NoCritico)
  $resultados.Add([pscustomobject]@{
    Nombre  = $Nombre
    Estado  = $Estado          # PASS | FAIL | WARN
    Detalle = $Detalle
    Critico = (-not $NoCritico)
  })
}
function Check-Existe {
  param([string]$Nombre, [string]$Ruta, [switch]$NoCritico)
  if (Test-Path $Ruta) { Add-Check $Nombre "PASS" $Ruta -NoCritico:$NoCritico }
  else { Add-Check $Nombre "FAIL" "falta: $Ruta" -NoCritico:$NoCritico }
}

# =====================================================================================
# 1) ESTRUCTURA (la escritura efectiva del Kit en disco)
# =====================================================================================
foreach ($c in @("00-Documentacion", "01-Produccion", "02-Desarrollo", "03-Backups", "04-Recursos")) {
  Check-Existe "carpeta $c\" (Join-Path $Proyecto $c)
}
Check-Existe "repo git (.git\)"  (Join-Path $Proyecto ".git")
Check-Existe ".gitignore"        (Join-Path $Proyecto ".gitignore")
Check-Existe "CLAUDE.md"         (Join-Path $Proyecto "CLAUDE.md")
Check-Existe "00 - LEEME.md"     (Join-Path $Proyecto "00-Documentacion\00 - LEEME.md")

# --- Boveda Sala A: localizar la unica carpeta bajo 04-Recursos\01-Boveda\
$vaultPadre = Join-Path $Proyecto "04-Recursos\01-Boveda"
$boveda = $null
if (Test-Path $vaultPadre) {
  $boveda = Get-ChildItem -Path $vaultPadre -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
}
if ($null -eq $boveda) {
  Add-Check "boveda Sala A" "FAIL" "no hay carpeta de boveda en: $vaultPadre"
} else {
  Add-Check "boveda Sala A ($($boveda.Name))" "PASS" $boveda.FullName
  Check-Existe "  boveda: CLAUDE.md"   (Join-Path $boveda.FullName "CLAUDE.md")
  Check-Existe "  boveda: index.md"    (Join-Path $boveda.FullName "index.md")
  Check-Existe "  boveda: log.md"      (Join-Path $boveda.FullName "log.md")
  Check-Existe "  boveda: plantilla nota atomica" (Join-Path $boveda.FullName "templates\_plantilla-nota-atomica.md")
  Check-Existe "  boveda: raw\"        (Join-Path $boveda.FullName "raw")
  Check-Existe "  boveda: wiki\"       (Join-Path $boveda.FullName "wiki")
}

# --- Cerebro federado (indice de indices + Salas B/C/D con sus LEEME)
$recursos = Join-Path $Proyecto "04-Recursos"
Check-Existe "federado: 00-INDICE-DE-INDICES.md" (Join-Path $recursos "00-INDICE-DE-INDICES.md")
Check-Existe "federado: Sala B (02-Catalogo)\"   (Join-Path $recursos "02-Catalogo")
Check-Existe "  Sala B: LEEME - Esquema"         (Join-Path $recursos "02-Catalogo\LEEME - Esquema Sala B.md")
Check-Existe "federado: Sala C (03-Referencia)\" (Join-Path $recursos "03-Referencia")
Check-Existe "  Sala C: LEEME - Esquema"         (Join-Path $recursos "03-Referencia\LEEME - Esquema Sala C.md")
Check-Existe "federado: Sala D (04-Aprendizaje)\" (Join-Path $recursos "04-Aprendizaje")
Check-Existe "  Sala D: LEEME - Esquema"         (Join-Path $recursos "04-Aprendizaje\LEEME - Esquema Sala D.md")

# =====================================================================================
# 2) AISLAMIENTO preservado en el CLAUDE.md del proyecto
# =====================================================================================
$claudeMd = Join-Path $Proyecto "CLAUDE.md"
if (Test-Path $claudeMd) {
  $txtClaude = [System.IO.File]::ReadAllText($claudeMd, [System.Text.Encoding]::UTF8)
  if ($txtClaude -match "Acceso a la bóveda") { Add-Check "aislamiento: regla 'Acceso a la bóveda'" "PASS" }
  else { Add-Check "aislamiento: regla 'Acceso a la bóveda'" "FAIL" "no aparece en CLAUDE.md" }
  if ($txtClaude -match "SOLO con el contexto") { Add-Check "aislamiento: 'Trabaja SOLO con el contexto'" "PASS" }
  else { Add-Check "aislamiento: 'Trabaja SOLO con el contexto'" "FAIL" "no aparece en CLAUDE.md" }
} else {
  Add-Check "aislamiento (CLAUDE.md)" "FAIL" "no hay CLAUDE.md que inspeccionar"
}

# =====================================================================================
# 3) PLANO GLOBAL (opcional): .mcp.json con sabio-shared + canal proyecto -> Centro de Mando
# =====================================================================================
$mcpPath = Join-Path $Proyecto ".mcp.json"
$pyExe = $null; $serverPy = $null; $globalRoot = $null; $tieneSabio = $false
if (-not (Test-Path $mcpPath)) {
  Add-Check ".mcp.json / plano global" "WARN" "proyecto solo-local (sin .mcp.json): conectar el plano global es opcional" -NoCritico
} else {
  try {
    $mcpObj = Get-Content $mcpPath -Raw | ConvertFrom-Json
    $shared = $mcpObj.mcpServers.'sabio-shared'
    if ($null -eq $shared) {
      Add-Check ".mcp.json: sabio-shared" "WARN" "el .mcp.json no declara sabio-shared (proyecto solo-local)" -NoCritico
    } else {
      $tieneSabio = $true
      Add-Check ".mcp.json: clave sabio-shared" "PASS"
      $pyExe = $shared.command
      if ($shared.args -and $shared.args.Count -ge 1) { $serverPy = $shared.args[0] }
      if ($shared.env) { $globalRoot = $shared.env.SABIO_GLOBAL_ROOT }
      if ([string]::IsNullOrWhiteSpace($globalRoot) -and -not [string]::IsNullOrWhiteSpace($CentroDeMando)) {
        $globalRoot = $CentroDeMando   # respaldo: si el .mcp.json no fija la raiz, usa el parametro
      }
      Check-Existe "  sabio-shared: python (venv)" $pyExe
      Check-Existe "  sabio-shared: server.py"     $serverPy
    }
  } catch {
    Add-Check ".mcp.json: parseable" "FAIL" "no se pudo parsear: $($_.Exception.Message)"
  }
}

# --- Prueba VIVA del canal (solo si el proyecto declara sabio-shared)
if (-not $tieneSabio) {
  # ya quedo un WARN arriba; nada que probar en un proyecto solo-local.
} elseif ($OmitirCanal) {
  Add-Check "canal plano global (lectura)" "WARN" "omitido por -OmitirCanal" -NoCritico
} elseif ($pyExe -and $serverPy -and (Test-Path $pyExe) -and (Test-Path $serverPy)) {
  try {
    $tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "sabio_probe_$([System.Guid]::NewGuid().ToString('N')).py")
    # globalRoot puede ir vacio: el server.py autodetecta la raiz desde su ubicacion (<root>/mcp/server.py).
    $setRoot = ""
    if (-not [string]::IsNullOrWhiteSpace($globalRoot)) {
      $setRoot = "os.environ['SABIO_GLOBAL_ROOT'] = r'''$globalRoot'''"
    }
    $pyCode = @"
import os, sys, importlib.util, traceback
try:
    $setRoot
    name = 'sabio_probe_server'
    spec = importlib.util.spec_from_file_location(name, r'''$serverPy''')
    m = importlib.util.module_from_spec(spec)
    sys.modules[name] = m                    # idioma correcto de importlib: registrar antes de ejecutar
    spec.loader.exec_module(m)               # carga el server real (FastMCP/pydantic)
    p = m._resolve_safe(m.INDICE_DE_INDICES) # resuelve dentro del scope permitido del plano global
    txt = m._read_text(p)
    assert len(txt) > 100, 'indice de indices vacio o ilegible'
    print('PROBE_OK len=%d' % len(txt))
except Exception:
    traceback.print_exc()
    sys.exit(1)
"@
    [System.IO.File]::WriteAllText($tmp, $pyCode, (New-Object System.Text.UTF8Encoding($false)))
    # Exe nativo: bajamos EAP a Continue para que una linea en stderr NO se vuelva excepcion
    # terminante (PS 5.1 + EAP=Stop). Juzgamos por exit code.
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $salida = (& $pyExe $tmp 2>&1 | Out-String)
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    if ($code -eq 0) {
      Add-Check "canal plano global (lee indice del Centro de Mando)" "PASS" "el proyecto lee el plano global (read-only)"
    } else {
      $cola = ($salida -split "`r?`n" | Where-Object { $_ -ne '' } | Select-Object -Last 3) -join " | "
      Add-Check "canal plano global (lee indice del Centro de Mando)" "FAIL" ("python exit=$code :: " + $cola)
    }
  } catch {
    Add-Check "canal plano global (lee indice del Centro de Mando)" "FAIL" $_.Exception.Message
  }
} else {
  Add-Check "canal plano global (lee indice del Centro de Mando)" "FAIL" "no se pudo resolver python/server.py del .mcp.json"
}

# =====================================================================================
# 4) HOMOGENEIDAD (convergencia generacional + andamiaje vigente)
# =====================================================================================
$kit = $PSScriptRoot
function Get-Gen([string]$ruta) {
  if (-not (Test-Path $ruta)) { return -1 }
  $l = Get-Content -LiteralPath $ruta -TotalCount 1 -ErrorAction SilentlyContinue
  if ($l -match 'sabio-generacion:\s*local') { return 'local' }
  if ($l -match 'sabio-generacion:\s*(\d+)') { return [int]$Matches[1] }
  return 0
}
$bovCmd = if ($boveda) { Join-Path $boveda.FullName "CLAUDE.md" } else { $null }
$artes = @(
  @{ et = "espinazo";       proy = (Join-Path $recursos "00-INDICE-DE-INDICES.md");                 kit = (Join-Path $kit "_federado\00-INDICE-DE-INDICES.md") },
  @{ et = "LEEME Sala B";   proy = (Join-Path $recursos "02-Catalogo\LEEME - Esquema Sala B.md");    kit = (Join-Path $kit "_federado\02-Catalogo\LEEME - Esquema Sala B.md") },
  @{ et = "LEEME Sala C";   proy = (Join-Path $recursos "03-Referencia\LEEME - Esquema Sala C.md");  kit = (Join-Path $kit "_federado\03-Referencia\LEEME - Esquema Sala C.md") },
  @{ et = "LEEME Sala D";   proy = (Join-Path $recursos "04-Aprendizaje\LEEME - Esquema Sala D.md"); kit = (Join-Path $kit "_federado\04-Aprendizaje\LEEME - Esquema Sala D.md") },
  @{ et = "esquema boveda"; proy = $bovCmd;                                                          kit = (Join-Path $kit "_plantilla\CLAUDE.md") }
)
foreach ($a in $artes) {
  if (-not $a.proy) { continue }
  $gc = Get-Gen $a.kit
  $gp = Get-Gen $a.proy
  if ($gp -eq 'local')      { Add-Check "homogeneidad: $($a.et)" "PASS" "opt-out local (intencional)" }
  elseif ($gp -eq -1)       { Add-Check "homogeneidad: $($a.et)" "FAIL" "falta el artefacto" }
  elseif ($gp -ge $gc)      { Add-Check "homogeneidad: $($a.et)" "PASS" "gen $gp (canonica $gc)" }
  else                      { Add-Check "homogeneidad: $($a.et)" "FAIL" "gen $gp < canonica $gc (corre /sabio-converger)" }
}
Check-Existe "buzon de promocion (promociones\)" (Join-Path $recursos "04-Aprendizaje\promociones")
if ($bovCmd -and (Test-Path $bovCmd)) {
  $tb = [System.IO.File]::ReadAllText($bovCmd, [System.Text.Encoding]::UTF8)
  if ($tb -match 'MOC-first') { Add-Check "homogeneidad: navegacion MOC-first" "PASS" }
  else { Add-Check "homogeneidad: navegacion MOC-first" "FAIL" "el esquema de boveda no trae la regla MOC-first" }
}
# Sala D: estado de la unificacion fisica (ESQUEMA estandar en todos)
$esquemaSalaD = Join-Path $recursos "04-Aprendizaje\ESQUEMA.md"
if (Test-Path $esquemaSalaD) { Add-Check "Sala D: forma unificada (ESQUEMA presente)" "PASS" -NoCritico }
else { Add-Check "Sala D: forma unificada (ESQUEMA presente)" "WARN" "perfil base sin ESQUEMA: unificacion fisica pendiente" -NoCritico }

# =====================================================================================
# Resumen
# =====================================================================================
$nPass = @($resultados | Where-Object { $_.Estado -eq "PASS" }).Count
$nFail = @($resultados | Where-Object { $_.Estado -eq "FAIL" -and $_.Critico }).Count
$nWarn = @($resultados | Where-Object { $_.Estado -eq "WARN" }).Count

Write-Host ""
Write-Host "================  TEST DE DESPLIEGUE SABIO  ================" -ForegroundColor Cyan
Write-Host ("  Proyecto : " + $Proyecto)
Write-Host ""
foreach ($r in $resultados) {
  $color = switch ($r.Estado) { "PASS" { "Green" } "FAIL" { "Red" } default { "Yellow" } }
  $linea = "  [{0}] {1}" -f $r.Estado, $r.Nombre
  if ($r.Detalle -and $r.Estado -ne "PASS") { $linea += "  -> " + $r.Detalle }
  Write-Host $linea -ForegroundColor $color
}
Write-Host ""
$colResumen = if ($nFail -eq 0) { "Green" } else { "Red" }
Write-Host ("  RESUMEN: $nPass PASS  |  $nFail FAIL  |  $nWarn WARN") -ForegroundColor $colResumen
if ($nFail -eq 0) {
  Write-Host "  RESULTADO: despliegue EFECTIVO (todos los checks criticos en PASS)." -ForegroundColor Green
} else {
  Write-Host "  RESULTADO: despliegue PARCIAL ($nFail check(s) critico(s) en FAIL)." -ForegroundColor Red
}
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

exit [int]$nFail
