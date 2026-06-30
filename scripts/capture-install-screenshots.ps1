# Captures real Android emulator screenshots for the sideload install guide.
# Run from repo root: .\scripts\capture-install-screenshots.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$adbExe = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
$serial = "emulator-5554"
$dest = Join-Path $repoRoot "deploy\website\assets\images\screenshots"
$apk = Join-Path $repoRoot "build\app\outputs\flutter-apk\app-debug.apk"

if (-not (Test-Path $adbExe)) {
    Write-Error "adb not found at $adbExe"
}

function Adb {
    & $adbExe -s $serial @args
}

function Wait-Boot {
    Write-Host "Waiting for emulator boot..."
    Adb wait-for-device
    for ($i = 0; $i -lt 60; $i++) {
        $booted = (Adb shell getprop sys.boot_completed).Trim()
        if ($booted -eq "1") { break }
        Start-Sleep -Seconds 3
    }
    Start-Sleep -Seconds 5
}

function Shot {
    param([string]$Name, [int]$DelaySeconds = 2)
    Start-Sleep -Seconds $DelaySeconds
    $path = Join-Path $dest $Name
    cmd /c "`"$adbExe`" -s $serial exec-out screencap -p > `"$path`""
    Write-Host "  -> $Name ($((Get-Item $path).Length) bytes)"
}

function Tap {
    param([int]$X, [int]$Y)
    Adb shell input tap $X $Y
    Start-Sleep -Milliseconds 800
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null

if (-not (Test-Path $apk)) {
    Write-Host "Building debug APK..."
    Push-Location $repoRoot
    flutter build apk --debug
    Pop-Location
}

$devices = (Adb devices) -join "`n"
if ($devices -notmatch "$serial\s+device") {
    Write-Host "Launching emulator..."
    flutter emulators --launch Pixel_3a_API_34_extension_level_7_x86_64
}
Wait-Boot

Write-Host "Preparing device..."
Adb shell settings put system user_rotation 0
Adb shell wm size 1080x2220 | Out-Null
Adb uninstall com.marksmanmate.marksmanmate 2>$null | Out-Null
Adb shell pm clear com.android.chrome 2>$null | Out-Null
Adb push $apk /sdcard/Download/marksmanmate-latest.apk | Out-Null

Write-Host "`nStep 1 - Install page in Chrome"
Adb shell am start -a android.intent.action.VIEW -d "https://marksmanmate.com/android-install/"
Start-Sleep -Seconds 5
Tap 540 1850
Start-Sleep -Seconds 2
Tap 540 1850
Start-Sleep -Seconds 6
Adb shell input swipe 540 1600 540 600 400
Shot "step-01-download.png" 2

Write-Host "Step 2 - Install unknown apps (Chrome)"
Adb shell am start -a android.settings.MANAGE_UNKNOWN_APP_SOURCES -d "package:com.android.chrome"
Shot "step-02-permissions-off.png" 3
Tap 950 1900
Shot "step-02-permissions.png" 1

Write-Host "Step 3 - Downloads folder with APK"
Adb shell input keyevent KEYCODE_BACK
Adb shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/" -t "resource/folder"
Shot "step-03-open-file.png" 4

Write-Host "Step 4 - Install confirmation"
Adb shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/marksmanmate-latest.apk" -t "application/vnd.android.package-archive"
Shot "step-04-install.png" 4

Write-Host "Step 5 - Install complete / Open"
Tap 900 2050
Shot "step-05-open-app.png" 14
Tap 540 1200
Shot "step-05-open-app-alt.png" 2

Write-Host "Step 6 - Login screen"
Adb shell am force-stop com.marksmanmate.marksmanmate
Adb shell monkey -p com.marksmanmate.marksmanmate -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 5
Tap 540 1280
Shot "step-06-login.png" 8

Write-Host "Step 7 - Home screen with app icon"
Adb shell input keyevent KEYCODE_HOME
Start-Sleep -Seconds 2
Adb shell input swipe 540 1800 540 800 300
Shot "step-07-home-icon.png" 2

Write-Host "`nDone. Screenshots in $dest"
