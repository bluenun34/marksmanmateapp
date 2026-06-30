# Sync launcher icons from the marksmanmate.com brand assets.
# Run from repo root: .\scripts\sync-brand-icons.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$brandSource = "D:\websites\marksmanmate\public\brand"
$brandDest = Join-Path $repoRoot "assets\brand"

if (-not (Test-Path $brandSource)) {
    Write-Error "Brand folder not found at $brandSource. Update the path in this script if your Laravel site lives elsewhere."
}

New-Item -ItemType Directory -Force -Path $brandDest | Out-Null

Copy-Item (Join-Path $brandSource "icon-512.png") (Join-Path $brandDest "icon-512.png") -Force
Copy-Item (Join-Path $brandSource "app-icon.svg") (Join-Path $brandDest "app-icon.svg") -Force
Copy-Item (Join-Path $brandSource "favicon.svg") (Join-Path $brandDest "favicon.svg") -Force

Set-Location $repoRoot
dart run flutter_launcher_icons

Copy-Item (Join-Path $brandDest "icon-512.png") (Join-Path $repoRoot "deploy\website\assets\images\app-icon.png") -Force

Write-Host "Brand icons synced to Android, iOS, web, Windows, macOS, and deploy website."
