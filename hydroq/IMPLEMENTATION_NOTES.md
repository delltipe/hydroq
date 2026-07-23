# HydroQ Implementation Notes

## Delivered architecture

The MVP uses Flutter SDK dependencies only. State is handled with `ChangeNotifier` and `InheritedNotifier`; nested navigation uses `Navigator`; charts and plant artwork use `CustomPainter`; demo data is deterministic and updates every five seconds.

The deliberately small dependency surface avoids generated code, cloud keys, plugin configuration, and package-version conflicts while the production backend is still being developed. It also keeps the repository straightforward for another harness to inspect and extend.

## Implemented flows

- Demo login and logout.
- Responsive bottom navigation and wide-screen navigation rail.
- Current pH, EC/TDS, volume, status, freshness, reports, alerts, and refresh.
- Plant search, plant detail, applying a profile, and copying it as a recipe.
- Recipe validation, editing, activation, and protected deletion.
- Tank configuration and device/sensor diagnostics.
- Notification category preferences.
- Explicit demo states for offline, stale, unconfigured device, and partial sensor failure.
- Mock REST contract covering authentication, tanks, reports, plants, alerts, recipes, and preferences.

## Production integration seams

- Replace `MockHydroRepository` with REST and realtime implementations matching `API_CONTRACT.md`.
- Store access and refresh tokens using platform-secure storage.
- Add production session persistence and refresh behavior.
- Add FCM/APNs configuration for actual push delivery.
- Add durable offline caching after backend payloads are finalized.
- Keep warning, critical, recovery, persistence, cooldown, and deduplication backend-authoritative.
- Connect the ESP32 ingestion endpoint to the backend’s sensor processing pipeline.

## Design implementation

- Light theme only for the MVP.
- Responsive breakpoints use bottom navigation below 840 logical pixels and a navigation rail at or above 840.
- Status never relies on color alone; every state includes text and an icon.
- Plant visuals are generated with `CustomPainter`, so no copyrighted stock image or remote asset is required.
- The design system prefers Poppins, but this source uses the platform sans-serif fallback and does not redistribute font binaries.

## Verification limitation

The creation environment did not contain a Flutter or Dart SDK. Source/contract checks, Node contract tests, file parsing, responsive HTML visual snapshots, archive integrity, and Git whitespace checks were executed here. Flutter formatting, analyzer, widget tests, integration tests, and release build commands are included in setup/CI but require a machine with Flutter installed. See `verification/VERIFICATION_REPORT.md`.
