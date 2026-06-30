# Creates the upload keystore and key.properties for Play Store / sideload releases.
# Run from the repo root: .\scripts\setup-android-signing.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$androidDir = Join-Path $repoRoot "android"
$keystoreDir = Join-Path $androidDir "keystore"
$keyProperties = Join-Path $androidDir "key.properties"
$keystorePath = Join-Path $keystoreDir "upload-keystore.jks"

if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    Write-Error "keytool not found. Install a JDK (Android Studio includes one) and ensure keytool is on PATH."
}

New-Item -ItemType Directory -Force -Path $keystoreDir | Out-Null

if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists at $keystorePath"
    Write-Host "Delete it first if you need to create a new one."
} else {
    Write-Host "Creating upload keystore..."
    Write-Host "You will be asked for a password and some certificate details."
    Write-Host "Use the SAME password for keystore and key when prompted, or remember both."
    Write-Host ""
    Push-Location $androidDir
    keytool -genkey -v `
        -keystore "keystore\upload-keystore.jks" `
        -alias upload `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000
    Pop-Location
}

if (Test-Path $keyProperties) {
    Write-Host "key.properties already exists — leaving it unchanged."
} else {
    $storePassword = Read-Host "Enter keystore password (same as used above)" -AsSecureString
    $storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword)
    )

    @"
storePassword=$storePasswordPlain
keyPassword=$storePasswordPlain
keyAlias=upload
storeFile=keystore/upload-keystore.jks
"@ | Set-Content -Path $keyProperties -Encoding UTF8

    Write-Host "Created $keyProperties"
}

Write-Host ""
Write-Host "SHA-1 fingerprint (add to Google Cloud Console Android OAuth client):"
Push-Location $androidDir
keytool -list -v -keystore "keystore\upload-keystore.jks" -alias upload | Select-String "SHA1:"
Pop-Location

Write-Host ""
Write-Host "Next: run .\scripts\build-android-release.ps1"
