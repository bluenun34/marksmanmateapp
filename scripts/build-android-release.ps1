# Builds release AAB (Google Play) and APK (sideload), then copies to deploy/downloads/.
# Run from the repo root: .\scripts\build-android-release.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$keyProperties = Join-Path $repoRoot "android\key.properties"
$downloadsDir = Join-Path $repoRoot "deploy\downloads"

Set-Location $repoRoot

if (-not (Test-Path $keyProperties)) {
    Write-Warning "android/key.properties not found — release will be signed with DEBUG keys."
    Write-Warning "Run .\scripts\setup-android-signing.ps1 before uploading to Google Play."
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") { exit 1 }
}

$versionLine = Select-String -Path "pubspec.yaml" -Pattern "^version:" | Select-Object -First 1
$version = ($versionLine -replace "version:\s*", "").Trim()
$versionName = ($version -split "\+")[0]
$versionCode = ($version -split "\+")[1]

Write-Host "Building MarksmanMate $versionName ($versionCode) for production API..."
Write-Host ""

flutter pub get
flutter build appbundle --release
flutter build apk --release

New-Item -ItemType Directory -Force -Path $downloadsDir | Out-Null

$aabSource = Join-Path $repoRoot "build\app\outputs\bundle\release\app-release.aab"
$apkSource = Join-Path $repoRoot "build\app\outputs\flutter-apk\app-release.apk"

$aabDest = Join-Path $downloadsDir "marksmanmate-$versionName-$versionCode.aab"
$apkDest = Join-Path $downloadsDir "marksmanmate-$versionName-$versionCode.apk"
$apkLatest = Join-Path $downloadsDir "marksmanmate-latest.apk"

Copy-Item -Force $aabSource $aabDest
Copy-Item -Force $apkSource $apkDest
Copy-Item -Force $apkSource $apkLatest

Write-Host ""
Write-Host "Done."
Write-Host "  Google Play (AAB): $aabDest"
Write-Host "  Sideload (APK):    $apkDest"
Write-Host "  Sideload (latest): $apkLatest"
Write-Host ""
Write-Host "Upload the AAB to Google Play Console."
Write-Host "Host marksmanmate-latest.apk at https://marksmanmate.com/downloads/marksmanmate-latest.apk"
Write-Host "Deploy deploy/website/ pages to your site (see deploy/README.md)."
