param(
  [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

$registryPath = Join-Path $RepositoryRoot 'docs/ui_ux_screen_registry.md'
$startMarker = '<!-- PRESENTATION_INVENTORY_START -->'
$endMarker = '<!-- PRESENTATION_INVENTORY_END -->'

$trackedChanges = @{}
git -C $RepositoryRoot status --porcelain | ForEach-Object {
  if ($_.Length -gt 3) {
    $changedPath = $_.Substring(3).Trim('"').Replace('\', '/')
    $trackedChanges[$changedPath] = $true
  }
}

$scanRoots = @(
  'apps/customer_app/lib',
  'apps/staff_app/lib',
  'apps/owner_app/lib',
  'apps/crm_app/lib',
  'packages/shared_core/lib/src/theme',
  'packages/shared_core/lib/src/layout',
  'packages/shared_core/lib/src/widgets',
  'packages/shared_core/lib/src/presentation',
  'packages/shared_auth/lib/src/presentation'
)

function Get-InventoryType([string]$relativePath) {
  $name = [IO.Path]::GetFileNameWithoutExtension($relativePath).ToLowerInvariant()
  $normalized = $relativePath.ToLowerInvariant()

  if ($normalized -match '/theme/' -or $name -match '^(app_colors|app_dimensions|app_fonts|app_text_styles|app_theme)$') { return 'DESIGN_SYSTEM' }
  if ($name -match 'dialog') { return 'DIALOG' }
  if ($name -match 'sheet|profile_sheet') { return 'BOTTOM_SHEET' }
  if ($name -match 'table') { return 'TABLE' }
  if ($name -match 'form|text_field|dropdown|otp_input|phone_input') { return 'FORM' }
  if ($name -match 'loading|empty|error|offline|shimmer|async_state') { return 'STATE' }
  if ($name -match 'navigation|nav|drawer|scaffold|shell|app_bar|top_bar|router|main') { return 'NAVIGATION' }
  if ($name -match '_view$') { return 'SCREEN' }
  if ($name -match '_page$') { return 'PAGE' }
  if ($normalized -match '^packages/') { return 'SHARED_WIDGET' }
  if ($normalized -match '/layout/') { return 'LAYOUT' }
  return 'WIDGET'
}

function Get-AppName([string]$relativePath) {
  if ($relativePath -match '^apps/([^/]+)/') { return $Matches[1] }
  if ($relativePath -match '^packages/([^/]+)/') { return $Matches[1] }
  return 'shared'
}

function Get-ModuleName([string]$relativePath) {
  if ($relativePath -match '/features/([^/]+)/') { return $Matches[1] }
  if ($relativePath -match '/src/([^/]+)/') { return $Matches[1] }
  if ($relativePath -match '/core/([^/]+)/') { return "core/$($Matches[1])" }
  return 'application'
}

function Get-ComponentName([string]$absolutePath) {
  $source = Get-Content -Raw -LiteralPath $absolutePath
  $matches = [regex]::Matches($source, '(?:abstract\s+final\s+)?class\s+([A-Z][A-Za-z0-9_]*)')
  $names = @($matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique -First 3)
  if ($names.Count -gt 0) { return ($names -join ', ') }
  return [IO.Path]::GetFileNameWithoutExtension($absolutePath)
}

$inventory = foreach ($scanRoot in $scanRoots) {
  $absoluteRoot = Join-Path $RepositoryRoot $scanRoot
  if (-not (Test-Path -LiteralPath $absoluteRoot)) { continue }

  Get-ChildItem -LiteralPath $absoluteRoot -Filter '*.dart' -File -Recurse | Where-Object {
    $normalized = $_.FullName.Replace('\', '/')
    $isProvider = $normalized -match '/providers?/' -or $_.BaseName -match '_provider$|_providers$'
    $isPresentation = $normalized -match '/presentation/'
    $isAppEntry = $normalized -match '/lib/main\.dart$|/lib/core/router/'
    $isSharedSurface = $normalized -match '/shared_core/lib/src/(theme|layout|widgets|presentation)/'
    (-not $isProvider) -and ($isPresentation -or $isAppEntry -or $isSharedSurface)
  } | ForEach-Object {
    $relative = $_.FullName.Substring($RepositoryRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
    $source = Get-Content -Raw -LiteralPath $_.FullName
    $responsive = if ($source -match 'AppResponsive|context\.adaptive|context\.isCompact|LayoutBuilder|MediaQuery') {
      'Implemented; visual QA pending'
    } else {
      'Review required'
    }
    $phaseOneVerified = $relative -match '^packages/shared_core/lib/src/theme/(app_colors|app_dimensions|app_fonts|app_motion|app_text_styles|app_theme)\.dart$'
    $phaseTwoVerified = $relative -match '^packages/shared_core/lib/src/widgets/' -or $relative -eq 'packages/shared_core/lib/src/presentation/async_state.dart'
    $phaseThreeVerified = $relative -match '^packages/shared_core/lib/src/layout/(app_responsive|app_adaptive_navigation)\.dart$'
    $phaseFourImplemented = $relative -match '^apps/customer_app/lib/features/customer/presentation/widgets/customer_scaffold\.dart$' -or
      $relative -match '^apps/owner_app/lib/features/dashboard/presentation/widgets/(dashboard_body|owner_app_bar|owner_bottom_nav)\.dart$' -or
      $relative -match '^apps/crm_app/lib/features/crm_dashboard/presentation/(crm_dashboard_view|widgets/crm_app_bar|widgets/crm_drawer)\.dart$' -or
      $relative -match '^apps/staff_app/lib/features/(advisor/presentation/pages/advisor_home_view|supervisor/presentation/widgets/supervisor_scaffold|technician/presentation/technician_dashboard_view|technician/presentation/widgets/technician_header_widget)\.dart$'
    $phaseFiveVerified = $relative -match '^packages/shared_auth/lib/src/presentation/(pages|widgets)/.+\.dart$' -or
      $relative -eq 'apps/staff_app/lib/features/supervisor/presentation/supervisor_login_view.dart'
    [pscustomobject]@{
      App = Get-AppName $relative
      Module = Get-ModuleName $relative
      File = $relative
      Component = Get-ComponentName $_.FullName
      Type = Get-InventoryType $relative
      Current = if ($trackedChanges.ContainsKey($relative)) { 'Existing; modified worktree' } else { 'Existing' }
      Redesign = if ($phaseOneVerified -or $phaseTwoVerified -or $phaseThreeVerified -or $phaseFiveVerified) {
        'VERIFIED'
      } elseif ($phaseFourImplemented) {
        'IMPLEMENTED'
      } else {
        'ANALYZING'
      }
      Responsive = if ($phaseOneVerified) {
        'Central token; viewport independent'
      } elseif ($phaseTwoVerified) {
        'Component contract verified; app QA pending'
      } elseif ($phaseThreeVerified) {
        '10 target widths tested; tablet/desktop goldens'
      } elseif ($phaseFourImplemented) {
        'Compact bottom navigation and wide navigation rail visually verified'
      } elseif ($phaseFiveVerified) {
        'Mobile form flow and desktop split composition visually verified'
      } else {
        $responsive
      }
      Tested = if ($phaseOneVerified) {
        'Analyzer, unit tests, visual golden'
      } elseif ($phaseTwoVerified) {
        'Analyzer, component tests, visual golden'
      } elseif ($phaseThreeVerified) {
        'Analyzer, breakpoint tests, overflow tests, visual goldens'
      } elseif ($phaseFourImplemented) {
        'Analyzer, navigation widget tests, compact/rail shell goldens; feature QA pending'
      } elseif ($phaseFiveVerified) {
        'Analyzer, auth state/interaction tests, responsive visual goldens'
      } else {
        'Not yet phase-verified'
      }
    }
  }
}

$inventory = @($inventory | Sort-Object App, Module, File -Unique)
$typeSummary = $inventory | Group-Object Type | Sort-Object Name
$appSummary = $inventory | Group-Object App | Sort-Object Name

$lines = [Collections.Generic.List[string]]::new()
$lines.Add($startMarker)
$lines.Add('')
$lines.Add('## Phase 0 — Complete Presentation Inventory')
$lines.Add('')
$lines.Add('This inventory is generated from the Flutter presentation source tree. `ANALYZING` means the item has been discovered but has not passed the strict redesign, rendered visual QA, responsive QA, and functional QA gates in the current phase-wise initiative.')
$lines.Add('')
$lines.Add("Inventory total: **$($inventory.Count) presentation files**.")
$lines.Add('')
$lines.Add('### Inventory summary')
$lines.Add('')
$lines.Add('| Group | Count |')
$lines.Add('|---|---:|')
foreach ($group in $appSummary) { $lines.Add("| $($group.Name) | $($group.Count) |") }
foreach ($group in $typeSummary) { $lines.Add("| Type: $($group.Name) | $($group.Count) |") }
$lines.Add('')
$lines.Add('### File-level registry')
$lines.Add('')
$lines.Add('| App | Module | File | Component | Type | Current Status | Redesign Status | Responsive | Tested |')
$lines.Add('|---|---|---|---|---|---|---|---|---|')
foreach ($item in $inventory) {
  $component = $item.Component.Replace('|', '\|')
  $lines.Add("| $($item.App) | $($item.Module) | ``$($item.File)`` | $component | $($item.Type) | $($item.Current) | $($item.Redesign) | $($item.Responsive) | $($item.Tested) |")
}
$lines.Add('')
$lines.Add($endMarker)

$existing = Get-Content -Raw -LiteralPath $registryPath
$generated = $lines -join [Environment]::NewLine
if ($existing.Contains($startMarker) -and $existing.Contains($endMarker)) {
  $pattern = [regex]::Escape($startMarker) + '.*?' + [regex]::Escape($endMarker)
  $updated = [regex]::Replace($existing, $pattern, $generated, [Text.RegularExpressions.RegexOptions]::Singleline)
} else {
  $updated = $existing.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $generated + [Environment]::NewLine
}

Set-Content -LiteralPath $registryPath -Value $updated -Encoding utf8
Write-Output "Updated $registryPath with $($inventory.Count) presentation files."
