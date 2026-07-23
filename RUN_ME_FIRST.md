# Run HydroQ

## Prerequisite

Install Flutter **3.44.x stable** and confirm this command works in a new terminal:

```bash
flutter --version
```

Chrome, Edge, or Brave is recommended for the Web target.

## Windows

Double-click:

```text
START_HYDROQ_WINDOWS.bat
```

The script creates the standard Flutter platform folders when missing, restores the HydroQ source, downloads SDK dependencies, runs analysis and tests, builds the Web release, and starts HydroQ at a local URL.

## macOS or Linux

```bash
chmod +x START_HYDROQ_UNIX.sh
./START_HYDROQ_UNIX.sh
```

## Demo account

- Email: `demo@hydroq.app`
- Password: `hydroq123`

The fields are already filled on the login screen.

## Visual preview without Flutter

Open this file in a browser:

```text
hydroq/design_preview/index.html
```

The preview is a design-QA companion, not the compiled Flutter application.

## Production boundary

This handoff contains a complete interactive Flutter frontend MVP, deterministic in-app demo data, tests, a mock REST backend, and a documented API contract. Cloud authentication, persistent production storage, real push delivery, and physical Arduino/ESP32 ingestion need to be connected by the production backend.
