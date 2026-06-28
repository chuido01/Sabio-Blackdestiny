<#
.SYNOPSIS
  Propaga (idempotente, ADD-ONLY) los activos TRANSVERSALES del Kit a proyectos EXISTENTES.

.DESCRIPTION
  El "update" del entorno: lleva el estandar del Kit a uno o varios proyectos que ya existen,
  SIN pisar nada local. Propaga:
    - estructura de 5 carpetas (00-Documentacion / 01-Produccion / 02-Desarrollo / 03-Backups / 04-Recursos),
    - esquemas de las Salas federadas (00-INDICE-DE-INDICES.md + 02/03/04 de 04-Recursos),
    - plantilla de nota atomica de la boveda,
    - lineas estandar de .gitignore,
    - el .mcp.json con el MCP sabio-shared (solo-lectura del plano global; ADD-ONLY; si das -CentroDeMando),
    - las secciones transversales del CLAUDE.md (SABIO + Acceso a la bóveda + aislamiento).
  Garantias:
    - NUNCA sobrescribe archivos existentes ni contenido del proyecto (notas, codigo, indices poblados).
    - Solo CREA lo que falta y APENDE lineas estandar que falten (.gitignore / CLAUDE.md).
    - La restriccion de aislamiento del destino es INMUTABLE: se escribe/preserva, nunca se debilita.
  Por defecto es DRY-RUN (solo reporta). Usa -Aplicar para escribir.

  Solo Windows (PowerShell). En macOS/Linux, pide a Claude Code los pasos equivalentes (INSTALAR.md).

.PARAMETER Destino
  Ruta de UN proyecto a actualizar.

.PARAMETER Todos
  Actualiza TODOS los proyectos bajo -RaizProyectos.

.PARAMETER RaizProyectos
  Carpeta padre donde viven tus proyectos (obligatoria con -Todos).

.PARAMETER CentroDeMando
  Ruta raiz de tu Centro de Mando Sabio (plano global). Si se da, conecta el MCP sabio-shared.

.PARAMETER PythonExe
  Ruta al ejecutable de Python del MCP. Por defecto: <CentroDeMando>\mcp\.venv\Scripts\python.exe

.PARAMETER Aplicar
  Sin este switch = DRY-RUN (no escribe). Con -Aplicar = aplica los cambios.

.EXAMPLE
  & ".\Actualizar-Proyecto.ps1" -Destino "C:\Mis Proyectos\Mi App"
  # Dry-run sobre un proyecto: muestra que propagaria.

.EXAMPLE
  & ".\Actualizar-Proyecto.ps1" -Todos -RaizProyectos "C:\Mis Proyectos" -CentroDeMando "C:\Centro de Mando Sabio" -Aplicar
#>
[CmdletBinding()]
param(
  [string]$Destino = "",
  [switch]$Todos,
  [string]$RaizProyectos = "",
  [string]$CentroDeMando = "",
  [string]$PythonExe = "",
  [switch]$Aplicar
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$modo = if ($Aplicar) { "APLICAR" } else { "DRY-RUN (solo reporta; usa -Aplicar para escribir)" }

# 0) Plantillas (junto a este script)
$plantillaBoveda   = Join-Path $PSScriptRoot "_plantilla"
$plantillaProyecto = Join-Path $PSScriptRoot "_proyecto\CLAUDE.md"
$plantillaFederado = Join-Path $PSScriptRoot "_federado"
foreach ($p in @($plantillaBoveda, $plantillaProyecto, $plantillaFederado)) {
  if (-not (Test-Path $p)) { throw "No encuentro la plantilla del Kit: $p" }
}

# --- Convergencia generacional (re-proyeccion del molde canonico) ---
# Compara el sello `<!-- sabio-generacion: N -->` del Kit vs el del proyecto y re-proyecta lo atrasado.
# PUROS: se sobrescriben enteros. MIXTOS: se reemplaza SOLO la region entre <!-- sabio:canonico:inicio -->
# y <!-- sabio:canonico:fin -->, preservando lo local. Un mixto sin marcadores NO se toca (migracion manual).
$reCanon = '(?s)<!-- sabio:canonico:inicio.*?<!-- sabio:canonico:fin -->'
$reSello = '<!-- sabio-generacion:\s*\d+ -->'
function Get-SabioGen([string]$ruta) {
  if (-not (Test-Path $ruta)) { return -1 }
  $primera = Get-Content -LiteralPath $ruta -TotalCount 1 -ErrorAction SilentlyContinue
  if ($primera -match 'sabio-generacion:\s*local') { return 2147483647 }  # opt-out: nunca se converge
  if ($primera -match 'sabio-generacion:\s*(\d+)') { return [int]$Matches[1] }
  return 0
}
function Convert-Marcadores([string]$texto, [string]$proy, [string]$bov, [string]$fch) {
  return $texto.Replace("<NombreProyecto>", $proy).Replace("<NombreBoveda>", $bov).Replace("<fecha>", $fch)
}
$artefactosFederado = @(
  @{ rel = "00-INDICE-DE-INDICES.md"; tipo = "mixto" },
  @{ rel = "02-Catalogo\LEEME - Esquema Sala B.md"; tipo = "puro" },
  @{ rel = "03-Referencia\LEEME - Esquema Sala C.md"; tipo = "mixto" },
  @{ rel = "04-Aprendizaje\LEEME - Esquema Sala D.md"; tipo = "puro" },
  @{ rel = "04-Aprendizaje\ESQUEMA.md"; tipo = "puro" },
  @{ rel = "04-Aprendizaje\promociones\LEEME - Buzon de promocion.md"; tipo = "puro" }
)

# 1) Resolver objetivos (gobernanza: nada sin destino explicito)
$objetivos = @()
if ($Todos) {
  if ([string]::IsNullOrWhiteSpace($RaizProyectos)) { throw "Con -Todos debes indicar -RaizProyectos <ruta>." }
  if (-not (Test-Path $RaizProyectos)) { throw "No existe la raiz de proyectos: $RaizProyectos" }
  $objetivos = Get-ChildItem -Path $RaizProyectos -Directory |
    Where-Object { (Test-Path (Join-Path $_.FullName ".git")) -or (Test-Path (Join-Path $_.FullName "CLAUDE.md")) } |
    Select-Object -ExpandProperty FullName
} elseif ($Destino) {
  if (-not (Test-Path $Destino)) { throw "No existe el destino: $Destino" }
  $objetivos = @((Resolve-Path $Destino).Path)
} else {
  throw "Indica -Destino <ruta> o -Todos -RaizProyectos <ruta>. (Gobernanza: no se actualiza nada sin destino explicito.)"
}

$carpetasEstandar = @("00-Documentacion", "01-Produccion", "02-Desarrollo", "03-Backups", "04-Recursos")
$giEstandar = @(
  "node_modules/", ".env", ".env.*", "dist/", "build/", ".claude/", ".understand-anything/",
  "03-Backups/**/*.zip", "03-Backups/**/*.tgz", "03-Backups/**/*.7z"
)
$fecha = Get-Date -Format "yyyy-MM-dd"

# Bloque MCP reutilizable (solo si se dio -CentroDeMando)
$mcpShared = $null
if (-not [string]::IsNullOrWhiteSpace($CentroDeMando)) {
  $cmRoot = $CentroDeMando.TrimEnd('\', '/')
  $serverPy = Join-Path $cmRoot "mcp\server.py"
  if ([string]::IsNullOrWhiteSpace($PythonExe)) { $PythonExe = Join-Path $cmRoot "mcp\.venv\Scripts\python.exe" }
  $mcpShared = [PSCustomObject]@{
    command = $PythonExe
    args    = @($serverPy)
    env     = [PSCustomObject]@{ SABIO_GLOBAL_ROOT = $cmRoot }
  }
}

Write-Host ""
Write-Host "================  Actualizar-Proyecto :: $modo  ================" -ForegroundColor Cyan
Write-Host ("  Objetivos: " + $objetivos.Count)

$totalHechos = 0
foreach ($proy in $objetivos) {
  $nombre = Split-Path $proy -Leaf
  $hechos = New-Object System.Collections.Generic.List[string]
  $saltos = 0

  # a) Carpetas estandar
  foreach ($c in $carpetasEstandar) {
    $cp = Join-Path $proy $c
    if (-not (Test-Path $cp)) {
      if ($Aplicar) { New-Item -ItemType Directory -Force -Path $cp | Out-Null }
      $hechos.Add("+ carpeta $c\")
    } else { $saltos++ }
  }

  # b) .gitignore: apendar lineas estandar que falten (nunca quita las locales)
  $gi = Join-Path $proy ".gitignore"
  $giActual = if (Test-Path $gi) { [System.IO.File]::ReadAllText($gi, [System.Text.Encoding]::UTF8) } else { "" }
  $giLineas = $giActual -split "`r?`n"
  $faltan = @()
  foreach ($l in $giEstandar) { if ($giLineas -notcontains $l) { $faltan += $l } }
  if ($faltan.Count -gt 0) {
    if ($Aplicar) {
      $sep = if ($giActual.Length -gt 0 -and -not $giActual.EndsWith("`n")) { "`r`n" } else { "" }
      $bloque = $sep + "`r`n# (Actualizar-Proyecto) estandar transversal del Kit`r`n" + ($faltan -join "`r`n") + "`r`n"
      [System.IO.File]::AppendAllText($gi, $bloque, $utf8)
    }
    $hechos.Add("+ .gitignore: " + $faltan.Count + " linea(s) estandar")
  } else { $saltos++ }

  # c) Cerebro federado: piezas que falten en 04-Recursos
  $recursos = Join-Path $proy "04-Recursos"
  if (-not (Test-Path $recursos) -and $Aplicar) { New-Item -ItemType Directory -Force -Path $recursos | Out-Null }
  $nombreBoveda = ""
  $vaultPadre = Join-Path $recursos "01-Boveda"
  if (Test-Path $vaultPadre) {
    $b = Get-ChildItem -Path $vaultPadre -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($b) { $nombreBoveda = $b.Name }
  }
  foreach ($pieza in @("00-INDICE-DE-INDICES.md", "02-Catalogo", "03-Referencia", "04-Aprendizaje")) {
    $destPieza = Join-Path $recursos $pieza
    if (-not (Test-Path $destPieza)) {
      if ($Aplicar) {
        Copy-Item -Recurse -Path (Join-Path $plantillaFederado $pieza) -Destination $destPieza
        $mds = if ((Get-Item $destPieza) -is [System.IO.DirectoryInfo]) {
          Get-ChildItem -Path $destPieza -Recurse -Filter *.md | ForEach-Object { $_.FullName }
        } else { @($destPieza) }
        foreach ($md in $mds) {
          $t = [System.IO.File]::ReadAllText($md, [System.Text.Encoding]::UTF8)
          $t = $t.Replace("<NombreProyecto>", $nombre).Replace("<NombreBoveda>", $nombreBoveda).Replace("<fecha>", $fecha)
          [System.IO.File]::WriteAllText($md, $t, $utf8)
        }
      }
      $hechos.Add("+ federado 04-Recursos\$pieza")
    } else { $saltos++ }
  }

  # d) Plantilla de nota atomica en la boveda (si existe boveda)
  if ($nombreBoveda) {
    $tplDest = Join-Path $vaultPadre (Join-Path $nombreBoveda "templates\_plantilla-nota-atomica.md")
    $tplOrig = Join-Path $plantillaBoveda "templates\_plantilla-nota-atomica.md"
    if ((Test-Path $tplOrig) -and -not (Test-Path $tplDest)) {
      if ($Aplicar) {
        New-Item -ItemType Directory -Force -Path (Split-Path $tplDest) | Out-Null
        Copy-Item -Path $tplOrig -Destination $tplDest
      }
      $hechos.Add("+ plantilla de nota atomica en la boveda")
    } else { $saltos++ }
  }

  # e) CLAUDE.md: secciones transversales (ADD-ONLY; reusa la regla de Crear-Proyecto)
  $claudeMd = Join-Path $proy "CLAUDE.md"
  if (Test-Path $claudeMd) {
    $txt = [System.IO.File]::ReadAllText($claudeMd, [System.Text.Encoding]::UTF8)
    if ($txt -notmatch "Acceso a la bóveda") {
      if ($Aplicar) {
        $nb = if ($nombreBoveda) { $nombreBoveda } else { "<NombreBoveda>" }
        $regla = "`r`n## Que es SABIO (la memoria de este proyecto)`r`n" +
          "**SABIO** (*Sistema de Archivos, Bovedas e Indices Organizados*) es el sistema de memoria y conocimiento del proyecto: SIN RAG (gestion de contexto nativa + boveda-wiki estilo Karpathy), federado en 4 Salas (A.Investigacion = la boveda . B.Catalogo . C.Referencia . D.Aprendizaje) unidas por el indice de indices (``04-Recursos/00-INDICE-DE-INDICES.md``).`r`n" +
          "`r`n## Acceso a la bóveda`r`n" +
          "- La **unica** boveda que este proyecto puede usar es **$nb**, ubicada en ``04-Recursos/01-Boveda/$nb/`` (dentro de la carpeta del proyecto).`r`n" +
          "- El acceso es **nativo** (sin MCP). **No** accedas a bovedas, datos ni investigaciones de otros proyectos, ni mezcles su informacion con la de este.`r`n"
        [System.IO.File]::AppendAllText($claudeMd, $regla, $utf8)
      }
      $hechos.Add("+ CLAUDE.md: seccion SABIO + Acceso a la bóveda")
    } else { $saltos++ }
  } else {
    $hechos.Add("! CLAUDE.md ausente (este updater NO lo crea; usa Crear-Proyecto.ps1 para bootstrap)")
  }

  # e2) CLAUDE.md: puntero al comando /disenar (ADD-ONLY)
  if (Test-Path $claudeMd) {
    $txtD = [System.IO.File]::ReadAllText($claudeMd, [System.Text.Encoding]::UTF8)
    if ($txtD -notmatch '/disenar') {
      if ($Aplicar) {
        $ptr = "`r`n" +
          '## Decisiones de diseno - comando `/disenar`' + "`r`n" +
          '- Ante una **duda de diseno** (abstraer o duplicar?, anadir capas/DDD/Clean Arch o mantener simple?), invoca **`/disenar`**: secuencia KISS/YAGNI -> DRY/SOLID/DDD -> Clean Arch, **Regla de Tres** como dial, **legibilidad** como desempate, y devuelve una recomendacion con su porque. El comando es **global** (`~/.claude/commands/`); no se copia dentro del proyecto.' + "`r`n"
        [System.IO.File]::AppendAllText($claudeMd, $ptr, $utf8)
      }
      $hechos.Add("+ CLAUDE.md: puntero al comando /disenar")
    } else { $saltos++ }
  }

  # f) Sala D unificada: ESQUEMA.md + tools/ + promociones/ son estandar (vienen en _federado, ya cubiertos
  #    por el bloque federado de arriba y por la convergencia 'h'). El perfil 'agentico' es solo un FLAG en
  #    el CLAUDE.md del proyecto, no otra estructura: no se superpone nada.

  # g) .mcp.json con el MCP sabio-shared (ADD-ONLY; no pisa otros MCP). Solo si se dio -CentroDeMando.
  if ($null -ne $mcpShared) {
    $mcpPath = Join-Path $proy ".mcp.json"
    if (-not (Test-Path $mcpPath)) {
      if ($Aplicar) {
        $obj = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{ 'sabio-shared' = $mcpShared } }
        [System.IO.File]::WriteAllText($mcpPath, ($obj | ConvertTo-Json -Depth 10), $utf8)
      }
      $hechos.Add("+ .mcp.json (MCP sabio-shared)")
    } else {
      try {
        $mcpObj = Get-Content $mcpPath -Raw | ConvertFrom-Json
        if ($null -eq $mcpObj.mcpServers -or $null -eq $mcpObj.mcpServers.'sabio-shared') {
          if ($Aplicar) {
            if ($null -eq $mcpObj.mcpServers) {
              $mcpObj | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{})
            }
            $mcpObj.mcpServers | Add-Member -NotePropertyName 'sabio-shared' -NotePropertyValue $mcpShared
            [System.IO.File]::WriteAllText($mcpPath, ($mcpObj | ConvertTo-Json -Depth 10), $utf8)
          }
          $hechos.Add("+ .mcp.json: sabio-shared (sin pisar otros MCP)")
        } else { $saltos++ }
      } catch { $saltos++ }
    }
  }

  # h) CONVERGENCIA generacional: re-proyectar artefactos canonicos atrasados (preserva lo local)
  $convItems = @()
  foreach ($a in $artefactosFederado) {
    $convItems += @{ canon = (Join-Path $plantillaFederado $a.rel); dest = (Join-Path $recursos $a.rel); tipo = $a.tipo }
  }
  if ($nombreBoveda) {
    $convItems += @{ canon = (Join-Path $plantillaBoveda "CLAUDE.md"); dest = (Join-Path $vaultPadre (Join-Path $nombreBoveda "CLAUDE.md")); tipo = "mixto" }
  }
  foreach ($c in $convItems) {
    if (-not (Test-Path $c.canon)) { continue }
    $genCanon = Get-SabioGen $c.canon
    $genProy  = Get-SabioGen $c.dest
    $relName  = Split-Path $c.dest -Leaf
    if ($genProy -eq -1) { continue }                       # ausente: lo cubre el bloque ADD-ONLY de arriba
    if ($genProy -ge $genCanon) { $saltos++; continue }     # al dia
    $canonTxt = [System.IO.File]::ReadAllText($c.canon, [System.Text.Encoding]::UTF8)
    $canonTxt = Convert-Marcadores $canonTxt $nombre $nombreBoveda $fecha
    if ($c.tipo -eq "puro") {
      if ($Aplicar) { [System.IO.File]::WriteAllText($c.dest, $canonTxt, $utf8) }
      $hechos.Add("~ convergido (puro) $relName  [gen $genProy -> $genCanon]")
    } else {
      $proyTxt = [System.IO.File]::ReadAllText($c.dest, [System.Text.Encoding]::UTF8)
      if ($proyTxt -notmatch $reCanon) {
        $hechos.Add("! $relName gen $genProy SIN marcadores -> requiere migracion inicial (manual); NO se toca")
        continue
      }
      $regionCanon = [regex]::Match($canonTxt, $reCanon).Value
      $evaluador = [System.Text.RegularExpressions.MatchEvaluator]{ param($mm) $regionCanon }
      $nuevo = [regex]::Replace($proyTxt, $reCanon, $evaluador)
      if ($nuevo -match $reSello) {
        $selloEval = [System.Text.RegularExpressions.MatchEvaluator]{ param($mm) ("<!-- sabio-generacion: " + $genCanon + " -->") }
        $nuevo = [regex]::Replace($nuevo, $reSello, $selloEval)
      } else {
        $nuevo = "<!-- sabio-generacion: $genCanon -->`r`n" + $nuevo
      }
      if ($Aplicar) { [System.IO.File]::WriteAllText($c.dest, $nuevo, $utf8) }
      $hechos.Add("~ convergido (mixto, region canonica) $relName  [gen $genProy -> $genCanon]")
    }
  }

  # Reporte por proyecto
  $totalHechos += $hechos.Count
  if ($hechos.Count -gt 0) {
    Write-Host ""
    Write-Host ("  [$nombre]") -ForegroundColor Yellow
    foreach ($h in $hechos) { Write-Host ("     " + $h) }
    Write-Host ("     (sin cambios en $saltos comprobaciones)") -ForegroundColor DarkGray
  } else {
    Write-Host ("  [$nombre] ya conforme (sin cambios)") -ForegroundColor Green
  }
}

Write-Host ""
if ($Aplicar) {
  Write-Host ("  HECHO. Cambios aplicados (total): $totalHechos") -ForegroundColor Green
} else {
  Write-Host ("  DRY-RUN. Cambios que se aplicarian (total): $totalHechos. Re-ejecuta con -Aplicar para escribir.") -ForegroundColor Cyan
}
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
