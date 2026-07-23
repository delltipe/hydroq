# HydroQ — Frontend Design Specification

**Date:** 23 July 2026
**Product name:** HydroQ
**Platform:** Flutter mobile application
**Product stage:** MVP for one active hydroponic tank
**Team:** 2 people — Frontend Flutter and Backend/IoT

---

## 1. Product Summary

HydroQ helps hydroponic users monitor the condition of nutrient water remotely. Data is collected by pH, EC, and ultrasonic water-level sensors connected to an Arduino. The Arduino sends readings to an ESP32 through Serial UART, and the ESP32 forwards the data to a cloud backend through Wi-Fi.

The mobile application is designed for two user groups:

1. **Beginners**, who need recommended water-quality ranges based on a selected hydroponic plant.
2. **Experienced users**, who already have their own nutrient recipes and want to define custom pH, EC/TDS, and water-volume limits.

The application is not only an alerting tool. Its primary role is a monitoring dashboard that displays current sensor values, historical reports, warnings, and educational plant profiles.

---


## 1.1 Product Identity

The locked user-facing product name is **HydroQ**. All app titles, splash and authentication branding, notification headers, accessibility labels that name the product, and store-facing placeholders must use this exact capitalization. The implementation project and Dart package use the lowercase identifier `hydroq`.

## 2. Product Goals

The MVP must allow a user to:

- Sign in using email and password.
- Monitor current pH, EC, estimated TDS/ppm, and water volume.
- Understand whether each value is normal, approaching a limit, critical, stale, or unavailable.
- Receive push notifications when unsafe conditions persist.
- Review historical readings and alert events.
- Select a recommended plant profile.
- Create a custom water recipe based on personal experience.
- Learn the recommended water parameters for common hydroponic plants.

### Success Criteria

The MVP is considered successful when:

- A user can understand the tank condition within five seconds of opening the Home page.
- New sensor readings appear without manually refreshing the page.
- Alerts do not spam the user for the same unresolved condition.
- A beginner can apply a plant profile without manually entering technical values.
- An experienced user can override recommended thresholds through a custom recipe.
- The app remains understandable when the device is offline, the internet is unavailable, or one sensor fails.

---

## 3. Non-Goals for the MVP

The following are intentionally excluded from the first version:

- Automatic nutrient dosing.
- Automatic pH correction.
- Remote pump or irrigation control.
- Camera monitoring.
- Social features or community discussions.
- Plant disease recognition.
- Multiple simultaneously active tanks in the user interface.
- WhatsApp or email alerts.
- Advanced machine-learning recommendations.

The data structure should still allow multiple tanks in a later version without redesigning the entire backend contract.

---

## 4. High-Level System Architecture

```text
pH Sensor ───────────────┐
EC Sensor ───────────────┼──> Arduino ──Serial UART──> ESP32 ──Wi-Fi──> Backend/Cloud
Ultrasonic Level Sensor ─┘                                      │
                                                                ├──> Realtime data channel
                                                                ├──> Historical summaries
                                                                └──> Push notification service
                                                                           │
                                                                           v
                                                                      Flutter App
```

### Responsibilities

#### Arduino

- Reads raw sensor values.
- Performs device-level validation and calibration calculations.
- Sends structured readings to the ESP32 through Serial UART.

#### ESP32

- Receives readings from the Arduino.
- Adds device identity and timestamp where appropriate.
- Sends data to the backend through Wi-Fi.
- Retries transmission when the connection temporarily fails.

#### Backend

- Authenticates users and devices.
- Associates devices and tanks with user accounts.
- Stores one-minute sensor summaries.
- Evaluates thresholds, persistence durations, recovery states, and alert cooldowns.
- Sends push notifications.
- Provides current data, reports, educational content, recipes, and alert history to Flutter.

#### Flutter App

- Displays live and historical data.
- Shows normal, warning, critical, stale, offline, and unavailable states.
- Allows plant-profile selection and custom-recipe management.
- Displays push notifications and in-app alert history.
- Does not decide authoritative alert states independently from the backend.

---

## 5. Navigation Structure

The authenticated application uses a bottom navigation bar with exactly three main destinations:

1. **Beranda**
2. **Edukasi**
3. **Profil**

Reports remain inside Beranda rather than becoming a fourth navigation item.

### Nested Screens

The three main destinations may open supporting screens:

```text
Login
└── Main App
    ├── Beranda
    │   ├── Detail Laporan
    │   └── Riwayat Peringatan
    ├── Edukasi
    │   └── Detail Tanaman
    └── Profil
        ├── Pengaturan Tangki
        ├── Status Perangkat
        ├── Profil Tanaman Aktif
        ├── Resep Kustom
        ├── Pengaturan Notifikasi
        ├── Pengaturan Satuan
        └── Ubah Kata Sandi
```

---

## 6. Screen Specifications

## 6.1 Authentication

### Login Screen

Required elements:

- Email field.
- Password field with show/hide control.
- Primary login button.
- Loading state while signing in.
- Inline validation and readable error messages.
- Password-reset link if supported by the backend.

MVP authentication uses email and password only. Social login is excluded.

---

## 6.2 Beranda

Beranda is the primary monitoring screen. Its information order must prioritize the current condition before historical information.

### Section 1 — Header

Displays:

- Active tank name, such as **Tangki Utama**.
- Active plant profile or recipe name.
- Device state: online, offline, partial sensor failure, or unconfigured.
- Last successful update time.
- Notification icon with unread count.

### Section 2 — Main Water-Condition Card

A single large card contains three compact parameter areas:

#### pH

- Current value.
- Target range.
- Status label.
- Last sensor timestamp when different from the general update time.

#### Nutrient Concentration

- EC as the primary authoritative value in mS/cm.
- Estimated TDS in ppm.
- Target EC range.
- Status label.
- TDS conversion factor is supplied by backend configuration or user settings, not hard-coded in the UI.

#### Water Volume

- Current estimated volume in liters.
- Percentage of configured tank capacity.
- Visual progress indicator.
- Minimum safe volume.
- Status label.

### Overall Tank Status

The card header shows one aggregate status:

- **Normal:** all available parameters are safe.
- **Warning:** at least one parameter is approaching a limit.
- **Critical:** at least one parameter is outside an allowed range after the persistence duration.
- **Data Terlambat:** readings have not arrived within the stale-data threshold.
- **Offline:** the device is explicitly disconnected or has not reported for the offline threshold.
- **Data Tidak Lengkap:** one sensor is unavailable while other sensors still report.

Critical outranks warning. Offline and stale conditions must not display old values as if they were current.

### Section 3 — Report Preview

The Home page uses one chart instead of three separate charts to avoid excessive scrolling.

Controls:

- Parameter tabs: `pH`, `EC/TDS`, and `Volume`.
- Period selector: daily, weekly, and monthly.

Displayed statistics:

- Average.
- Minimum.
- Maximum.
- Number of warning events.
- Number of critical events.
- Duration outside the safe range when available.

A **Lihat Laporan Lengkap** action opens the detailed report screen.

### Section 4 — Recent Alerts

Displays the latest three to five alert events:

- Parameter.
- Severity.
- Reading and target range.
- Start time.
- Duration or ongoing state.
- Recovery status when the condition has returned to normal.

A **Lihat Semua** action opens the complete alert history.

---

## 6.3 Detailed Report Screen

The detailed report remains accessible from Beranda and is not a bottom-navigation destination.

Required features:

- Parameter selector: pH, EC/TDS, or volume.
- Period selector: day, week, month.
- Historical line chart.
- Average, minimum, maximum, and sample count.
- Warning and critical event count.
- Total abnormal duration.
- Clear indication when historical data is incomplete.

### Data Granularity

- The backend stores one-minute summaries.
- Daily reports may show minute-level or downsampled points.
- Weekly and monthly reports should use backend aggregation to avoid transferring excessive data.
- The frontend must not download all raw readings and aggregate large periods locally.

---

## 6.4 Alert History Screen

Required features:

- Chronological list with newest items first.
- Severity indicator: warning, critical, or recovered.
- Parameter and measured value.
- Target range active at the time of the event.
- Start and end times.
- Ongoing marker for unresolved alerts.
- Empty state when no alerts exist.

Filtering is not required for the MVP.

---

## 6.5 Edukasi

The Edukasi page follows the clean green visual direction of the provided reference image, while keeping the interface original and suitable for the application.

### Required Elements

- Page title and short introductory text.
- Search field for plant names.
- Two-column plant-card grid on normal phone widths.
- No category filter in the MVP.

### Plant Card

Each card displays:

- Plant image or illustration.
- Plant name.
- Difficulty label, such as Pemula or Menengah.
- Short pH range.
- Short EC range.

Selecting a card opens the plant detail screen.

### Search Behaviour

- Search matches plant names and optional aliases.
- Search updates after short input debounce.
- No-result state suggests checking spelling.
- A failed network request must be distinguishable from an empty result.

---

## 6.6 Plant Detail Screen

Displays:

- Plant image.
- Plant name and short description.
- Difficulty level.
- Ideal pH range.
- Ideal EC range.
- Estimated TDS range.
- Recommended water-temperature range when the content exists.
- Approximate growth or harvest duration.
- Nutrient and maintenance tips.
- Common problems.

Actions:

1. **Gunakan Profil Ini**
   - Applies the default recommended profile to the active tank after confirmation.

2. **Salin sebagai Resep Kustom**
   - Creates an editable copy instead of modifying the built-in profile.

Built-in plant profiles are read-only.

---

## 6.7 Profil

The Profil page is the entry point for account, tank, device, recipe, and notification settings.

### Main Profile Items

- User name and email.
- Active tank.
- Device status.
- Active plant profile or custom recipe.
- Notification settings.
- Unit preferences.
- Change password.
- Logout.

### Tank Settings

- Tank name.
- Tank capacity in liters.
- Tank dimensions required by the ultrasonic volume calculation.
- Minimum safe water volume.

Tank geometry validation belongs to both frontend and backend. The backend remains authoritative.

### Device Status

Displays:

- Device name or identifier.
- Connection state.
- Last contact time.
- Individual pH, EC, and level-sensor availability.
- Firmware or hardware information when supplied by the backend.

Pairing and Wi-Fi provisioning may be added later. For the initial frontend scope, the page must support an already-associated device and a clear unconfigured state.

### Custom Recipes

A custom recipe includes:

- Recipe name.
- Minimum and maximum pH.
- Minimum and maximum EC.
- Optional TDS display based on the selected conversion factor.
- Minimum safe water volume.
- Warning margin.
- Alert persistence duration when user-editable.

Validation rules:

- Minimum values must be lower than maximum values.
- Values must remain inside backend-defined physically plausible limits.
- Built-in plant profiles cannot be overwritten.
- Editing an active recipe updates future evaluations, not historical alert records.

### Notification Settings

- Enable or disable push notifications globally.
- Enable pH alerts.
- Enable EC/TDS alerts.
- Enable volume alerts.
- Enable recovery notifications.
- Show notification-permission status.

Severity rules remain backend-controlled. The frontend controls user preferences only.

---

## 7. Alert and Status Behaviour

### Default Evaluation Model

Recommended backend defaults for the MVP:

- Sensor reads continuously on the device.
- Important changes are transmitted immediately.
- One-minute summaries are stored for historical reporting.
- Warning is triggered when a value enters a configurable margin near its limit.
- Critical is triggered after the value remains outside the safe range for approximately three minutes.
- Recovery is confirmed after the value remains inside the safe range for approximately two minutes.
- One unresolved condition creates one alert lifecycle rather than repeated alerts every minute.

These durations should be backend configuration, not hard-coded into the Flutter UI.

### Alert Lifecycle

```text
Normal
  └── Approaching limit ──> Warning
          └── Outside safe range long enough ──> Critical
                  └── Returns inside safe range long enough ──> Recovered
```

### Deduplication

- Do not send another notification for the same parameter and state while the alert remains unresolved.
- Escalating warning to critical may send a new notification.
- Recovery may send one final notification.
- A new alert may begin only after the previous lifecycle has recovered.

---

## 8. Realtime Data Flow

### Preferred Behaviour

1. Flutter loads the most recent snapshot through the standard API.
2. Flutter subscribes to a realtime channel for new readings and device-state changes.
3. Incoming readings update the current dashboard state.
4. Historical reports are fetched separately through aggregated report endpoints.
5. Push notifications may arrive while the app is foregrounded, backgrounded, or closed.

### Fallback Behaviour

If the realtime channel disconnects:

- Show a subtle reconnecting state.
- Keep the last known values with their timestamps.
- Poll the latest snapshot at a modest interval, such as once per minute.
- Restore realtime updates when the connection becomes available.

The UI must never label cached values as current without showing their age.

---

## 9. Frontend Data Models

The exact names may change during implementation, but the contracts should represent the following concepts.

### User

```text
id
name
email
notificationPreferences
unitPreferences
```

### Tank

```text
id
name
capacityLiters
dimensions
minimumSafeVolumeLiters
activeProfileId
deviceId
```

### Device

```text
id
name
connectionStatus
lastSeenAt
sensorAvailability
```

### SensorSnapshot

```text
tankId
recordedAt
receivedAt
ph
ecMsCm
tdsPpm
volumeLiters
volumePercent
parameterStatuses
overallStatus
```

### SensorReport

```text
parameter
period
startAt
endAt
points
average
minimum
maximum
sampleCount
warningCount
criticalCount
abnormalDurationSeconds
```

### AlertEvent

```text
id
tankId
parameter
severity
status
measuredValue
targetMinimum
targetMaximum
startedAt
endedAt
lastUpdatedAt
```

### PlantProfile

```text
id
name
aliases
description
imageUrl
difficulty
phRange
ecRange
tdsRange
waterTemperatureRange
growthDuration
nutrientTips
commonProblems
```

### CustomRecipe

```text
id
name
phRange
ecRange
minimumVolumeLiters
warningMargin
alertPersistenceSeconds
updatedAt
```

---

## 10. Backend Contract Required by Frontend

The backend implementation may use REST, GraphQL, or another approach, but the frontend requires equivalent operations for:

### Authentication

- Login.
- Refresh session.
- Logout.
- Request password reset.

### Dashboard

- Fetch active tank.
- Fetch current sensor snapshot.
- Subscribe to live sensor and device-state updates.

### Reports

- Fetch aggregated data by parameter and period.
- Fetch summary statistics.

### Alerts

- Fetch recent alerts.
- Fetch complete alert history.
- Fetch unread-alert count.
- Mark alerts as read if required by product behaviour.

### Education

- Fetch plant list.
- Search plants by text.
- Fetch plant detail.
- Apply built-in profile to active tank.

### Recipes and Settings

- Fetch, create, update, and delete custom recipes.
- Set active plant profile or custom recipe.
- Read and update tank configuration.
- Read device status.
- Read and update notification preferences.

### API Error Shape

All errors should provide:

```text
machine-readable code
human-readable message
field errors when applicable
request or trace identifier when available
```

This allows Flutter to display clear messages without parsing backend text.

---

## 11. Frontend Architecture Recommendation

Use a **feature-first architecture** rather than a highly ceremonial enterprise clean architecture. The team is small, so boundaries should be clear without creating excessive boilerplate.

```text
lib/
├── app/
│   ├── routing/
│   ├── theme/
│   └── app.dart
├── core/
│   ├── networking/
│   ├── realtime/
│   ├── storage/
│   ├── errors/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── reports/
│   ├── alerts/
│   ├── education/
│   ├── plant_profile/
│   ├── recipes/
│   ├── tank_settings/
│   └── profile/
└── main.dart
```

Each feature should separate:

- Presentation widgets and screen state.
- Domain models and use cases where useful.
- Data sources and repositories.

Avoid large screens that directly call APIs. Screens consume state controllers; controllers consume repositories; repositories handle remote or cached data.

---

## 12. State Management Boundaries

Recommended application states:

- Authentication session.
- Active tank.
- Current sensor snapshot.
- Realtime connection state.
- Report query and result.
- Alert history and unread count.
- Plant search and plant detail.
- Active profile and custom recipes.
- Notification and unit preferences.

Realtime sensor state must be isolated from report state so live updates do not force the entire report screen to rebuild.

---

## 13. Local Storage and Caching

Store locally:

- Authentication tokens in secure storage.
- Last selected report parameter and period.
- Last successfully loaded snapshot for offline display.
- Small plant-content cache when practical.
- Non-sensitive UI preferences.

Do not store passwords or authoritative alert logic locally.

Cached data must include timestamps and must be clearly labeled when stale.

---

## 14. Error and Empty States

The following states require explicit designs:

### No Device Connected

- Explain that monitoring is unavailable.
- Provide a route to device-status or setup information.

### Device Offline

- Preserve the last known values.
- Display last-contact time prominently.
- Disable misleading live indicators.

### Stale Data

- Show how old the latest reading is.
- Distinguish stale backend data from a confirmed offline device.

### Partial Sensor Failure

- Continue showing healthy sensors.
- Replace only the unavailable parameter with a clear error state.
- Overall status becomes Data Tidak Lengkap unless another available parameter is critical.

### Backend Unreachable

- Show cached values if available.
- Provide retry action.
- Preserve navigation to cached educational content where possible.

### Session Expired

- Attempt session refresh.
- Return to login only if refresh fails.
- Avoid losing unsaved recipe input without warning.

### Notification Permission Denied

- Monitoring remains usable.
- Show an explanation and a path to device settings.

### No Historical Data

- Explain that reports will appear after sensor data has been collected.
- Do not render a misleading flat zero-value chart.

---

## 15. Visual Design Direction

### Style

- Clean, calm, modern, and beginner-friendly.
- Light neutral background.
- Green as the primary application color.
- Rounded cards and controls.
- Plant imagery in Edukasi.
- Minimal technical jargon on primary screens.

### Status Colours

- Normal: green.
- Warning: amber or orange.
- Critical: red.
- Offline or unavailable: grey.

Colour must never be the only status indicator. Each state also uses text and an icon.

### Typography and Layout

- Clear hierarchy with large current sensor values.
- Target ranges remain visible but secondary.
- Use an eight-point spacing rhythm.
- Ensure touch targets are comfortable on small phones.
- Support long Indonesian labels without clipping.

### Accessibility

- Maintain readable contrast.
- Support screen-reader labels for icons and charts.
- Do not rely only on red and green.
- Respect text scaling.
- Provide textual summaries for chart statistics.

---

## 16. Testing Strategy

### Unit Tests

Test:

- Sensor-value formatting.
- EC and TDS display rules.
- Volume percentage formatting.
- Status-priority mapping.
- Stale-data detection in presentation state.
- Report statistic mapping.
- Recipe validation.
- API error mapping.

### Widget Tests

Test:

- Login validation.
- Main dashboard states.
- Parameter and period switching on reports.
- Education search results and empty states.
- Plant-detail actions.
- Recipe form validation.
- Offline and partial-sensor states.

### Integration Tests

Cover:

1. Login and dashboard load.
2. Live sensor update changes the current card.
3. Realtime disconnect falls back gracefully.
4. Warning escalates to critical and later recovers.
5. Applying a plant profile changes target ranges.
6. Creating and activating a custom recipe.
7. Device offline and reconnect flow.
8. Notification navigation opens the relevant alert context.

### Contract Tests

Frontend fixtures should be validated against backend response schemas for:

- Current snapshot.
- Realtime event.
- Report response.
- Alert event.
- Plant profile.
- Custom recipe.

---

## 17. Recommended Delivery Order

### Phase 1 — Foundation

- Application shell and theme.
- Routing.
- Login.
- Shared API and error handling.

### Phase 2 — Monitoring

- Beranda layout.
- Current snapshot integration.
- Status and offline states.
- Realtime updates.

### Phase 3 — Reports and Alerts

- Report preview.
- Detailed report.
- Alert history.
- Push-notification navigation.

### Phase 4 — Education

- Plant grid.
- Search.
- Plant detail.
- Apply plant profile.

### Phase 5 — Profile and Recipes

- Profile page.
- Tank settings.
- Device status.
- Custom recipes.
- Notification preferences.

### Phase 6 — Hardening

- Loading, empty, stale, and partial-failure states.
- Accessibility.
- Performance checks.
- Unit, widget, integration, and contract tests.

---

## 18. Final MVP Scope

### Included

- Email/password login.
- Three primary destinations: Beranda, Edukasi, Profil.
- Live pH, EC, estimated TDS, and water-volume monitoring.
- Overall and per-parameter status.
- Daily, weekly, and monthly reports.
- Warning, critical, recovery, offline, stale, and partial-failure states.
- Push notifications and in-app alert history.
- Plant education grid without category filters.
- Plant-detail profiles.
- Built-in recommended profiles for beginners.
- Custom recipes for experienced users.
- One active tank in the MVP.
- Architecture ready for multiple tanks later.

### Explicitly Deferred

- Automatic control and dosing.
- Multi-tank switching UI.
- QR pairing and Wi-Fi provisioning.
- Email and WhatsApp notifications.
- Category filters in Edukasi.
- Advanced analytics or AI recommendations.

---

## 19. Design Decisions Locked During Brainstorming

- The product is an operational MVP, not only a classroom prototype.
- Monitoring works remotely through the internet.
- Arduino reads sensors and communicates with ESP32 through Serial UART.
- EC is the primary nutrient measurement; TDS/ppm is estimated for usability.
- Volume is displayed in liters and percentage using an ultrasonic sensor.
- Built-in plant profiles and user-defined custom recipes are both supported.
- Warning and critical alerts require persistence to reduce false alarms.
- Push notifications and in-app alert history are included.
- The app displays live values and historical reports, not notifications alone.
- Sensor data is continuously observed; important changes are sent quickly; one-minute summaries are stored.
- Authentication uses email and password.
- Bottom navigation contains Beranda, Edukasi, and Profil only.
- Reports are placed inside Beranda.
- Beranda shows current conditions before reports.
- Current pH, nutrient, and volume values share one large summary card.
- Edukasi includes search and a plant grid, with no category filter.

