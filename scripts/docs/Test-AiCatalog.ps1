<#
.SYNOPSIS
  Validate AI catalog: regenerate and require zero meaningful drift; enforce taxonomy + entry points.
#>
[CmdletBinding()]
param(
  [string]$ProjectsRoot = '',
  [string]$StandardsRoot = ''
)

$ErrorActionPreference = 'Stop'

if (-not $StandardsRoot) {
  $StandardsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$catalogPath = Join-Path $StandardsRoot 'docs\ai\ai-catalog.json'
if (-not (Test-Path -LiteralPath $catalogPath)) {
  Write-Error "Missing catalog: $catalogPath — run Generate-AiCatalog.ps1 first"
  exit 1
}

$before = [System.IO.File]::ReadAllText($catalogPath)

$gen = Join-Path $PSScriptRoot 'Generate-AiCatalog.ps1'
& $gen -StandardsRoot $StandardsRoot -ProjectsRoot $ProjectsRoot
if ($LASTEXITCODE -ne 0) {
  Write-Error 'Generate-AiCatalog.ps1 failed'
  exit 1
}

$after = [System.IO.File]::ReadAllText($catalogPath)

function Get-CatalogCore([string]$jsonText) {
  $obj = $jsonText | ConvertFrom-Json
  # Ignore generatedAt timestamp for drift comparison
  $obj.generatedAt = 'IGNORED'
  foreach ($d in $obj.documents) {
    if ($null -ne $d.lastUpdated) { $d.lastUpdated = 'IGNORED' }
  }
  return ($obj | ConvertTo-Json -Depth 20)
}

$coreBefore = Get-CatalogCore $before
$coreAfter = Get-CatalogCore $after

if ($coreBefore -ne $coreAfter) {
  Write-Error 'ai-catalog.json is stale relative to banners/paths. Commit the regenerated catalog (ignore generatedAt/lastUpdated-only noise if present — structural drift detected).'
  exit 1
}

# Entry-point coverage
$obj = $after | ConvertFrom-Json
foreach ($dom in $obj.taxonomy.domains) {
  $eps = @($obj.indexes.entryPointsByDomain.$dom)
  if ($eps.Count -lt 1) {
    Write-Error "Domain '$dom' has no entry points"
    exit 1
  }
}

Write-Host "AI catalog validation OK ($($obj.documents.Count) documents)."
exit 0
