# Deploying MarksmanMate to the web and app stores

Static pages and release artifacts for Google Play and sideload distribution.

## Quick start

1. **Create signing keys** (once):
   ```powershell
   .\scripts\setup-android-signing.ps1
   ```
2. **Add the release SHA-1** to [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials → Android OAuth client for `com.marksmanmate.marksmanmate`.
3. **Build release files**:
   ```powershell
   .\scripts\build-android-release.ps1
   ```
4. **Upload to your website** (marksmanmate.com):
   - `deploy/website/` → site pages
   - `deploy/downloads/marksmanmate-latest.apk` → `https://marksmanmate.com/downloads/marksmanmate-latest.apk`
   - `deploy/website/.well-known/assetlinks.json` → `https://marksmanmate.com/.well-known/assetlinks.json` (after filling in your SHA-256)

## Website pages

| Local path | Deploy to |
|------------|-----------|
| `deploy/website/android-install/index.html` | `https://marksmanmate.com/android-install/` |
| `deploy/website/privacy/index.html` | `https://marksmanmate.com/privacy/` |

## Google Play

Upload `deploy/downloads/marksmanmate-*-.aab` to [Google Play Console](https://play.google.com/console).

See `deploy/PLAY_STORE_CHECKLIST.md` for the full submission checklist and store listing copy.

## Replacing guide images

The install guide uses SVG illustrations in `deploy/website/assets/images/`. Replace them with real phone screenshots for a more polished look — keep the same filenames so the HTML does not need to change.

## App icon

Launcher icons are generated from the same brand assets as marksmanmate.com (`assets/brand/icon-512.png`, sourced from the site `public/brand/` folder). Regenerate after updating the logo:

```powershell
dart run flutter_launcher_icons
Copy-Item assets\brand\icon-512.png deploy\website\assets\images\app-icon.png -Force
```
