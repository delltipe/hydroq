# HydroQ Flutter MVP

HydroQ is a responsive Flutter application for hydroponic water monitoring. It contains a complete interactive frontend, deterministic realtime demo data, a mock REST backend, product-state simulations, and automated tests.

## One-command start

### Windows

Double-click:

```text
scripts\start_windows.bat
```

### macOS or Linux

```bash
chmod +x scripts/start_unix.sh
./scripts/start_unix.sh
```

Both commands verify the project, create missing platform runners, build Flutter Web in release mode, and start a local Web server on port `8080`.

## Demo credentials

- Email: `demo@hydroq.app`
- Password: `hydroq123`

## Manual run

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d web-server --web-port 8080
```

For Android after setup:

```bash
flutter devices
flutter run -d <android-device-id>
```

## Verification

Run all checks:

```bash
bash scripts/run_all_checks.sh
```

Windows:

```powershell
.\scripts\run_all_checks_windows.bat
```

The checks cover source structure, contract fixtures, shell and JavaScript syntax, REST contract behavior, Flutter formatting, analysis, tests, and a release Web build when the Flutter SDK is available.

## Optional mock backend

```bash
node backend_mock/server.js
```

Health endpoint:

```text
http://127.0.0.1:8787/health
```

The application itself defaults to `MockHydroRepository`, so it remains fully explorable without running Node. See `API_CONTRACT.md` for production integration.

## Source layout

```text
lib/
├── app/                 # MaterialApp composition
├── core/
│   ├── data/            # deterministic demo repository
│   ├── models/          # sensor, report, alert, plant, recipe models
│   ├── state/           # application controller and inherited scope
│   ├── theme/           # design tokens and Material theme
│   └── widgets/         # reusable cards, status, chart, plant artwork
└── features/
    ├── auth/
    ├── shell/
    ├── dashboard/
    ├── reports/
    ├── alerts/
    ├── education/
    ├── profile/
    ├── recipes/
    └── notifications/
```

## Platform runner generation

The handoff intentionally keeps generated native runner files out of the ZIP. `scripts/setup_windows.ps1` and `scripts/setup_unix.sh` run `flutter create` only when runner folders are missing, preserve the HydroQ source, then verify and build the project. This keeps the handoff small while producing the standard runner files for the local operating system.
