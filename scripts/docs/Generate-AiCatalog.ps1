<#
.SYNOPSIS
  Generate STANDARDS/docs/ai/ai-catalog.json from org markdown banners + path rules.
.PARAMETER MigrateBanners
  Add/update Domain and Capability tokens on classification banners using path heuristics.
.PARAMETER ProjectsRoot
  Parent folder containing STANDARDS, SYSTEM-ADMIN-EAC, SYSTEM-SHARED-UI, Breeze-On-github.
.PARAMETER StandardsRoot
  Override STANDARDS root (default: parent of scripts/docs).
#>
[CmdletBinding()]
param(
  [switch]$MigrateBanners,
  [string]$ProjectsRoot = '',
  [string]$StandardsRoot = ''
)

$ErrorActionPreference = 'Stop'

if (-not $StandardsRoot) {
  $StandardsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
if (-not $ProjectsRoot) {
  $ProjectsRoot = Split-Path $StandardsRoot -Parent
}

$repos = @(
  @{ Name = 'STANDARDS'; Root = $StandardsRoot; Gh = 'STANDARDS' }
  @{ Name = 'SYSTEM-ADMIN-EAC'; Root = (Join-Path $ProjectsRoot 'SYSTEM-ADMIN-EAC'); Gh = 'SYSTEM-ADMIN-EAC' }
  @{ Name = 'SYSTEM-SHARED-UI'; Root = (Join-Path $ProjectsRoot 'SYSTEM-SHARED-UI'); Gh = 'SYSTEM-SHARED-UI' }
  @{ Name = '.github'; Root = (Join-Path $ProjectsRoot 'Breeze-On-github'); Gh = '.github' }
)

function Get-PosixRel([string]$root, [string]$full) {
  return ($full.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/')
}

function Read-Taxonomy([string]$docPath) {
  $text = [System.IO.File]::ReadAllText($docPath)
  if ($text -notmatch '(?s)<!-- AI-CATALOG-TAXONOMY-BEGIN -->(.*?)<!-- AI-CATALOG-TAXONOMY-END -->') {
    throw "Taxonomy block missing in $docPath"
  }
  $block = $Matches[1]
  $domains = @()
  $capabilities = [ordered]@{}
  foreach ($line in ($block -split "`n")) {
    $line = $line.Trim()
    if (-not $line) { continue }
    if ($line -match '^Domains:\s*(.+)$') {
      $domains = @($Matches[1].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
      continue
    }
    if ($line -match '^(\w+):\s*(.+)$') {
      $d = $Matches[1]
      $capabilities[$d] = @($Matches[2].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }
  }
  if ($domains.Count -ne 6) { throw "Expected 6 Domains, found $($domains.Count)" }
  return @{ Domains = $domains; Capabilities = $capabilities }
}

# Entry-point allow-list: repo|path -> @{ Domain; Priority }
$entryPoints = @{
  'STANDARDS|architecture/identity-and-authentication/README.md' = @{ Domain = 'Security'; Priority = 10 }
  'STANDARDS|architecture/authorization/README.md'               = @{ Domain = 'Security'; Priority = 20 }
  'STANDARDS|architecture/landscape.md'                          = @{ Domain = 'Platform'; Priority = 10 }
  'STANDARDS|docs/ui/overview.md'                                = @{ Domain = 'UI'; Priority = 10 }
  'STANDARDS|docs/documentation.md'                              = @{ Domain = 'Engineering'; Priority = 10 }
  'STANDARDS|docs/ai/README.md'                                  = @{ Domain = 'Engineering'; Priority = 20 }
  'STANDARDS|runbooks/README.md'                                 = @{ Domain = 'Operations'; Priority = 10 }
  '.github|profile/README.md'                                    = @{ Domain = 'Org'; Priority = 10 }
}

function Resolve-DomainCapability([string]$repo, [string]$rel) {
  $p = $rel.ToLowerInvariant()

  # Explicit entry hubs
  $key = "$repo|$rel"
  if ($entryPoints.ContainsKey($key)) {
    $ep = $entryPoints[$key]
    $cap = switch ($ep.Domain) {
      'Security' { 'Authentication' }
      'Platform' { 'Applications' }
      'UI' { 'PageDevelopment' }
      'Engineering' { if ($rel -like 'docs/ai/*') { 'AiOnboarding' } else { 'DocStandards' } }
      'Operations' { 'CustomerOnboarding' }
      'Org' { 'OrgProfile' }
      default { 'DocStandards' }
    }
    if ($rel -eq 'architecture/authorization/README.md') { $cap = 'Authorization' }
    if ($rel -eq 'architecture/landscape.md') { $cap = 'Applications' }
    return @{ Domain = $ep.Domain; Capability = $cap }
  }

  if ($repo -eq '.github') { return @{ Domain = 'Org'; Capability = 'OrgProfile' } }

  if ($p -match 'identity-and-authentication|identity-model') {
    return @{ Domain = 'Security'; Capability = 'Authentication' }
  }
  if ($p -match 'authorization|security-model|eac-authorization') {
    return @{ Domain = 'Security'; Capability = 'Authorization' }
  }
  if ($p -match 'security-governance') {
    return @{ Domain = 'Security'; Capability = 'DependencyGovernance' }
  }
  if ($p -match 'architecture/security\.md') {
    return @{ Domain = 'Security'; Capability = 'SqlAccessSecrets' }
  }

  if ($p -match 'data-entities') { return @{ Domain = 'Platform'; Capability = 'DataEntities' } }
  if ($p -match 'process-framework') { return @{ Domain = 'Platform'; Capability = 'ProcessFramework' } }
  if ($p -match 'variables') { return @{ Domain = 'Platform'; Capability = 'Variables' } }
  if ($p -match 'app-configuration|construct-selection|configuration-session') {
    return @{ Domain = 'Platform'; Capability = 'AppConfiguration' }
  }
  if ($p -match 'data-portability') { return @{ Domain = 'Platform'; Capability = 'DataPortability' } }
  if ($p -match 'hosted-deployment') { return @{ Domain = 'Platform'; Capability = 'Hosting' } }
  if ($p -match 'environments') { return @{ Domain = 'Platform'; Capability = 'Environments' } }
  if ($p -match 'local-database|docs/database|db-model|sql/seed') {
    return @{ Domain = 'Platform'; Capability = 'Database' }
  }
  if ($p -match 'application-model') {
    return @{ Domain = 'Engineering'; Capability = 'ApplicationModel' }
  }
  if ($p -match 'architecture/applications') {
    return @{ Domain = 'Platform'; Capability = 'Applications' }
  }

  if ($p -match 'docs/ui/shell|boappshell|nav') { return @{ Domain = 'UI'; Capability = 'ShellNavigation' } }
  if ($p -match 'docs/ui/foundations') { return @{ Domain = 'UI'; Capability = 'Foundations' } }
  if ($p -match 'docs/ui/layout') { return @{ Domain = 'UI'; Capability = 'Layout' } }
  if ($p -match 'docs/ui/controls') { return @{ Domain = 'UI'; Capability = 'Controls' } }
  if ($p -match 'docs/ui/patterns|gallery-index|example-governance|ux-pr-review') {
    return @{ Domain = 'UI'; Capability = 'Patterns' }
  }
  if ($p -match 'page-development|docs/ui/overview|ui-components') {
    return @{ Domain = 'UI'; Capability = 'PageDevelopment' }
  }
  if ($p -match 'public-component-api') { return @{ Domain = 'UI'; Capability = 'PublicComponentApi' } }
  if ($p -match 'docs/ui/') { return @{ Domain = 'UI'; Capability = 'PageDevelopment' } }

  if ($p -match 'ai-agent-governance') { return @{ Domain = 'Engineering'; Capability = 'AgentGovernance' } }
  if ($p -match 'planning-and-development') { return @{ Domain = 'Engineering'; Capability = 'PlanningDevelopmentAgents' } }
  if ($p -match 'docs/ai/') { return @{ Domain = 'Engineering'; Capability = 'AiOnboarding' } }
  if ($p -match 'documentation\.md|review-governance') {
    $cap = if ($p -match 'review-governance') { 'ReviewGovernance' } else { 'DocStandards' }
    return @{ Domain = 'Engineering'; Capability = $cap }
  }
  if ($p -match 'deviations') { return @{ Domain = 'Engineering'; Capability = 'Deviations' } }
  if ($p -match 'docs/adr\.md|decisions/') { return @{ Domain = 'Engineering'; Capability = 'AdrProcess' } }
  if ($p -match 'glossary') { return @{ Domain = 'Engineering'; Capability = 'Glossary' } }
  if ($p -match 'naming') { return @{ Domain = 'Engineering'; Capability = 'Naming' } }
  if ($p -match 'engineering\.md') { return @{ Domain = 'Engineering'; Capability = 'Stack' } }
  if ($p -match 'testing|observability|versioning|domain-modeling') {
    return @{ Domain = 'Engineering'; Capability = 'DocStandards' }
  }
  if ($p -match 'local-development-scripts|templates/') {
    return @{ Domain = 'Engineering'; Capability = 'Stack' }
  }
  if ($p -match 'docs/plans/') { return @{ Domain = 'Engineering'; Capability = 'PlanningDevelopmentAgents' } }

  if ($p -match 'runbooks/.*onboarding|customer-onboarding') {
    return @{ Domain = 'Operations'; Capability = 'CustomerOnboarding' }
  }
  if ($p -match 'runbooks/.*configuration|eac-application-configuration') {
    return @{ Domain = 'Operations'; Capability = 'ConfigPromote' }
  }
  if ($p -match 'runbooks/') { return @{ Domain = 'Operations'; Capability = 'CustomerOnboarding' } }

  if ($p -match 'readme_ai|agents\.md|^readme\.md$') {
    if ($repo -eq 'SYSTEM-ADMIN-EAC') { return @{ Domain = 'Platform'; Capability = 'Applications' } }
    if ($repo -eq 'SYSTEM-SHARED-UI') { return @{ Domain = 'UI'; Capability = 'PublicComponentApi' } }
    return @{ Domain = 'Engineering'; Capability = 'DocStandards' }
  }

  if ($repo -eq 'SYSTEM-ADMIN-EAC') { return @{ Domain = 'Platform'; Capability = 'Applications' } }
  if ($repo -eq 'SYSTEM-SHARED-UI') { return @{ Domain = 'UI'; Capability = 'PublicComponentApi' } }

  return @{ Domain = 'Engineering'; Capability = 'DocStandards' }
}

function Get-Kind([string]$class, [string]$rel) {
  if ($class -eq 'DEC') { return 'Decision' }
  if ($class -eq 'OPS') { return 'Runbook' }
  if ($class -eq 'ENT') { return 'Entry' }
  if ($class -eq 'TPL') { return 'Template' }
  if ($rel -match '^architecture/') { return 'Architecture' }
  if ($rel -match 'docs/ai/(BREEZEON-AI-QUICKSTART|BREEZEON-AI-STANDARDS-SUMMARY|BREEZEON-AI-APPLICATION-ADOPTION|README)') {
    return 'Orientation'
  }
  if ($class -eq 'AN') { return 'Reference' }
  if ($rel -match 'documentation|review-governance|deviations|security-governance') { return 'Governance' }
  if ($rel -match 'architecture/applications/') { return 'Product' }
  return 'Standard'
}

function Get-Status([string]$class, [string]$rel) {
  if ($rel -match 'docs/plans/') { return 'plan' }
  if ($class -eq 'H') { return 'historical' }
  return 'active'
}

function Parse-Banner([string]$text) {
  $m = [regex]::Match($text, '<!--\s*Classification:\s*([^;]+);\s*Scope:\s*([^>;]+?)(?:;\s*Domain:\s*([^;]+);\s*Capability:\s*([^>]+?))?\s*-->')
  if (-not $m.Success) { return $null }
  return @{
    Class      = $m.Groups[1].Value.Trim()
    Scope      = $m.Groups[2].Value.Trim()
    Domain     = if ($m.Groups[3].Success) { $m.Groups[3].Value.Trim() } else { '' }
    Capability = if ($m.Groups[4].Success) { $m.Groups[4].Value.Trim() } else { '' }
    FullMatch  = $m.Value
  }
}

function Get-Owner([string]$text) {
  $m = [regex]::Match($text, '(?m)^Owner:\s*(.+)\s*$')
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}

function Get-GitLastUpdated([string]$repoRoot, [string]$rel) {
  try {
    $iso = & git -C $repoRoot log -1 --format=%cI -- $rel 2>$null
    if ($LASTEXITCODE -eq 0 -and $iso) { return $iso.Trim() }
  } catch { }
  return (Get-Date).ToString('o')
}

function Update-BannerText([string]$text, [string]$domain, [string]$capability) {
  $banner = Parse-Banner $text
  if (-not $banner) { throw 'Missing classification banner' }
  $newBanner = "<!-- Classification: $($banner.Class); Scope: $($banner.Scope); Domain: $domain; Capability: $capability -->"
  if ($banner.Domain -eq $domain -and $banner.Capability -eq $capability) {
    return @{ Text = $text; Changed = $false }
  }
  $newText = $text.Replace($banner.FullMatch, $newBanner)
  return @{ Text = $newText; Changed = $true }
}

$taxonomyPath = Join-Path $StandardsRoot 'docs\documentation.md'
$taxonomy = Read-Taxonomy $taxonomyPath

$documents = New-Object System.Collections.Generic.List[object]
$migrateCount = 0
$errors = New-Object System.Collections.Generic.List[string]

foreach ($r in $repos) {
  if (-not (Test-Path -LiteralPath $r.Root)) {
    Write-Warning "Skip missing repo root: $($r.Root)"
    continue
  }
  $files = Get-ChildItem -LiteralPath $r.Root -Recurse -Filter '*.md' -File |
    Where-Object {
      $_.FullName -notmatch '[\\/]\.git[\\/]' -and
      $_.FullName -notmatch '[\\/]node_modules[\\/]' -and
      $_.FullName -notmatch '[\\/]bin[\\/]' -and
      $_.FullName -notmatch '[\\/]obj[\\/]'
    }

  foreach ($f in $files) {
    $rel = Get-PosixRel $r.Root $f.FullName
    $text = [System.IO.File]::ReadAllText($f.FullName)
    $dc = Resolve-DomainCapability $r.Gh $rel

    if ($MigrateBanners) {
      try {
        $upd = Update-BannerText $text $dc.Domain $dc.Capability
        if ($upd.Changed) {
          [System.IO.File]::WriteAllText($f.FullName, $upd.Text, (New-Object System.Text.UTF8Encoding $false))
          $text = $upd.Text
          $migrateCount++
        }
      } catch {
        $errors.Add("$($r.Gh):$rel — $($_.Exception.Message)")
        continue
      }
    }

    $banner = Parse-Banner $text
    if (-not $banner) {
      $errors.Add("$($r.Gh):$rel — missing classification banner")
      continue
    }

    $domain = if ($banner.Domain) { $banner.Domain } else { $dc.Domain }
    $capability = if ($banner.Capability) { $banner.Capability } else { $dc.Capability }

    if ($taxonomy.Domains -notcontains $domain) {
      $errors.Add("$($r.Gh):$rel — invalid Domain '$domain'")
    } elseif ($taxonomy.Capabilities[$domain] -notcontains $capability) {
      $errors.Add("$($r.Gh):$rel — Capability '$capability' not in Domain '$domain' seed list")
    }

    $epKey = "$($r.Gh)|$rel"
    $isEp = $entryPoints.ContainsKey($epKey)
    $epPri = if ($isEp) { [int]$entryPoints[$epKey].Priority } else { $null }

    # related: same domain+capability siblings filled after first pass — stub empty for now, fill below
    $documents.Add([ordered]@{
      id                 = "$($r.Gh):$rel"
      repository         = $r.Gh
      path               = $rel
      domain             = $domain
      capability         = $capability
      documentType       = $banner.Class
      kind               = Get-Kind $banner.Class $rel
      owner              = Get-Owner $text
      scope              = $banner.Scope
      status             = Get-Status $banner.Class $rel
      isEntryPoint       = $isEp
      entryPointPriority = $epPri
      related            = @()
      relatedAdrs        = @()
      lastUpdated        = Get-GitLastUpdated $r.Root $rel
      _repoRoot          = $r.Root
    })
  }
}

# Fill related (sibling docs same domain+capability, exclude self, cap 12)
$byKey = @{}
foreach ($d in $documents) {
  $k = "$($d.domain)|$($d.capability)"
  if (-not $byKey.ContainsKey($k)) { $byKey[$k] = New-Object System.Collections.Generic.List[string] }
  [void]$byKey[$k].Add($d.id)
}
foreach ($d in $documents) {
  $k = "$($d.domain)|$($d.capability)"
  $sibs = @($byKey[$k] | Where-Object { $_ -ne $d.id } | Select-Object -First 12)
  $d.related = $sibs
  if ($d.path -match 'decisions/ADR-(\d+)') {
    # leave relatedAdrs empty on non-ADR; for ADRs point to decisions/README
  }
  if ($d.documentType -eq 'DEC') {
    $d.relatedAdrs = @($d.id)
  }
}

# Strip private fields
$cleanDocs = @()
foreach ($d in $documents) {
  $cleanDocs += [ordered]@{
    id                 = $d.id
    repository         = $d.repository
    path               = $d.path
    domain             = $d.domain
    capability         = $d.capability
    documentType       = $d.documentType
    kind               = $d.kind
    owner              = $d.owner
    scope              = $d.scope
    status             = $d.status
    isEntryPoint       = [bool]$d.isEntryPoint
    entryPointPriority = $d.entryPointPriority
    related            = @($d.related)
    relatedAdrs        = @($d.relatedAdrs)
    lastUpdated        = $d.lastUpdated
  }
}

$byDomain = [ordered]@{}
$byCapability = [ordered]@{}
$byRepository = [ordered]@{}
$entryPointsByDomain = [ordered]@{}
foreach ($dom in $taxonomy.Domains) {
  $byDomain[$dom] = @($cleanDocs | Where-Object { $_.domain -eq $dom } | ForEach-Object { $_.id })
  $entryPointsByDomain[$dom] = @(
    $cleanDocs |
      Where-Object { $_.domain -eq $dom -and $_.isEntryPoint } |
      Sort-Object { if ($null -eq $_.entryPointPriority) { 999 } else { $_.entryPointPriority } }, path |
      ForEach-Object { $_.id }
  )
}
foreach ($dom in $taxonomy.Domains) {
  foreach ($cap in $taxonomy.Capabilities[$dom]) {
    $byCapability["$dom/$cap"] = @($cleanDocs | Where-Object { $_.domain -eq $dom -and $_.capability -eq $cap } | ForEach-Object { $_.id })
  }
}
foreach ($r in $repos) {
  $byRepository[$r.Gh] = @($cleanDocs | Where-Object { $_.repository -eq $r.Gh } | ForEach-Object { $_.id })
}

foreach ($dom in $taxonomy.Domains) {
  if ($entryPointsByDomain[$dom].Count -lt 1) {
    $errors.Add("Domain '$dom' has no entry point")
  }
}

$catalog = [ordered]@{
  schemaVersion = 1
  generatedAt   = (Get-Date).ToUniversalTime().ToString('o')
  generator     = 'scripts/docs/Generate-AiCatalog.ps1'
  repositories  = @($repos | ForEach-Object { $_.Gh })
  taxonomy      = [ordered]@{
    domains      = @($taxonomy.Domains)
    capabilities = $taxonomy.Capabilities
  }
  documents     = $cleanDocs
  indexes       = [ordered]@{
    byDomain             = $byDomain
    byCapability         = $byCapability
    byRepository         = $byRepository
    entryPointsByDomain  = $entryPointsByDomain
  }
}

$outPath = Join-Path $StandardsRoot 'docs\ai\ai-catalog.json'
$json = $catalog | ConvertTo-Json -Depth 8
# PowerShell ConvertTo-Json can be awkward with ordered; use Newtonsoft-free compact via .NET
Add-Type -AssemblyName System.Web.Extensions -ErrorAction SilentlyContinue | Out-Null
function ConvertTo-JsonDeep($obj) {
  return ($obj | ConvertTo-Json -Depth 20 -Compress:$false)
}
$json = ConvertTo-JsonDeep $catalog
[System.IO.File]::WriteAllText($outPath, $json + "`n", (New-Object System.Text.UTF8Encoding $false))

Write-Host "Migrated banners: $migrateCount"
Write-Host "Documents: $($cleanDocs.Count)"
Write-Host "Wrote $outPath"
if ($errors.Count -gt 0) {
  Write-Host "ERRORS ($($errors.Count)):"
  $errors | ForEach-Object { Write-Host "  $_" }
  exit 1
}
exit 0
