# Removes explicit kotlin-android declarations from plugin build files so Flutter
# can apply KGP automatically without triggering the built-in Kotlin warning.
param(
    [string]$PubCache = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"
)

$ErrorActionPreference = "Stop"

function Patch-PluginBuildGradle {
    param(
        [string]$PluginDir,
        [string]$JvmTarget = "JVM_17"
    )

    $buildGradle = Join-Path $PluginDir "android\build.gradle"
    if (-not (Test-Path $buildGradle)) { return $false }

    $content = Get-Content $buildGradle -Raw
    if ($content -match "PATCHED_FOR_BUILTIN_KOTLIN") { return $false }

    $content = $content -replace "(?ms)^\s*if\s*\([^\)]*\)\s*\{\s*apply plugin:\s*'kotlin-android'\s*\}\s*\r?\n", ""
    $content = $content -replace "apply plugin: 'kotlin-android'\r?\n", ""
    $content = $content -replace '(?m)^\s*apply\(plugin = "org\.jetbrains\.kotlin\.android"\)\s*\r?\n', ""
    $content = $content -replace '(?m)^\s*if\s*\(agpMajor < 9\)\s*\{\s*\r?\n\s*apply\(plugin = "org\.jetbrains\.kotlin\.android"\)\s*\r?\n\s*\}\s*\r?\n', ""
    $content = $content -replace "(?ms)\s+kotlinOptions \{\s+jvmTarget = '17'\s+\}", ""
    $content = $content -replace "(?ms)\s+kotlinOptions \{\s+tasks\.withType\(org\.jetbrains\.kotlin\.gradle\.tasks\.KotlinCompile\)\.configureEach \{\s+kotlinOptions\.jvmTarget = ""1\.8""\s+\}\s+\}", ""
    $content = $content -replace "(?ms)\s+if \(!useBuiltInKotlin\) \{\s+kotlinOptions \{\s+jvmTarget = ""1\.8""\s+\}\s+\}", ""

    if ($content -notmatch "PATCHED_FOR_BUILTIN_KOTLIN") {
        $kotlinBlock = @"

// PATCHED_FOR_BUILTIN_KOTLIN
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.$JvmTarget
    }
}
"@
        if ($content -match "(?ms)(apply plugin: 'com\.android\.library'\r?\n)") {
            $content = $content -replace "(?ms)(apply plugin: 'com\.android\.library'\r?\n)", "`$1$kotlinBlock`n"
        } else {
            return $false
        }
    }

    Set-Content -Path $buildGradle -Value $content -NoNewline
    return $true
}

$patched = @()

Get-ChildItem $PubCache -Directory -Filter "wakelock_plus-*" | ForEach-Object {
    if (Patch-PluginBuildGradle $_.FullName "JVM_17") { $patched += $_.Name }
}

Get-ChildItem $PubCache -Directory -Filter "workmanager_android-*" | ForEach-Object {
    if (Patch-PluginBuildGradle $_.FullName "JVM_1_8") { $patched += $_.Name }
}

Get-ChildItem $PubCache -Directory -Filter "home_widget-*" | ForEach-Object {
    if (Patch-PluginBuildGradle $_.FullName "JVM_1_8") { $patched += $_.Name }
}

if ($patched.Count -gt 0) {
    Write-Host "Patched Kotlin Gradle plugins: $($patched -join ', ')"
}
