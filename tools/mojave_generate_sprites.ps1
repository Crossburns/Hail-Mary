Param(
  [string]$Root = "mojave/icons",
  [string]$OutFile = "code/modules/f13/mojave_sprite_catalog.dm"
)

$rootPath = Resolve-Path $Root
$rootNorm = $rootPath.Path

$excludePrefixes = @(
  "effects/",
  "hud/",
  "hydroponics/",
  "mob/",
  "outcasts_storage_only/"
)

$excludeObjectPrefixes = @(
  "objects/guns/",
  "objects/ammo/",
  "objects/melee/",
  "objects/projectiles/",
  "objects/organs/",
  "objects/throwables/"
)

$excludeFiles = @(
  "default_title.dmi",
  "splashscreen.dmi",
  "title_roll.dmi",
  "turf/areas.dmi"
)

$includeRoots = @(
  "decals/",
  "flora/",
  "faction_flags/",
  "objects/",
  "obstacles/",
  "structure/",
  "turf/"
)

function Get-RelNorm([string]$full) {
  $rel = $full.Substring($rootNorm.Length).TrimStart("\\")
  return ($rel -replace "\\", "/")
}

function Should-Include([string]$rel) {
  if ($excludeFiles -contains $rel) { return $false }
  foreach ($p in $excludePrefixes) { if ($rel.StartsWith($p)) { return $false } }
  foreach ($p in $excludeObjectPrefixes) { if ($rel.StartsWith($p)) { return $false } }
  foreach ($p in $includeRoots) { if ($rel.StartsWith($p)) { return $true } }
  return $false
}

function Get-Token([string]$rel) {
  $token = $rel -replace "\\", "/"
  $token = $token -replace "\.dmi$", ""
  $token = $token -replace "[^A-Za-z0-9_]", "_"
  if ($token -match "^[0-9]") { $token = "n_$token" }
  return $token
}

function Get-BaseType([string]$rel) {
  if ($rel.StartsWith("decals/")) { return "/obj/effect/f13/mojave_decal" }
  if ($rel.StartsWith("turf/walls/")) { return "/turf/closed/wall/mojave_sprite" }
  if ($rel.StartsWith("turf/")) { return "/turf/open/floor/mojave_sprite" }
  if ($rel.StartsWith("obstacles/")) { return "/obj/structure/f13/mojave_prop/dense" }

  if ($rel.StartsWith("structure/chairs")) { return "/obj/structure/chair/f13/mojave" }
  if ($rel.StartsWith("structure/beds")) { return "/obj/structure/bed/f13/mojave" }
  if ($rel.StartsWith("structure/standalone_tables")) { return "/obj/structure/table/f13/mojave" }
  if ($rel.StartsWith("structure/smooth_structures/tables")) { return "/obj/structure/table/f13/mojave" }
  if ($rel.StartsWith("structure/counter")) { return "/obj/structure/table/f13/mojave" }
  if ($rel.StartsWith("structure/crates")) { return "/obj/structure/closet/crate/f13/mojave" }
  if ($rel.StartsWith("structure/doors")) { return "/obj/structure/f13/mojave_toggle_door" }
  if ($rel.StartsWith("structure/talldoor")) { return "/obj/structure/f13/mojave_toggle_door" }
  if ($rel.StartsWith("structure/shutters")) { return "/obj/structure/f13/mojave_toggle_shutter" }
  if ($rel.StartsWith("objects/airlocks/")) { return "/obj/structure/f13/mojave_toggle_door" }

  return "/obj/structure/f13/mojave_prop"
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("// Auto-generated Mojave sprite catalog (map placeables)")
$lines.Add("// Generated from mojave/icons (structures/objects/decals/flora/turf/obstacles; excludes mobs/HUD/weapons/etc.)")
$lines.Add("")

$lines.Add("/obj/structure/f13/mojave_sprite_base")
$lines.Add("`tparent_type = /obj/structure/f13/mojave_prop")
$lines.Add("`t" + 'name = "mojave sprite"')
$lines.Add("`t" + 'desc = "A Mojave sprite. Set icon_state as needed."')
$lines.Add("")
$lines.Add("/obj/structure/f13/mojave_sprite_base/dense")
$lines.Add("`tparent_type = /obj/structure/f13/mojave_prop/dense")
$lines.Add("")
$lines.Add("/obj/structure/f13/mojave_sprite_base/low")
$lines.Add("`tparent_type = /obj/structure/f13/mojave_prop")
$lines.Add("`tlayer = BELOW_OBJ_LAYER")
$lines.Add("")
$lines.Add("/turf/open/floor/mojave_sprite")
$lines.Add("`tparent_type = /turf/open/floor/mojave_generic")
$lines.Add("`t" + 'name = "mojave floor"')
$lines.Add("")
$lines.Add("/turf/closed/wall/mojave_sprite")
$lines.Add("`tparent_type = /turf/closed/wall/mojave_generic")
$lines.Add("`t" + 'name = "mojave wall"')
$lines.Add("")
$lines.Add("/obj/structure/closet/crate/f13/mojave")
$lines.Add("`t" + 'name = "mojave crate"')
$lines.Add("`t" + 'desc = "A crate with Mojave styling."')
$lines.Add("`ticon = 'mojave/icons/structure/crates.dmi'")
$lines.Add("`tanchored = FALSE")
$lines.Add("`tdensity = TRUE")
$lines.Add("")
$lines.Add("/obj/structure/closet/crate/f13/mojave/anchored")
$lines.Add("`tanchored = TRUE")

$seen = @{}
$files = Get-ChildItem -Path $rootPath -Recurse -Filter *.dmi | Sort-Object FullName
foreach ($file in $files) {
  $rel = Get-RelNorm $file.FullName
  if (-not (Should-Include $rel)) { continue }
  $token = Get-Token $rel
  if ($seen.ContainsKey($token)) {
    $seen[$token] += 1
    $token = "${token}_$($seen[$token])"
  } else {
    $seen[$token] = 0
  }
  $base = Get-BaseType $rel
  $lines.Add("")
  $lines.Add("$base/$token")
  $lines.Add("`ticon = 'mojave/icons/$rel'")
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($lines -join [Environment]::NewLine), $utf8NoBom)
Write-Output "Generated $OutFile with $($files.Count) source DMIs (filtered)."
