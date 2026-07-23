# HydroQ Verification Report

## Scope

This report records the checks performed before packaging the HydroQ MVP handoff.

## Passed in the handoff environment

- All Dart files passed balanced delimiter and unterminated string/comment checks.
- Every relative Dart import resolves to an existing file.
- The `pubspec.yaml` package name, SDK constraints, and SDK-only dependency policy are valid.
- Required product copy, states, navigation labels, and recipe controls are present.
- Web manifest icon references resolve and JSON parses.
- API contract fixtures for snapshot, report, alert, plant, and recipe contain required fields.
- Bash setup and verification scripts pass `bash -n`.
- Mock backend JavaScript files pass `node --check`.
- Mock backend contract tests pass for login, snapshot, reports, eight plant profiles, alias search, notification preferences, recipe creation, recipe activation, active-target snapshot updates, protected deletion, invalid tank capacity, and validation errors.
- JSON, XML, HTML, and YAML smoke parsing passes.
- Static responsive design preview rendered successfully at 390 px, 768 px, and 1280 px widths. Snapshots are stored under `verification/screenshots/`.
- Git whitespace validation and final archive integrity checks are performed during packaging.

## Flutter SDK checks

The execution environment used to create this ZIP does not provide `flutter` or `dart` in `PATH`, and external SDK installation was not available. Therefore the following commands could not be executed here:

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build web --release
```

They are mandatory in `scripts/run_all_checks.*`, `scripts/setup_*`, and `.github/workflows/flutter.yml`. The one-command setup scripts run them before starting the application on a machine with Flutter installed.

## Reproduce all checks

From the `hydroq` directory:

```bash
bash scripts/run_all_checks.sh
```

Windows:

```powershell
.\scripts\run_all_checks_windows.bat
```

A successful run with Flutter installed ends with a passing Flutter Web release build.

## Visual QA artifacts

- `verification/screenshots/dashboard-phone.png`
- `verification/screenshots/dashboard-tablet.png`
- `verification/screenshots/dashboard-desktop.png`

These are responsive HTML design-companion snapshots used to validate density, hierarchy, card behavior, and navigation breakpoints. They are not screenshots from a compiled Flutter binary.
