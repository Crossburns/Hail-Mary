Param(
  [string]$OutFile = "code/modules/f13/mojave_sprite_catalog.dm"
)

$sourceDirs = @(
  "mojave/structures",
  "mojave/turfs",
  "mojave/effects"
)

$allowedProps = @{
  name = $true
  desc = $true
  icon = $true
  icon_state = $true
  anchored = $true
  density = $true
  opacity = $true
  pixel_x = $true
  pixel_y = $true
  parent_type = $true
}

function IsSimpleValue([string]$val) {
  if ([string]::IsNullOrWhiteSpace($val)) { return $false }
  if ($val -match '[\[\]\(\)\{\}]') { return $false }
  if ($val -match '\+\+|--') { return $false }
  if ($val -match '\b(new|list|pick|rand|prob)\b') { return $false }
  return $true
}

function IsSafeQuotedString([string]$val) {
  if ([string]::IsNullOrWhiteSpace($val)) { return $false }
  if ($val.Length -lt 2) { return $false }
  if ($val[0] -ne '"' -or $val[$val.Length-1] -ne '"') { return $false }
  if ($val -match '\\') { return $false }
  $q = ($val.ToCharArray() | Where-Object { $_ -eq '"' }).Count
  if ($q -ne 2) { return $false }
  return $true
}

function IsSafeNumberOrBool([string]$val) {
  if ([string]::IsNullOrWhiteSpace($val)) { return $false }
  if ($val -match '^(TRUE|FALSE)$') { return $true }
  if ($val -match '^[+-]?\d+(\.\d+)?$') { return $true }
  return $false
}

function IsAllowedIcon([string]$iconPath) {
  if (-not $iconPath.StartsWith("'mojave/icons/")) { return $false }
  if ($iconPath -match "/decals/") { return $true }
  if ($iconPath -match "/turf/") { return $true }
  if ($iconPath -match "/structure/") { return $true }
  if ($iconPath -match "/obstacles/") { return $true }
  if ($iconPath -match "/flora/") { return $true }
  if ($iconPath -match "/objects/") {
    $excluded = @(
      "/objects/ammo/",
      "/objects/guns/",
      "/objects/melee/",
      "/objects/projectiles/",
      "/objects/throwables/",
      "/objects/organs/",
      "/objects/medical/",
      "/objects/drugs/",
      "/objects/food/",
      "/objects/currency/",
      "/objects/clothing/",
      "/objects/tools/",
      "/objects/pa_items/",
      "/objects/crafting/",
      "/objects/smokeables/",
      "/objects/identification/"
    )
    foreach ($p in $excluded) {
      if ($iconPath -match [regex]::Escape($p)) { return $false }
    }
    if ($iconPath -match "inventory" -or $iconPath -match "_inventory" -or $iconPath -match "_mob" -or $iconPath -match "/mob/" -or $iconPath -match "/hud/") { return $false }
    return $true
  }
  return $false
}

function IsAllowedType([string]$typePath) {
  if ($typePath -like "/turf/*") { return $true }
  if ($typePath -like "/obj/structure/*") { return $true }
  if ($typePath -like "/obj/machinery/door/*") { return $true }
  if ($typePath -like "/obj/machinery/light/*") { return $true }
  if ($typePath -like "/obj/effect/turf_decal/ms13/*") { return $true }
  return $false
}

function GetParentPath([string]$typePath, [hashtable]$props) {
  if ($props.ContainsKey("parent_type")) {
    $pt = $props["parent_type"]
    if ($pt -match "^/" ) { return $pt }
  }
  if ($typePath -notmatch "/") { return $null }
  $idx = $typePath.LastIndexOf("/")
  if ($idx -le 0) { return $null }
  return $typePath.Substring(0, $idx)
}

function GetProp([string]$typePath, [string]$prop, [hashtable]$typeInfo) {
  $seen = @{}
  $t = $typePath
  while ($t -and -not $seen.ContainsKey($t)) {
    $seen[$t] = $true
    if ($typeInfo.ContainsKey($t)) {
      $props = $typeInfo[$t]
      if ($props.ContainsKey($prop)) { return $props[$prop] }
      $t = GetParentPath $t $props
    } else {
      $t = GetParentPath $t @{ }
    }
  }
  return $null
}

function GetBaseType([string]$srcType, [string]$icon, [string]$density) {
  if ($srcType -like "/turf/closed/*") { return "/turf/closed/wall/mojave_sprite" }
  if ($srcType -like "/turf/open/*" -or $srcType -like "/turf/*") { return "/turf/open/floor/mojave_sprite" }
  if ($icon -match "/decals/") { return "/obj/effect/f13/mojave_decal" }
  if ($srcType -like "/obj/machinery/door/*" -or $icon -like "*doors.dmi'" -or $icon -like "*airlocks*") { return "/obj/structure/f13/mojave_toggle_door" }
  if ($icon -like "*shutters.dmi'") { return "/obj/structure/f13/mojave_toggle_shutter" }
  if ($srcType -like "/obj/structure/chair*" -or $icon -like "*chairs.dmi'") { return "/obj/structure/chair/f13/mojave" }
  if ($srcType -like "/obj/structure/bed*" -or $icon -like "*beds.dmi'") { return "/obj/structure/bed/f13/mojave" }
  if ($srcType -like "/obj/structure/table*" -or $icon -like "*tables*" -or $icon -like "*counter.dmi'") { return "/obj/structure/table/f13/mojave" }
  if ($srcType -like "/obj/structure/closet*" -or $icon -like "*crates.dmi'" -or $icon -like "*storage.dmi'") { return "/obj/structure/closet/crate/f13/mojave" }
  if ($srcType -like "/obj/machinery/light/*" -or $icon -like "*lighting.dmi'" -or $icon -like "*lamps.dmi'") { return "/obj/structure/f13/mojave_prop" }
  if ($density -eq "TRUE" -or $density -eq "1") { return "/obj/structure/f13/mojave_prop/dense" }
  return "/obj/structure/f13/mojave_prop"
}

$typeInfo = @{}

foreach ($dir in $sourceDirs) {
  if (-not (Test-Path $dir)) { continue }
  $files = Get-ChildItem -Path $dir -Recurse -Filter *.dm
  foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    $inBlock = $false
    $current = $null
    foreach ($raw in $lines) {
      $line = $raw
      if ($line -match "/\*") { $inBlock = $true }
      if ($inBlock) {
        if ($line -match "\*/") { $inBlock = $false }
        continue
      }
      $line = $line -replace "//.*$", ""
      if ($line -match "^\s*/") {
        $candidate = $line.Trim()
        if ($candidate -match "\(") { continue }
        $current = $candidate
        if (-not $typeInfo.ContainsKey($current)) { $typeInfo[$current] = @{} }
        continue
      }
      if (-not $current) { continue }
      if ($line -match "^\s*([A-Za-z0-9_]+)\s*=\s*(.+?)\s*$") {
        $prop = $matches[1]
        $val = $matches[2].Trim()
        if (-not $allowedProps.ContainsKey($prop)) { continue }
        if (-not (IsSimpleValue $val)) { continue }
        $typeInfo[$current][$prop] = $val
      }
    }
  }
}

$linesOut = New-Object System.Collections.Generic.List[string]
$linesOut.Add("// Auto-generated Mojave sprite catalog (from Mojave DM definitions)")
$linesOut.Add("// Includes structures/turfs/decals with icon+icon_state baked in where possible.")
$linesOut.Add("")

$seen = @{}

foreach ($typePath in ($typeInfo.Keys | Sort-Object)) {
  if ($typePath -like "/obj/item/*") { continue }
  if (-not (IsAllowedType $typePath)) { continue }
  $icon = GetProp $typePath "icon" $typeInfo
  if (-not $icon) { continue }
  if (-not (IsAllowedIcon $icon)) { continue }

  $name = GetProp $typePath "name" $typeInfo
  $desc = GetProp $typePath "desc" $typeInfo
  $icon_state = GetProp $typePath "icon_state" $typeInfo
  $anchored = GetProp $typePath "anchored" $typeInfo
  $density = GetProp $typePath "density" $typeInfo
  $opacity = GetProp $typePath "opacity" $typeInfo
  $pixel_x = GetProp $typePath "pixel_x" $typeInfo
  $pixel_y = GetProp $typePath "pixel_y" $typeInfo

  $base = GetBaseType $typePath $icon $density

  $token = ($typePath.TrimStart("/") -replace "[^A-Za-z0-9_]", "_")
  if ($seen.ContainsKey($token)) {
    $seen[$token] += 1
    $token = "${token}_$($seen[$token])"
  } else {
    $seen[$token] = 0
  }

  $linesOut.Add("$base/$token")
  if ($name -and (IsSafeQuotedString $name)) { $linesOut.Add("`tname = $name") }
  if ($desc -and (IsSafeQuotedString $desc)) { $linesOut.Add("`tdesc = $desc") }
  $linesOut.Add("`ticon = $icon")
  if ($icon_state -and (IsSafeQuotedString $icon_state)) { $linesOut.Add("`ticon_state = $icon_state") }
  if ($anchored -and (IsSafeNumberOrBool $anchored)) { $linesOut.Add("`tanchored = $anchored") }
  if ($density -and (IsSafeNumberOrBool $density)) { $linesOut.Add("`tdensity = $density") }
  if ($opacity -and (IsSafeNumberOrBool $opacity)) { $linesOut.Add("`topacity = $opacity") }
  if ($pixel_x -and (IsSafeNumberOrBool $pixel_x)) { $linesOut.Add("`tpixel_x = $pixel_x") }
  if ($pixel_y -and (IsSafeNumberOrBool $pixel_y)) { $linesOut.Add("`tpixel_y = $pixel_y") }
  $linesOut.Add("")
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($linesOut -join [Environment]::NewLine), $utf8NoBom)
Write-Output "Generated $OutFile from $($typeInfo.Keys.Count) Mojave types."
