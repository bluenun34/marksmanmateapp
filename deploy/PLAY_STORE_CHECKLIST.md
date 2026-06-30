# Google Play Store checklist — MarksmanMate

Use this when submitting to [Google Play Console](https://play.google.com/console).

## One-time setup

- [ ] Google Play Developer account created ($25) and identity verified
- [ ] Upload keystore created: `.\scripts\setup-android-signing.ps1`
- [ ] Release SHA-1 added to Google Cloud Console → Android OAuth client (`com.marksmanmate.marksmanmate`)
- [ ] Play App Signing enabled (recommended — Google manages app signing key)
- [ ] Privacy policy live at **https://marksmanmate.com/privacy/**
- [ ] Asset links file live at **https://marksmanmate.com/.well-known/assetlinks.json** (see `deploy/website/.well-known/assetlinks.json.example`)

## Build and upload

```powershell
.\scripts\build-android-release.ps1
```

- [ ] Upload `deploy/downloads/marksmanmate-*-.aab` to Play Console
- [ ] `versionCode` in `pubspec.yaml` incremented for every release (the `+N` part)

## Store listing copy (draft)

**App name:** MarksmanMate

**Short description (80 chars max):**
```
Log shoots, manage your kit, and connect with UK shooting clubs and events.
```

**Full description:**
```
MarksmanMate is the mobile companion for the marksmanmate.com shooting sports platform.

LOG YOUR SHOOTING
Record range sessions, scores, and notes. Review your history and track progress over time — even when you're offline at the range.

YOUR LOCKER
Keep firearms and ammunition records synced with your account.

TOOLS FOR THE RANGE
Shot timer, target analyser, round counter, ballistics calculators, and more — built for practical shooting.

CLUBS, GROUPS & EVENTS
Join your club, coordinate with groups, enter events, and follow live scores.

STAY CONNECTED
Messages and notifications keep you up to date with friends, groups, and event organisers.

Sign in with your existing marksmanmate.com account or Google. Requires an active MarksmanMate membership where applicable.
```

**Category:** Sports

**Contact email:** support@marksmanmate.com

**Privacy policy URL:** https://marksmanmate.com/privacy/

## Graphics needed in Play Console

| Asset | Size | Notes |
|-------|------|-------|
| App icon | 512×512 PNG | Generated from `assets/brand/icon-512.png` (matches site favicon) |
| Feature graphic | 1024×500 PNG | Banner for store listing |
| Phone screenshots | 2–8 images | Dashboard, shoot log, tools, locker |
| Optional tablet | 7–10" | If supporting tablets |

## App content declarations

### Data safety (summary — complete the full form in Console)

| Data type | Collected | Purpose |
|-----------|-----------|---------|
| Email, name | Yes | Account |
| User-generated content | Yes | Shoot logs, messages |
| Photos | Yes | Optional, user-initiated |
| Location | Yes | Optional, session tagging |
| App activity | Yes | Usage within app |
| Device IDs | Yes | Auth tokens |

### Sensitive permissions — justification text

| Permission | User-facing reason |
|------------|-------------------|
| Camera | Photograph targets and score sheets for session records |
| Photos / media | Attach images to shoot sessions |
| Location | Tag where a session or event took place (optional) |
| Microphone | Shot timer detects shots via audio |
| Notifications | Messages, event updates, and reminders |
| Bluetooth | Connect to supported accessories where available |

### Other questionnaires

- [ ] Target audience and content rating completed
- [ ] Login required: **Yes**
- [ ] User-generated content: **Yes** (messages, groups)
- [ ] Ads: **No** (unless you add ads later)
- [ ] Export compliance: typically **No** for standard apps

## Testing rollout (recommended order)

1. **Internal testing** — 5–10 trusted users, verify Google Sign-In on release build
2. **Closed testing** — wider club beta
3. **Production** — staged rollout 10% → 50% → 100%

## Sideload → Play Store transition

While Play review is pending:

- Host APK at `https://marksmanmate.com/downloads/marksmanmate-latest.apk`
- Publish install guide at `https://marksmanmate.com/android-install/`

When live on Play Store, update the install guide to point to the Play Store link and keep the APK page as a fallback if desired.

## Get SHA-256 for asset links

```powershell
cd android
keytool -list -v -keystore keystore\upload-keystore.jks -alias upload
```

Copy the **SHA-256** fingerprint into `assetlinks.json` (see example file).
