<#
.SYNOPSIS
  Crea un PROYECTO NUEVO completo (Capa 1 + Capa 2) en un solo paso.

.DESCRIPTION
  Hace TODO lo que antes eran pasos separados:
    1. Crea la estructura de carpetas estandar:
         00-Documentacion / 01-Produccion / 02-Desarrollo / 03-Backups / 04-Recursos
    2. Inicializa el repositorio git del proyecto (memoria aislada).
    3. Crea el .gitignore basico.
    4. Crea el CLAUDE.md del proyecto desde la plantilla _proyecto\CLAUDE.md
       (incluye el arbol de carpetas y la regla "Acceso a Obsidian" ya escrita).
    5. Crea 00-Documentacion\00 - LEEME.md.
    6. Crea la boveda de Capa 2 (wiki LLM) copiando la plantilla canonica _plantilla a:
         04-Recursos\01-Vault Obsidian\<NombreBoveda>\
    7. Crea el CEREBRO FEDERADO en 04-Recursos (plantillas de _federado):
         00-INDICE-DE-INDICES.md (namespace de IDs) + 02-Catalogo (Sala B) +
         03-Referencia (Sala C) + 04-Aprendizaje (Sala D), cada una con su LEEME-Esquema.
    8. Si pasas -CentroDeMando, crea el .mcp.json con el MCP sabio-shared (solo-lectura del plano
       GLOBAL de tu Centro de Mando Sabio). Si el .mcp.json ya existe, ANADE sabio-shared sin pisar
       los otros MCP. Si NO pasas -CentroDeMando, el proyecto queda solo-local (sin plano global).
  Es seguro re-ejecutarlo sobre un proyecto existente: NO sobrescribe nada que ya exista
  (solo crea lo que falte).

  Solo Windows (PowerShell). En macOS/Linux, pide a Claude Code que ejecute los pasos equivalentes
  siguiendo INSTALAR.md (copiar los moldes y sustituir los marcadores).

.PARAMETER ProyectoDestino
  Carpeta raiz del proyecto. Por defecto: la carpeta actual. Si no existe, se crea.

.PARAMETER NombreProyecto
  Nombre del proyecto para el CLAUDE.md. Por defecto: el nombre de la carpeta destino.

.PARAMETER NombreBoveda
  Nombre de la boveda Obsidian. Por defecto: "Memoria_" + nombre de la carpeta.

.PARAMETER PerfilSalaD
  Perfil de la Sala D: "base" (default) o "agentico" (anade validador y confianza numerica).

.PARAMETER CentroDeMando
  Ruta raiz de tu Centro de Mando Sabio (el plano global). Si se da, conecta el MCP sabio-shared.
  Si se omite, el proyecto funciona solo con sus Salas locales.

.PARAMETER PythonExe
  Ruta al ejecutable de Python del MCP. Por defecto: <CentroDeMando>\mcp\.venv\Scripts\python.exe

.EXAMPLE
  & ".\Crear-Proyecto.ps1" -ProyectoDestino "C:\Mis Proyectos\Mi App" -CentroDeMando "C:\Centro de Mando Sabio"
#>
[CmdletBinding()]
param(
  [string]$ProyectoDestino = (Get-Location).Path,
  [string]$NombreProyecto = "",
  [string]$NombreBoveda = "",
  [ValidateSet("base", "agentico")]
  [string]$PerfilSalaD = "base",
  [string]$CentroDeMando = "",
  [string]$PythonExe = ""
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)   # UTF-8 sin BOM
$hechos = New-Object System.Collections.Generic.List[string]
$saltos = New-Object System.Collections.Generic.List[string]

# 0) Localizar las plantillas (junto a este script)
$plantillaBoveda   = Join-Path $PSScriptRoot "_plantilla"
$plantillaProyecto = Join-Path $PSScriptRoot "_proyecto\CLAUDE.md"
$plantillaFederado = Join-Path $PSScriptRoot "_federado"
$plantillaPerfilAgentico = Join-Path $PSScriptRoot "_perfiles\agentico"
if (-not (Test-Path $plantillaBoveda))   { throw "No encuentro la plantilla de boveda en: $plantillaBoveda" }
if (-not (Test-Path $plantillaProyecto)) { throw "No encuentro la plantilla de proyecto en: $plantillaProyecto" }
if (-not (Test-Path $plantillaFederado)) { throw "No encuentro la plantilla federada en: $plantillaFederado" }
if ($PerfilSalaD -eq "agentico" -and -not (Test-Path $plantillaPerfilAgentico)) { throw "No encuentro el overlay del perfil agentico en: $plantillaPerfilAgentico" }

# 1) Resolver destino y nombres
if (-not (Test-Path $ProyectoDestino)) {
  New-Item -ItemType Directory -Force -Path $ProyectoDestino | Out-Null
  $hechos.Add("Carpeta del proyecto creada")
}
$ProyectoDestino = (Resolve-Path $ProyectoDestino).Path
$leaf = Split-Path $ProyectoDestino -Leaf
if ([string]::IsNullOrWhiteSpace($NombreProyecto)) { $NombreProyecto = $leaf }
if ([string]::IsNullOrWhiteSpace($NombreBoveda)) {
  $NombreBoveda = "Memoria_" + ($leaf -replace "[^0-9A-Za-z]+", "_")
}
$fecha = Get-Date -Format "yyyy-MM-dd"

# 2) Estructura de carpetas estandar
foreach ($carpeta in @("00-Documentacion", "01-Produccion", "02-Desarrollo", "03-Backups", "04-Recursos")) {
  $p = Join-Path $ProyectoDestino $carpeta
  if (-not (Test-Path $p)) {
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    $hechos.Add("Carpeta $carpeta\ creada")
  } else { $saltos.Add("Carpeta $carpeta\ ya existia") }
}

# 3) Repositorio git aislado
if (-not (Test-Path (Join-Path $ProyectoDestino ".git"))) {
  try {
    & git -C $ProyectoDestino init | Out-Null
    $hechos.Add("Repositorio git inicializado (memoria aislada)")
  } catch {
    $saltos.Add("AVISO: no pude ejecutar git init (esta git instalado?). Hazlo a mano: git init")
  }
} else { $saltos.Add("Repositorio git ya existia") }

# 4) .gitignore basico
$gi = Join-Path $ProyectoDestino ".gitignore"
if (-not (Test-Path $gi)) {
  $contenidoGi = "node_modules/`r`n.env`r`n.env.*`r`ndist/`r`nbuild/`r`n.claude/`r`n.understand-anything/`r`n"
  [System.IO.File]::WriteAllText($gi, $contenidoGi, $utf8)
  $hechos.Add(".gitignore creado")
} else { $saltos.Add(".gitignore ya existia") }

# 5) CLAUDE.md del proyecto (con arbol de carpetas + regla Acceso a Obsidian)
$claudeMd = Join-Path $ProyectoDestino "CLAUDE.md"
if (-not (Test-Path $claudeMd)) {
  $txt = [System.IO.File]::ReadAllText($plantillaProyecto, [System.Text.Encoding]::UTF8)
  $txt = $txt.Replace("<NombreProyecto>", $NombreProyecto).Replace("<NombreBoveda>", $NombreBoveda).Replace("<PerfilSalaD>", $PerfilSalaD)
  [System.IO.File]::WriteAllText($claudeMd, $txt, $utf8)
  $hechos.Add("CLAUDE.md creado (perfil Sala D: $PerfilSalaD; rellena los <RELLENAR> con tus datos)")
} else {
  $txtExistente = [System.IO.File]::ReadAllText($claudeMd, [System.Text.Encoding]::UTF8)
  if ($txtExistente -notmatch "Acceso a Obsidian") {
    $regla = "`r`n## Que es SABIO (la memoria de este proyecto)`r`n" +
      "**SABIO** (*Sistema de Archivos, Bovedas e Indices Organizados*) es el sistema de memoria y conocimiento del proyecto: SIN RAG (gestion de contexto nativa de Claude Code + una boveda-wiki en Obsidian estilo Karpathy), con el conocimiento federado en 4 Salas (A.Investigacion = la boveda . B.Catalogo . C.Referencia . D.Aprendizaje) unidas por el indice de indices (``04-Recursos/00-INDICE-DE-INDICES.md``).`r`n" +
      "`r`n## Acceso a Obsidian`r`n" +
      "- La **unica** boveda de Obsidian que este proyecto puede usar es **$NombreBoveda**, ubicada en ``04-Recursos/01-Vault Obsidian/$NombreBoveda/`` (dentro de la carpeta del proyecto).`r`n" +
      "- El acceso es **nativo**: estando dentro del proyecto, Claude edita los ``.md`` directamente. **No se usa MCP.**`r`n" +
      "- **No** accedas a bovedas, datos ni investigaciones de otros proyectos, ni mezcles su informacion con la de este.`r`n"
    [System.IO.File]::WriteAllText($claudeMd, $txtExistente + $regla, $utf8)
    $hechos.Add("CLAUDE.md ya existia: se anadio la descripcion de SABIO + la regla 'Acceso a Obsidian'")
  } else { $saltos.Add("CLAUDE.md ya existia (con regla de Obsidian incluida)") }
}

# 6) LEEME del proyecto
$leeme = Join-Path $ProyectoDestino "00-Documentacion\00 - LEEME.md"
if (-not (Test-Path $leeme)) {
  $contenidoLeeme = "# $NombreProyecto`r`n`r`n> Escribe aqui UNA linea que explique de que trata el proyecto.`r`n"
  [System.IO.File]::WriteAllText($leeme, $contenidoLeeme, $utf8)
  $hechos.Add("00-Documentacion\00 - LEEME.md creado")
} else { $saltos.Add("00 - LEEME.md ya existia") }

# 7) Boveda de Capa 2 en 04-Recursos\01-Vault Obsidian\<NombreBoveda>
$padre  = Join-Path $ProyectoDestino "04-Recursos\01-Vault Obsidian"
$boveda = Join-Path $padre $NombreBoveda
if (-not (Test-Path $boveda)) {
  New-Item -ItemType Directory -Force -Path $padre | Out-Null
  Copy-Item -Recurse -Path $plantillaBoveda -Destination $boveda
  foreach ($archivo in @("CLAUDE.md", "index.md", "log.md")) {
    $p = Join-Path $boveda $archivo
    $txt = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
    $txt = $txt.Replace("<NombreBoveda>", $NombreBoveda).Replace("<fecha>", $fecha)
    [System.IO.File]::WriteAllText($p, $txt, $utf8)
  }
  $hechos.Add("Boveda Capa 2 creada: 04-Recursos\01-Vault Obsidian\$NombreBoveda\")
} else { $saltos.Add("La boveda ya existia (no se toco): $boveda") }

# 8) Cerebro federado: indice de indices + salas B, C y D en 04-Recursos
$recursos = Join-Path $ProyectoDestino "04-Recursos"
foreach ($pieza in @("00-INDICE-DE-INDICES.md", "02-Catalogo", "03-Referencia", "04-Aprendizaje")) {
  $origen  = Join-Path $plantillaFederado $pieza
  $destino = Join-Path $recursos $pieza
  if (-not (Test-Path $destino)) {
    Copy-Item -Recurse -Path $origen -Destination $destino
    # Sustituir marcadores en los .md copiados
    $mds = @()
    if ((Get-Item $destino) -is [System.IO.DirectoryInfo]) {
      $mds = Get-ChildItem -Path $destino -Recurse -Filter *.md | ForEach-Object { $_.FullName }
    } else { $mds = @($destino) }
    foreach ($md in $mds) {
      $txt = [System.IO.File]::ReadAllText($md, [System.Text.Encoding]::UTF8)
      $txt = $txt.Replace("<NombreProyecto>", $NombreProyecto).Replace("<NombreBoveda>", $NombreBoveda).Replace("<fecha>", $fecha)
      [System.IO.File]::WriteAllText($md, $txt, $utf8)
    }
    $hechos.Add("Federado: 04-Recursos\$pieza creado")
  } else { $saltos.Add("Federado: 04-Recursos\$pieza ya existia") }
}

# 8b) Perfil agentico: superponer el overlay (ESQUEMA.md + tools + ejemplo sintetico), ADD-ONLY
if ($PerfilSalaD -eq "agentico") {
  $overlayAp = Join-Path $plantillaPerfilAgentico "04-Aprendizaje"
  $destAp    = Join-Path $recursos "04-Aprendizaje"
  foreach ($item in (Get-ChildItem -Path $overlayAp -Recurse -File)) {
    $rel = $item.FullName.Substring($overlayAp.Length).TrimStart('\')
    $destFile = Join-Path $destAp $rel
    if (-not (Test-Path $destFile)) {
      New-Item -ItemType Directory -Force -Path (Split-Path $destFile) | Out-Null
      Copy-Item -Path $item.FullName -Destination $destFile
      $hechos.Add("Perfil agentico: 04-Aprendizaje\$rel")
    } else { $saltos.Add("Perfil agentico: 04-Aprendizaje\$rel ya existia") }
  }
}

# 8c) .mcp.json con el MCP sabio-shared (solo-lectura del plano global). ADD-ONLY.
#     Necesita -CentroDeMando (ruta raiz de tu Centro de Mando Sabio). Si no se da, se omite
#     y el proyecto funciona solo con sus Salas locales.
if ([string]::IsNullOrWhiteSpace($CentroDeMando)) {
  $saltos.Add(".mcp.json: sin -CentroDeMando, no se conecta sabio-shared (proyecto solo-local). Puedes anadirlo luego.")
} else {
  $cmRoot = $CentroDeMando.TrimEnd('\', '/')
  $serverPy = Join-Path $cmRoot "mcp\server.py"
  if ([string]::IsNullOrWhiteSpace($PythonExe)) {
    $PythonExe = Join-Path $cmRoot "mcp\.venv\Scripts\python.exe"
  }
  $shared = [PSCustomObject]@{
    command = $PythonExe
    args    = @($serverPy)
    env     = [PSCustomObject]@{ SABIO_GLOBAL_ROOT = $cmRoot }
  }
  $mcpPath = Join-Path $ProyectoDestino ".mcp.json"
  if (-not (Test-Path $mcpPath)) {
    $obj = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{ 'sabio-shared' = $shared } }
    [System.IO.File]::WriteAllText($mcpPath, ($obj | ConvertTo-Json -Depth 10), $utf8)
    $hechos.Add(".mcp.json creado (MCP sabio-shared -> $cmRoot)")
  } else {
    try {
      $mcpObj = Get-Content $mcpPath -Raw | ConvertFrom-Json
      if ($null -eq $mcpObj.mcpServers) {
        $mcpObj | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{})
      }
      if ($null -eq $mcpObj.mcpServers.'sabio-shared') {
        $mcpObj.mcpServers | Add-Member -NotePropertyName 'sabio-shared' -NotePropertyValue $shared
        [System.IO.File]::WriteAllText($mcpPath, ($mcpObj | ConvertTo-Json -Depth 10), $utf8)
        $hechos.Add(".mcp.json ya existia: se anadio sabio-shared (sin pisar otros MCP)")
      } else { $saltos.Add(".mcp.json ya tenia sabio-shared") }
    } catch {
      $saltos.Add("AVISO: .mcp.json existe pero no pude parsearlo; revisa a mano sabio-shared")
    }
  }
}

# 9) Resumen
Write-Host ""
Write-Host "================  PROYECTO LISTO (Capa 1 + Capa 2)  ================" -ForegroundColor Green
Write-Host ("  Proyecto : " + $ProyectoDestino)
Write-Host ("  Boveda   : 04-Recursos\01-Vault Obsidian\" + $NombreBoveda + "  (Sala A)")
Write-Host  "  Federado : 04-Recursos\00-INDICE-DE-INDICES.md + Salas B/C/D con sus esquemas"
Write-Host ""
if ($hechos.Count -gt 0) {
  Write-Host "  HECHO:" -ForegroundColor Green
  foreach ($h in $hechos) { Write-Host ("   + " + $h) }
}
if ($saltos.Count -gt 0) {
  Write-Host "  SIN CAMBIOS (ya existia):" -ForegroundColor Yellow
  foreach ($s in $saltos) { Write-Host ("   - " + $s) }
}
Write-Host ""
Write-Host "  SIGUIENTES PASOS:" -ForegroundColor Cyan
Write-Host "   1. Abre CLAUDE.md y rellena los <RELLENAR> (o pide a Claude que te pregunte)."
Write-Host "   2. Suelta fuentes en la carpeta raw\ de la boveda y di a Claude:"
Write-Host "        compila lo nuevo de raw al wiki"
Write-Host "   3. Para investigar sin subir archivos, usa la Chuleta de Prompts del Kit."
Write-Host ""
Write-Host "  Boveda LOCAL: acceso nativo (sin MCP)." -ForegroundColor Cyan
Write-Host "  Plano GLOBAL: conectado via el MCP sabio-shared (solo-lectura) en .mcp.json (si diste -CentroDeMando)." -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Green
