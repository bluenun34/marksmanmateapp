# MarksmanMate App

Flutter client for the [MarksmanMate](https://marksmanmate.com) shooting sports platform.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- The **marksmanmate** Laravel backend repo (sibling project), for local API development
- Chrome, Edge, or Windows desktop for local runs

Verify setup:

```bash
flutter doctor
flutter devices
```

## Local development (app + backend)

Use the Laravel **marksmanmate** project as the API while you develop the app. Production is only used for release builds or when you explicitly opt in.

### 1. Start the Laravel backend

Backend repo: **`D:\websites\marksmanmate`**

This project uses **Laravel Herd** (or similar) with:

- Site URL: **http://marksmanmate.test**
- API base: **http://marksmanmate.test/api**

Ensure Herd is running and the site is linked/serving that folder. You do **not** need `php artisan serve` if Herd already serves `marksmanmate.test`.

Quick checks from the backend folder:

```bash
cd D:\websites\marksmanmate
php artisan migrate:status
curl http://marksmanmate.test/up
```

If you use `php artisan serve` instead, change `config/dev.env.json` to `http://127.0.0.1:8000/api`.

### 2. Allow the Flutter web app (CORS)

When testing in Chrome, the app runs on `http://localhost:<port>`. Laravel must allow that origin.

In **marksmanmate** `config/cors.php` (or `.env`), ensure local origins are permitted, for example:

```php
'allowed_origins' => [
    'http://localhost:*',
    'http://127.0.0.1:*',
],
```

Or set `CORS_ALLOWED_ORIGINS` in `.env` to match your Flutter dev URL. Restart `php artisan serve` after changes.

### 3. Run the Flutter app against dev

**Option A — Cursor / VS Code (recommended)**

Run and Debug → choose **MarksmanMate (dev API)**.

**Option B — Terminal**

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.env.json
```

**Option C — Debug default**

Plain `flutter run -d chrome` (without defines) also targets `http://marksmanmate.test/api` in debug builds.

The login screen shows an orange **Development API** banner when not pointing at production.

### 4. Point at production (live) when ready

```bash
flutter run -d chrome --dart-define-from-file=config/prod.env.json
```

Or use the **MarksmanMate (production API)** launch configuration.

Release builds (`flutter build ...`) use production automatically unless you pass a dart-define override.

## Run targets

| Target | Command |
|--------|---------|
| Chrome | `flutter run -d chrome --dart-define-from-file=config/dev.env.json` |
| Edge | `flutter run -d edge --dart-define-from-file=config/dev.env.json` |
| Windows | `flutter run -d windows --dart-define-from-file=config/dev.env.json` |
| Android emulator | Use `http://10.0.2.2:8000/api` in `config/dev.env.json` (not `127.0.0.1`) |
| Android physical device | Use your PC's LAN IP, e.g. `http://192.168.1.10:8000/api` |

While `flutter run` is active: **`r`** hot reload, **`R`** restart, **`q`** quit.

## Configuration files

| File | Purpose |
|------|---------|
| `config/dev.env.json` | Local Herd API (`http://marksmanmate.test/api`) |
| `config/prod.env.json` | Live production API |

Override a single value without editing files:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

## Manual test checklist

1. **Login** — dev user from your local marksmanmate database / seeders
2. **Dashboard** — sessions and stats load from local API
3. **Shoot log** — create and open a session
4. **Offline** — Chrome DevTools → Network → Offline → create session → pending sync
5. **Locker** — refresh firearms/ammo from API
6. **Settings** — theme and sign out

## Tests & analysis

```bash
flutter analyze
flutter test
```

## Project structure

```
lib/
  core/       # API, database, sync, theme, config
  features/   # auth, dashboard, shoot_log, locker, settings
  shared/     # models and widgets
config/       # dev.env.json, prod.env.json
```
