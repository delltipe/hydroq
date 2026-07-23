# HydroQ — Agent instructions

## First-read sources
`README.md`, `RUN_ME_FIRST.md`, `PRD.md`, `DESIGN_SYSTEM.md`, `API_CONTRACT.md`, `IMPLEMENTATION_NOTES.md`

## Entrypoint
`hydroq/lib/main.dart` → `HydroQApp(controller: HydroQController(repository: MockHydroRepository()))` → `LoginScreen`

## Commands (run from `hydroq/`)

| Action | Command |
|---|---|
| Get deps | `flutter pub get` |
| Analyze | `flutter analyze` |
| Test (all) | `flutter test` |
| Build | `flutter build web --release` |
| Run web | `flutter run -d web-server --web-port 8080` |
| Mock backend (port 8787) | `node backend_mock/server.js` |
| Full verification (all 7 steps) | Unix: `bash scripts/run_all_checks.sh` — Windows: `.\scripts\run_all_checks_windows.bat` |
| CI does | `bash scripts/setup_unix.sh` then `flutter build web --release` |

## Architecture
- **SDK-only deps**: No Riverpod, go_router, Dio, etc. `pubspec.yaml` depends only on `flutter` and `flutter_localizations` + test SDK.
- **State**: `HydroQController` (ChangeNotifier) accessed via `HydroQScope` (InheritedNotifier).
- **Navigation**: `Navigator` directly (no go_router).
- **Charts & plant artwork**: `CustomPainter` (no fl_chart).
- **Demo data**: `MockHydroRepository` uses `Random(2407)`, updates snapshot every 5 seconds via Timer.
- **Backend contract**: `API_CONTRACT.md` defines REST endpoints. The Flutter demo uses the in-process repo by default; `backend_mock/server.js` is a compatible Node.js sandbox.

## Key conventions
- **Language**: Indonesian UI (`id` locale), English code identifiers.
- **Status**: Never use color alone — every state includes text + icon. Available states: `normal`, `warning`, `critical`, `stale`, `offline`, `incomplete`, `unavailable`. Backend-authoritative; Flutter does not recalculate.
- **Unavailable values**: Use em dash (`—`), never `0`.
- **Navigation**: Exactly 3 bottom tabs (Beranda, Edukasi, Profil). Reports live inside Beranda.
- **Product name**: `HydroQ` (capital H, capital Q). Never `Hydroq`, `Hydro Q`.
- **Light theme only** for MVP (no dark mode).
- **No redistributed font binaries** — platform sans-serif fallback used instead of Poppins.
- **Platform runners excluded** from source. `scripts/setup_*` auto-generates them via `flutter create`.

## Testing quirks
- Unit: `test/core/controller_test.dart`, `models_test.dart`
- Widget: `test/widgets/{login_screen, education_screen, plant_profile_flow, responsive_dashboard}_test.dart`
- Integration: `integration_test/app_flow_test.dart`
- Fixtures: `test/fixtures/{snapshot, report, alert, plant, recipe}.json`
- Tests create controller manually: `HydroQController(repository: MockHydroRepository())`, dispose after.
- `verify_structure.py` enforces SDK-only deps, fixture field presence, no secrets, no font files.
