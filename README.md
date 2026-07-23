# HydroQ — Runnable Flutter MVP Handoff

HydroQ is a responsive Flutter application for monitoring hydroponic water quality. This handoff includes the application source, deterministic demo data, a zero-dependency mock backend, automated tests, verification scripts, product documentation, and the approved visual reference.

## Fastest start

### Windows

1. Install Flutter stable and make sure `flutter` is available in `PATH`.
2. Extract this ZIP.
3. Double-click `START_HYDROQ_WINDOWS.bat`.
4. After verification and the Web release build complete, open the local URL printed by Flutter.

### macOS or Linux

```bash
chmod +x START_HYDROQ_UNIX.sh
./START_HYDROQ_UNIX.sh
```

The setup scripts generate standard platform runners when they are missing, restore the HydroQ source, fetch dependencies, run analysis and tests, build Flutter Web in release mode, and then start a local Web server.

## Demo login

- Email: `demo@hydroq.app`
- Password: `hydroq123`

The fields are prefilled. The application runs entirely from deterministic demo data, so no cloud key or external backend is required to explore the complete frontend flow.

## Included product experience

- Email/password demo authentication and logout.
- Responsive phone, tablet, Web, and desktop layout.
- Three primary destinations: **Beranda**, **Edukasi**, and **Profil**.
- Live pH, EC, estimated TDS/ppm, liters, and volume percentage.
- Normal, warning, critical, stale, offline, partial-sensor, unavailable, loading, and empty states.
- Daily, weekly, and monthly reports with pH, EC/TDS, and volume selection.
- Alert preview and full lifecycle history.
- Eight searchable hydroponic plant profiles with detailed guidance.
- Built-in profile activation and custom recipe creation/editing/activation/deletion.
- Tank, device, sensor availability, notification, and unit information screens.
- Demo controls for offline, stale, unconfigured-device, and partial-sensor scenarios.
- Responsive design tokens, custom chart rendering, and custom plant illustrations.

## Repository map

```text
HydroQ/
├── START_HYDROQ_WINDOWS.bat
├── START_HYDROQ_UNIX.sh
├── README.md
├── RUN_ME_FIRST.md
├── PRD.md
├── DESIGN_SYSTEM.md
├── MANIFEST.sha256
├── docs/
├── references/
└── hydroq/
    ├── lib/                    # Flutter application
    ├── test/                   # unit and widget tests
    ├── integration_test/       # end-to-end app flow
    ├── backend_mock/           # zero-dependency REST sandbox
    ├── design_preview/         # static visual QA companion
    ├── verification/           # report and visual snapshots
    ├── scripts/                # setup, run, and verification scripts
    ├── API_CONTRACT.md
    ├── IMPLEMENTATION_NOTES.md
    └── pubspec.yaml
```

## Manual commands

From the `hydroq` directory:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter run -d web-server --web-port 8080
```

Run the mock backend separately with:

```bash
node backend_mock/server.js
```

The Flutter demo currently uses an in-process repository. `API_CONTRACT.md` and `backend_mock/` define the integration boundary for the production backend.

## Documentation order

1. `PRD.md` — scope, users, functional requirements, and acceptance criteria.
2. `DESIGN_SYSTEM.md` — visual tokens, components, states, accessibility, and layout rules.
3. `docs/superpowers/specs/2026-07-23-hydroq-monitoring-app-design.md` — approved product and architecture design.
4. `docs/superpowers/plans/2026-07-23-hydroq-flutter-mvp-implementation.md` — implementation plan.
5. `hydroq/verification/VERIFICATION_REPORT.md` — checks performed for this handoff and the environment limitation.

## Important production boundary

This ZIP is a complete, runnable frontend MVP and backend contract sandbox. Production authentication, secure token storage, cloud persistence, actual FCM/APNs push delivery, and Arduino/ESP32 ingestion remain integration work for the production backend. No production secret or credential is included.
