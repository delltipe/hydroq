# Product Requirements Document — HydroQ

**Document status:** Approved for MVP implementation
**Version:** 1.1
**Date:** 23 July 2026
**Product name:** HydroQ
**Primary platform:** Flutter mobile application
**MVP language:** Indonesian
**Initial deployment:** One active hydroponic tank per user interface
**Team:** One Flutter frontend developer and one backend/IoT developer

---

### Product Naming Requirement

- All user-facing application titles, splash screens, authentication screens, system labels, and notification headers use `HydroQ`.
- The name is case-sensitive and must not be separated into two words.
- Generic phrases such as “aplikasi hidroponik” may still be used descriptively, but they must not replace the HydroQ product name.
- The MVP uses a text wordmark only. Logo-symbol exploration is outside the implementation scope covered by this PRD.

## 1. Executive Summary

HydroQ is a mobile application that helps hydroponic growers remotely understand the condition of the nutrient solution in their reservoir. The system measures pH, electrical conductivity (EC), estimated total dissolved solids (TDS/ppm), and water volume using sensors connected to an Arduino. The Arduino transfers readings to an ESP32 through Serial UART, and the ESP32 sends the readings to a cloud backend through Wi-Fi.

The application serves two audiences:

1. **Beginners**, who need simple plant-based recommendations and clear explanations.
2. **Experienced growers**, who already have their own nutrient recipes and need configurable thresholds.

The MVP combines three product functions:

- **Live monitoring:** Current water parameters and device status.
- **Reporting and alerts:** Historical trends, abnormal-condition history, and push notifications.
- **Education and configuration:** Plant profiles, recommended ranges, and custom nutrient recipes.

The application is intentionally monitoring-first. It does not automatically dose nutrients, correct pH, or control pumps in the MVP.

---

## 2. Problem Statement

Hydroponic plants depend heavily on the condition of their nutrient water. pH, nutrient concentration, and water availability may change between manual checks. When growers notice the problem too late, plants can experience nutrient lockout, underfeeding, overfeeding, dehydration, or reduced growth.

Current manual workflows create several problems:

- Growers must physically inspect the reservoir.
- Beginners may not know the correct pH and EC ranges for a selected plant.
- A single number without context does not explain whether the condition is safe.
- Temporary sensor fluctuations can create false alarms.
- Experienced growers need flexibility beyond fixed recommendations.
- Historical changes are difficult to understand without reports.
- Device failures or stale readings may be mistaken for a healthy tank.

The product must solve these problems without overwhelming new users with technical complexity.

---

## 3. Product Vision

Enable hydroponic growers to understand and respond to nutrient-water conditions quickly, confidently, and remotely, regardless of their experience level.

### Product Promise

Within five seconds of opening the Home page, a user should be able to answer:

- Is the tank safe right now?
- Which parameter needs attention?
- What is the current value and target range?
- Is the reading current, delayed, or unavailable?
- What changed recently?

---

## 4. Product Goals

### 4.1 Primary Goals

The MVP shall allow a signed-in user to:

- View current pH, EC, estimated TDS, water volume, and device status remotely.
- Understand each parameter through a normal, warning, critical, stale, offline, or unavailable state.
- Receive push notifications for persistent abnormal conditions.
- Review daily, weekly, and monthly reports.
- Review alert history and recovery events.
- Select a built-in plant profile with recommended water ranges.
- Create, edit, activate, and delete custom recipes.
- Access educational information for common hydroponic plants.
- Continue understanding the last known condition when connectivity is degraded.

### 4.2 Success Criteria

The MVP is successful when:

- The main status is understandable within five seconds of opening Beranda.
- Current readings update without manual refresh when realtime connectivity is available.
- Cached values always display their age and are never presented as live data.
- One unresolved condition does not generate repeated notification spam.
- A beginner can activate a recommended plant profile without manually entering technical values.
- An experienced user can create and activate a custom recipe.
- The user can distinguish device offline, stale data, partial sensor failure, and backend failure.
- The principal user journeys pass integration and acceptance testing.

---

## 5. Non-Goals

The following capabilities are explicitly excluded from the MVP:

- Automatic nutrient dosing.
- Automatic pH correction.
- Remote pump or irrigation control.
- Camera monitoring.
- Plant disease recognition.
- AI-generated cultivation recommendations.
- Social feeds, forums, or community discussions.
- Multiple simultaneously active tanks in the mobile interface.
- QR device pairing and Wi-Fi provisioning.
- Email or WhatsApp alerts.
- Category filters on the Education page.
- Editing built-in plant profiles.
- Downloading or exporting reports.

The backend data model should remain capable of supporting multiple tanks in a future release.

---

## 6. Target Users

## 6.1 Persona A — Beginner Grower

**Characteristics**

- Recently started hydroponics.
- Does not fully understand pH, EC, or TDS.
- Wants clear safe ranges and corrective context.
- Prefers selecting a plant over creating technical settings.

**Primary needs**

- Simple status language.
- Plant-specific recommendations.
- Educational content.
- Clear warnings without excessive alerts.

## 6.2 Persona B — Experienced Grower

**Characteristics**

- Understands pH and nutrient concentration.
- May have a personal nutrient recipe.
- Wants control over limits and warning margins.
- Uses historical trends to adjust cultivation decisions.

**Primary needs**

- Custom recipes.
- Detailed reports.
- Reliable current values and timestamps.
- Fine-grained notification preferences.

## 6.3 Secondary Persona — Maintainer or Technical Operator

**Characteristics**

- Installs or maintains Arduino, ESP32, sensors, and tank configuration.
- Needs visibility into device and individual sensor availability.

**Primary needs**

- Device status.
- Last contact time.
- Sensor-specific failure indicators.
- Clear configuration errors.

---

## 7. Product Principles

1. **Current condition first.** Live status appears before reports or educational content.
2. **Clarity over density.** Primary screens avoid unnecessary technical jargon.
3. **No misleading freshness.** Every cached or stale value displays a timestamp and age.
4. **Backend-authoritative safety.** The backend determines warning, critical, recovery, persistence, cooldown, and deduplication states.
5. **Beginner-friendly, expert-capable.** Built-in profiles and custom recipes coexist.
6. **Graceful degradation.** Partial sensor failure does not hide healthy sensor readings.
7. **No alert spam.** One abnormal condition produces one lifecycle until recovery.
8. **MVP discipline.** Deferred automation and multi-tank features do not enter the first release.

---

## 8. System Context

```text
pH Sensor ───────────────┐
EC Sensor ───────────────┼──> Arduino ──Serial UART──> ESP32 ──Wi-Fi──> Backend/Cloud
Ultrasonic Level Sensor ─┘                                      │
                                                                ├── REST/API responses
                                                                ├── Realtime data channel
                                                                ├── Historical aggregation
                                                                └── Push notification service
                                                                           │
                                                                           v
                                                                      Flutter App
```

### 8.1 Arduino Responsibilities

- Read pH, EC, and ultrasonic sensor data.
- Apply device-level calibration and basic physical validation.
- Produce a structured reading payload.
- Send readings to the ESP32 over Serial UART.

### 8.2 ESP32 Responsibilities

- Receive structured readings from Arduino.
- Attach device identity and applicable timestamps.
- Send data to the backend through Wi-Fi.
- Retry temporary transmission failures.
- Report connectivity and device state when supported.

### 8.3 Backend Responsibilities

- Authenticate users and devices.
- Associate users, tanks, and devices.
- Accept and validate sensor readings.
- Store one-minute historical summaries.
- Provide current snapshots and aggregated reports.
- Evaluate thresholds, persistence durations, recovery windows, and cooldowns.
- Deduplicate alert lifecycles.
- Send push notifications.
- Store plant profiles, recipes, preferences, and alert history.

### 8.4 Flutter Responsibilities

- Authenticate the user.
- Display current and historical information.
- Subscribe to realtime sensor and device updates.
- Display backend-authoritative states.
- Manage user-controlled settings and recipes.
- Cache selected non-authoritative data for graceful offline presentation.
- Navigate from push notifications to the relevant alert context.

---

## 9. Information Architecture

The authenticated application uses exactly three primary bottom-navigation destinations:

1. **Beranda**
2. **Edukasi**
3. **Profil**

Reports remain inside Beranda.

```text
Login
└── Main Application
    ├── Beranda
    │   ├── Laporan Lengkap
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

## 10. Core User Journeys

## 10.1 Login and Monitor Tank

1. User opens the application.
2. User signs in with email and password.
3. Application loads the active tank and latest snapshot.
4. Application displays overall tank status and parameter values.
5. Application subscribes to realtime updates.
6. Incoming readings update the current status without manual refresh.

**Successful outcome:** The user understands the current tank condition and freshness of data.

## 10.2 Beginner Applies a Plant Profile

1. User opens Edukasi.
2. User searches for or selects a plant.
3. User opens the plant detail.
4. User reviews recommended pH, EC, TDS, and cultivation information.
5. User taps **Gunakan Profil Ini**.
6. Application asks for confirmation.
7. Backend applies the profile to the active tank.
8. Beranda displays the new profile name and target ranges.

**Successful outcome:** Recommended thresholds are applied without manual entry.

## 10.3 Experienced User Creates a Custom Recipe

1. User opens Profil → Resep Kustom.
2. User creates a recipe.
3. User enters valid pH and EC ranges, minimum water volume, warning margin, and optional persistence duration.
4. Frontend validates the form.
5. Backend validates and saves the recipe.
6. User activates the recipe.
7. Beranda reflects the active recipe and updated target ranges.

**Successful outcome:** The user's own recipe controls future evaluations.

## 10.4 Persistent Abnormal Condition

1. A parameter enters the warning margin.
2. Backend creates or updates a warning lifecycle.
3. If the value remains outside the safe range for the configured duration, backend escalates to critical.
4. User receives a push notification according to preferences.
5. Beranda and alert history show the current event.
6. When the condition remains safe for the recovery duration, backend marks the lifecycle recovered.
7. User may receive one recovery notification.

**Successful outcome:** The user is notified without repeated alerts for the same unresolved condition.

## 10.5 Device Goes Offline

1. Realtime updates stop.
2. Application shows reconnecting state.
3. Application preserves last known values with timestamps.
4. Backend or application identifies the device as stale or offline according to configured thresholds.
5. Beranda displays a prominent freshness or offline status.
6. When connectivity returns, the latest snapshot is loaded and realtime subscription resumes.

**Successful outcome:** Old values are never mistaken for current values.

---

## 11. Functional Requirements

Requirement priority uses:

- **P0:** Required for MVP release.
- **P1:** Important, but release may proceed with an explicitly approved limitation.
- **P2:** Deferred enhancement.

## 11.1 Authentication

### AUTH-001 — Email and Password Login (P0)

The application shall allow users to sign in using email and password.

**Acceptance criteria**

- Email and password fields are visible.
- Password visibility can be toggled.
- Empty and malformed inputs show inline validation.
- Login button shows an in-progress state during submission.
- Successful login opens the authenticated application.
- Invalid credentials display a readable Indonesian error.
- Network and server failures are distinguishable from invalid credentials.

### AUTH-002 — Session Persistence and Refresh (P0)

The application shall securely retain an authenticated session and refresh it when supported.

**Acceptance criteria**

- Tokens are stored in secure storage.
- Expired access tokens trigger one refresh attempt.
- Failed refresh returns the user to Login.
- Passwords are never stored.

### AUTH-003 — Logout (P0)

The application shall allow the user to end the session.

**Acceptance criteria**

- Logout is available under Profil.
- Secure tokens are removed.
- Cached user-specific sensitive data is cleared.
- User returns to Login.

### AUTH-004 — Password Reset Entry Point (P1)

A password-reset link shall be shown when backend support exists.

---

## 11.2 Main Application Shell

### NAV-001 — Three Primary Destinations (P0)

The bottom navigation shall contain exactly Beranda, Edukasi, and Profil.

**Acceptance criteria**

- The active tab is visually and semantically identifiable.
- Switching tabs preserves appropriate tab state.
- Reports do not appear as a fourth primary destination.
- Navigation labels support Indonesian text scaling without clipping.

### NAV-002 — Nested Navigation (P0)

Supporting screens shall open from their owning destination and return predictably.

---

## 11.3 Beranda — Current Monitoring

### HOME-001 — Tank Header (P0)

Beranda shall display:

- Active tank name.
- Active plant profile or recipe.
- Device status.
- Last successful update time.
- Notification unread count.

### HOME-002 — Main Water-Condition Card (P0)

Beranda shall display one large card containing pH, nutrient concentration, and water volume.

**Acceptance criteria**

- The card header displays aggregate status.
- Each parameter area displays value, unit, target, status, and freshness where relevant.
- Unavailable values use a placeholder and explanatory text, never zero.
- Critical status outranks warning.
- Color is accompanied by text and iconography.

### HOME-003 — pH Display (P0)

The pH area shall display:

- Current pH value.
- Target minimum and maximum.
- Backend-authoritative status.
- Last sensor timestamp when required.

### HOME-004 — EC and TDS Display (P0)

The nutrient area shall display:

- EC in mS/cm as the authoritative measurement.
- Estimated TDS in ppm.
- Target EC range.
- Backend-authoritative status.

**Constraints**

- Flutter shall not independently convert EC to TDS for authoritative data.
- The backend supplies TDS or the configured factor needed only for display.

### HOME-005 — Water Volume Display (P0)

The water area shall display:

- Estimated liters.
- Percentage of configured capacity.
- Minimum safe volume.
- Progress indicator.
- Backend-authoritative status.

### HOME-006 — Aggregate Tank Status (P0)

Supported aggregate states are:

- Normal.
- Warning.
- Critical.
- Data Terlambat.
- Offline.
- Data Tidak Lengkap.
- Belum Dikonfigurasi.

**Acceptance criteria**

- Critical outranks Warning.
- A partial sensor failure does not hide healthy sensor values.
- Old readings are accompanied by data age.
- Unconfigured state links to device or tank information.

### HOME-007 — Realtime Update (P0)

The dashboard shall update when new readings arrive through the realtime channel.

**Acceptance criteria**

- No manual refresh is required under normal connectivity.
- Only affected state areas rebuild where practical.
- Realtime disconnection shows reconnecting state.
- Snapshot polling is used as a fallback at a modest interval.

### HOME-008 — Pull-to-Refresh or Explicit Retry (P1)

The user shall be able to retry loading the latest snapshot after an error.

---

## 11.4 Reports

### REPORT-001 — Home Report Preview (P0)

Beranda shall contain one chart, not three simultaneous charts.

**Controls**

- Parameter: pH, EC/TDS, Volume.
- Period: Day, Week, Month.

**Statistics**

- Average.
- Minimum.
- Maximum.
- Warning count.
- Critical count.
- Abnormal duration when available.

### REPORT-002 — Detailed Report Screen (P0)

The application shall provide a detailed report screen opened from Beranda.

**Acceptance criteria**

- User can switch parameter and period.
- Historical line chart is shown when data exists.
- Average, minimum, maximum, sample count, warning count, critical count, and abnormal duration are shown.
- Incomplete data is clearly identified.
- Empty reports do not display fake zero-value lines.

### REPORT-003 — Backend Aggregation (P0)

Weekly and monthly reports shall use backend aggregation.

**Constraints**

- Flutter shall not download all raw historical readings for long periods.
- The backend stores one-minute summaries.
- Report responses shall contain prepared points and statistics.

### REPORT-004 — Remember Last Selection (P1)

The app should remember the last selected parameter and report period locally.

---

## 11.5 Alerts and Notifications

### ALERT-001 — Recent Alerts on Beranda (P0)

Beranda shall display the latest three to five events.

Each row displays:

- Parameter.
- Severity.
- Measured value.
- Target range.
- Start time.
- Duration or ongoing state.
- Recovery state when applicable.

### ALERT-002 — Alert History (P0)

The application shall provide complete chronological alert history.

**Acceptance criteria**

- Newest events appear first.
- Warning, critical, and recovered states are visually distinct.
- Ongoing alerts are labeled.
- Start and end timestamps are shown.
- An empty state is provided.
- Filtering is not required.

### ALERT-003 — Push Notifications (P0)

The user shall receive push notifications for enabled alert categories.

**Acceptance criteria**

- Notification opens relevant application context.
- Foreground, background, and terminated-state handling are supported where permitted by the platform.
- Monitoring remains usable if notification permission is denied.
- Permission status is shown in settings.

### ALERT-004 — Alert Lifecycle (P0)

The backend shall manage one lifecycle per parameter condition:

```text
Normal → Warning → Critical → Recovered
```

**Rules**

- Warning occurs near a configured limit.
- Critical occurs only after persistence outside the safe range.
- Recovery occurs only after persistence inside the safe range.
- Warning-to-critical escalation may send a new notification.
- Recovery may send one final notification.
- No repeated notifications are sent for the same unresolved state.

### ALERT-005 — User Preferences (P0)

The user shall be able to enable or disable:

- All push notifications.
- pH notifications.
- EC/TDS notifications.
- Volume notifications.
- Recovery notifications.

The frontend controls preferences only; severity logic remains backend-controlled.

---

## 11.6 Edukasi

### EDU-001 — Plant Grid (P0)

The Education page shall show a clean two-column grid on normal phone widths.

Each plant card displays:

- Plant image or illustration.
- Plant name.
- Difficulty.
- Short pH range.
- Short EC range.

There shall be no category filter in the MVP.

### EDU-002 — Plant Search (P0)

The Education page shall include a plant-name search field.

**Acceptance criteria**

- Search matches names and aliases.
- Search updates after a short debounce.
- No-result and network-error states are different.
- Clearing the query restores the plant list.

### EDU-003 — Plant Detail (P0)

The plant detail screen shall display:

- Image.
- Name and description.
- Difficulty.
- Ideal pH range.
- Ideal EC range.
- Estimated TDS range.
- Water-temperature range when available.
- Approximate growth or harvest duration.
- Nutrient and maintenance tips.
- Common problems.

### EDU-004 — Apply Built-In Profile (P0)

The user shall be able to apply a built-in profile to the active tank after confirmation.

**Acceptance criteria**

- Built-in profile remains read-only.
- Confirmation identifies the selected tank and profile.
- Successful application updates active profile state.
- Beranda target ranges refresh.

### EDU-005 — Copy as Custom Recipe (P0)

The user shall be able to create an editable custom recipe from a built-in profile.

---

## 11.7 Profil and Settings

### PROFILE-001 — Profile Overview (P0)

Profil shall display:

- User name and email.
- Active tank.
- Device status.
- Active plant profile or recipe.
- Links to notification settings, unit preferences, password change, and logout.

### TANK-001 — Tank Settings (P0)

The user shall be able to view and update:

- Tank name.
- Capacity in liters.
- Required geometry values.
- Minimum safe water volume.

**Validation**

- Capacity must be positive.
- Dimensions must be positive.
- Minimum safe volume must be lower than or equal to capacity.
- Frontend provides immediate validation.
- Backend remains authoritative.

### DEVICE-001 — Device Status (P0)

The device screen shall display:

- Device name or identifier.
- Connection state.
- Last contact time.
- pH sensor availability.
- EC sensor availability.
- Level sensor availability.
- Firmware or hardware information when supplied.

### DEVICE-002 — Unconfigured Device State (P0)

The frontend shall support an account with no associated device and explain that monitoring is unavailable.

Pairing and Wi-Fi provisioning are deferred.

### UNIT-001 — Unit Preferences (P1)

The user may choose supported display preferences such as TDS factor representation when exposed by backend configuration.

Authoritative EC values remain unchanged.

### PASSWORD-001 — Change Password (P1)

The application shall expose password change when backend support exists.

---

## 11.8 Custom Recipes

### RECIPE-001 — Recipe List (P0)

The user shall be able to view custom recipes and identify the active recipe.

### RECIPE-002 — Create Recipe (P0)

A custom recipe contains:

- Name.
- Minimum pH.
- Maximum pH.
- Minimum EC.
- Maximum EC.
- Minimum safe water volume.
- Warning margin.
- Alert persistence duration when user-editable.

### RECIPE-003 — Edit Recipe (P0)

The user shall be able to edit a custom recipe.

**Rules**

- Built-in profiles cannot be edited.
- Updating an active recipe affects future evaluations only.
- Historical alerts retain the target range active at event time.

### RECIPE-004 — Delete Recipe (P0)

The user shall be able to delete a non-active custom recipe.

If active-recipe deletion is supported, the backend must require a safe replacement or deactivate it explicitly.

### RECIPE-005 — Recipe Validation (P0)

**Acceptance criteria**

- Minimum values are lower than maximum values.
- Values remain inside backend-defined plausible ranges.
- Minimum water volume does not exceed tank capacity.
- Invalid fields show specific messages.
- Backend validation errors map to the correct fields.

### RECIPE-006 — Activate Recipe (P0)

The user shall be able to activate one built-in profile or one custom recipe for the active tank.

---

## 12. Status and Edge-State Requirements

## 12.1 Loading

- Use skeleton or structured loading states for primary content.
- Avoid replacing the entire application shell during local refreshes.

## 12.2 Stale Data

- Show the age of the latest reading.
- Distinguish stale data from confirmed device offline.
- Do not show a live indicator.

## 12.3 Device Offline

- Preserve last known values when available.
- Display last contact prominently.
- Disable misleading realtime indicators.

## 12.4 Partial Sensor Failure

- Continue displaying healthy sensors.
- Replace only failed parameter content.
- Aggregate status becomes Data Tidak Lengkap unless an available parameter is critical.

## 12.5 Backend Unreachable

- Show cached snapshot when available.
- Mark it as cached with timestamp.
- Provide retry.
- Keep cached educational content accessible when practical.

## 12.6 Session Expired

- Attempt token refresh once.
- Return to Login only after refresh failure.
- Warn before discarding unsaved recipe changes.

## 12.7 Notification Permission Denied

- Monitoring remains functional.
- Explain the consequence.
- Provide a path to operating-system settings where supported.

## 12.8 No Historical Data

- Explain that reports appear after data collection.
- Do not draw a flat zero line.

## 12.9 No Alerts

- Show a positive empty state without implying that monitoring is disconnected.

## 12.10 No Plant Search Results

- Suggest checking spelling or trying another name.
- Do not show a generic network error.

---

## 13. Data and Domain Model

## 13.1 User

```text
id
name
email
notificationPreferences
unitPreferences
```

## 13.2 Tank

```text
id
name
capacityLiters
dimensions
minimumSafeVolumeLiters
activeProfileId
deviceId
```

## 13.3 Device

```text
id
name
connectionStatus
lastSeenAt
sensorAvailability
firmwareVersion
hardwareInfo
```

## 13.4 SensorSnapshot

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

## 13.5 SensorReport

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
isComplete
```

## 13.6 AlertEvent

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
isRead
```

## 13.7 PlantProfile

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

## 13.8 CustomRecipe

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

## 13.9 NotificationPreferences

```text
globalEnabled
phEnabled
ecEnabled
volumeEnabled
recoveryEnabled
permissionStatus
```

---

## 14. Backend Contract Requirements

The backend may use REST, GraphQL, or another protocol, but the Flutter application requires equivalent operations.

## 14.1 Authentication

- Login.
- Refresh session.
- Logout.
- Request password reset.
- Change password when supported.

## 14.2 Dashboard

- Fetch active tank.
- Fetch current snapshot.
- Subscribe to sensor updates.
- Subscribe to device-state updates.

## 14.3 Reports

- Fetch aggregated report by tank, parameter, period, start, and end.
- Return chart points and summary statistics.
- Identify incomplete periods.

## 14.4 Alerts

- Fetch recent alerts.
- Fetch paginated full alert history.
- Fetch unread count.
- Mark alerts read when implemented.

## 14.5 Education

- Fetch plant list.
- Search plants.
- Fetch plant detail.
- Apply built-in profile to active tank.

## 14.6 Recipes and Settings

- Fetch custom recipes.
- Create custom recipe.
- Update custom recipe.
- Delete custom recipe.
- Activate built-in profile or custom recipe.
- Fetch and update tank settings.
- Fetch device status.
- Fetch and update notification preferences.
- Fetch and update supported unit preferences.

## 14.7 API Error Contract

Every error response shall provide:

```text
code: machine-readable error code
message: safe human-readable message
fieldErrors: optional field-to-message map
traceId: optional request or trace identifier
```

The Flutter client shall not parse arbitrary backend text to determine behavior.

## 14.8 Realtime Event Contract

Realtime events should include:

- Event type.
- Tank ID.
- Device ID when applicable.
- Event timestamp.
- Payload schema version.
- Snapshot or device-state payload.

Clients shall ignore unsupported event versions safely and trigger a snapshot refresh when necessary.

---

## 15. Data Processing and Alert Rules

## 15.1 Sampling and Storage

- Sensors may read continuously or at a device-defined interval.
- Important changes should be transmitted quickly.
- The backend stores one-minute summaries for reporting.
- Weekly and monthly responses use backend aggregation or downsampling.

## 15.2 Default Alert Model

Recommended configurable defaults:

- Warning begins when a value enters a margin near a safe limit.
- Critical begins after approximately three continuous minutes outside the safe range.
- Recovery occurs after approximately two continuous minutes inside the safe range.
- One unresolved condition creates one alert lifecycle.

The exact durations are backend configuration and shall not be hard-coded in Flutter.

## 15.3 Priority Rules

Recommended priority:

1. Critical available-parameter condition.
2. Device offline.
3. Stale data.
4. Warning available-parameter condition.
5. Partial sensor failure.
6. Normal.

The backend response should supply the aggregate state. Flutter uses local mapping only to render the returned state.

## 15.4 Historical Integrity

Alert records shall preserve:

- The measured value.
- The target range active at event creation.
- The profile or recipe reference where available.
- Start, escalation, and recovery timestamps.

Changing a recipe shall not rewrite historical alert targets.

---

## 16. Frontend Architecture Requirements

Use a feature-first Flutter architecture with focused responsibilities.

```text
lib/
├── app/
│   ├── routing/
│   ├── theme/
│   └── app.dart
├── core/
│   ├── config/
│   ├── errors/
│   ├── formatting/
│   ├── networking/
│   ├── realtime/
│   ├── storage/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── shell/
│   ├── dashboard/
│   ├── reports/
│   ├── alerts/
│   ├── education/
│   ├── plant_profile/
│   ├── profile/
│   ├── tank_settings/
│   ├── device_status/
│   ├── recipes/
│   └── notifications/
└── main.dart
```

### 16.1 Responsibility Boundaries

- Screens render state and user interactions.
- Controllers manage presentation state.
- Repositories expose domain operations.
- Data sources perform transport or local persistence.
- API details do not leak into widgets.
- Realtime sensor state remains isolated from historical report state.

### 16.2 Recommended Stack

- Flutter 3.44.3.
- Dart 3.12.2.
- Riverpod for state management.
- go_router for navigation.
- Dio for REST networking.
- web_socket_channel for realtime updates.
- flutter_secure_storage for tokens.
- shared_preferences for non-sensitive preferences and small cache metadata.
- fl_chart for reports.
- Firebase Messaging and local notifications for push behavior.
- Freezed and json_serializable for immutable models and serialization.

Exact dependency versions are locked in the implementation plan.

---

## 17. Local Storage and Caching

The application may store:

- Authentication tokens in secure storage.
- Last selected report parameter and period.
- Last successfully loaded snapshot with timestamps.
- Small plant-content cache.
- Non-sensitive display preferences.

The application shall not store:

- Passwords.
- Authoritative safety logic.
- Unencrypted authentication secrets.
- Sensor readings without timestamps.

Cached data must always include freshness metadata.

---

## 18. Visual and Interaction Requirements

## 18.1 Style Direction

- Clean, calm, modern, and beginner-friendly.
- Light neutral background.
- Green as primary brand and normal-status color.
- Rounded cards and controls.
- Plant imagery on Edukasi.
- Minimal technical jargon on primary screens.

## 18.2 Status Presentation

- Normal: green.
- Warning: amber or orange.
- Critical: red.
- Offline or unavailable: grey.

Color shall never be the only signal. Every state includes text and an icon.

## 18.3 Layout

- Current sensor values use strong visual hierarchy.
- Target ranges are visible but secondary.
- Use an eight-point spacing rhythm.
- Touch targets must be comfortable on small phones.
- Long Indonesian labels shall not clip.
- Beranda current status appears before the report section.

## 18.4 Accessibility

- Maintain readable contrast.
- Support screen-reader labels for controls, icons, and charts.
- Respect platform text scaling.
- Do not depend only on red-green distinction.
- Provide textual chart summaries.
- Preserve logical focus and reading order.

---

## 19. Non-Functional Requirements

## 19.1 Performance

- Initial authenticated shell should become interactive promptly on a typical mid-range Android device.
- Realtime readings should update visible values without reloading the entire page.
- Long report periods should use backend-prepared data.
- Education images should use sensible sizing and caching.

## 19.2 Reliability

- Realtime connection shall reconnect automatically.
- Snapshot polling shall provide fallback when realtime is unavailable.
- One malformed realtime event shall not terminate the stream permanently.
- Cached values shall survive temporary backend outages.

## 19.3 Security

- Use TLS for all backend and realtime traffic.
- Store tokens only in secure storage.
- Never log passwords or complete authentication tokens.
- Backend must enforce ownership of tanks, devices, recipes, reports, and alerts.
- Frontend validation complements but never replaces backend validation.
- Push payloads should avoid unnecessary sensitive information.

## 19.4 Privacy

- Collect only information required for account, device, tank, and monitoring operations.
- Provide a clear privacy policy before public release.
- Do not expose device identifiers or tank data across accounts.
- Define retention rules for sensor history and alert events before production launch.

## 19.5 Compatibility

- Android minimum SDK: 23.
- iOS support is included in the Flutter project, subject to signing and notification configuration.
- Layouts shall support common phone widths and text scaling.

## 19.6 Maintainability

- Use feature-first boundaries.
- Avoid screens that call APIs directly.
- Use immutable typed models.
- Keep repository interfaces testable with fakes.
- Require passing analysis and tests before merge.

---

## 20. Product Analytics and Operational Metrics

Analytics must not block MVP operation. When analytics is implemented, recommended events include:

- `login_succeeded`
- `login_failed`
- `dashboard_loaded`
- `realtime_connected`
- `realtime_disconnected`
- `report_opened`
- `report_parameter_changed`
- `plant_searched`
- `plant_profile_applied`
- `custom_recipe_created`
- `custom_recipe_activated`
- `notification_opened`
- `device_offline_viewed`

Recommended product metrics:

- Successful login rate.
- Dashboard load success rate.
- Median snapshot age when Beranda opens.
- Realtime connection success rate.
- Push-notification delivery and open rate.
- Percentage of users with an active plant profile or recipe.
- Report usage frequency.
- Number of duplicate notifications per alert lifecycle, target: zero.
- Crash-free session rate.

No analytics event should contain passwords, tokens, or unrestricted sensor payloads.

---

## 21. Testing and Quality Requirements

## 21.1 Unit Tests

Required coverage includes:

- Measurement formatting.
- EC and TDS display mapping.
- Volume percentage formatting.
- Status-priority rendering.
- Stale-data presentation.
- Report response mapping.
- Recipe validation.
- API error mapping.
- Realtime event decoding.

## 21.2 Widget Tests

Required coverage includes:

- Login validation and error states.
- Dashboard normal, warning, critical, stale, offline, and partial-failure states.
- Report parameter and period switching.
- Education search, empty, and error states.
- Plant-detail actions.
- Recipe form validation.
- Notification settings.

## 21.3 Integration Tests

The release candidate shall cover:

1. Login and dashboard load.
2. Live update changes the current card.
3. Realtime disconnect and fallback behavior.
4. Warning escalates to critical and later recovers.
5. Applying a plant profile changes target ranges.
6. Creating and activating a custom recipe.
7. Device offline and reconnect flow.
8. Notification navigation opens the relevant context.

## 21.4 Contract Tests

Fixtures shall be validated against backend schemas for:

- Current snapshot.
- Realtime event.
- Report response.
- Alert event.
- Plant profile.
- Custom recipe.
- API error.

## 21.5 Definition of Done

A feature is complete when:

- Acceptance criteria pass.
- Unit and widget tests pass.
- Integration impact is checked.
- `flutter analyze` passes without errors.
- User-facing text is Indonesian and reviewed for clarity.
- Loading, empty, error, stale, and offline states are handled where applicable.
- Accessibility labels are present.
- Backend contract changes are documented.
- No secret or environment-specific credential is committed.

---

## 22. Team Ownership

| Area | Frontend Owner | Backend/IoT Owner | Shared Decision |
|---|---:|---:|---:|
| Flutter UI and navigation | Yes | No | UX review |
| Client state and caching | Yes | No | Cache contract |
| REST/realtime client | Yes | API support | Schema |
| Authentication service | Client integration | Yes | Error behavior |
| Sensor reading and calibration | No | Yes | Units and limits |
| Arduino–ESP32 UART protocol | No | Yes | Payload schema |
| Device-to-cloud transport | No | Yes | Retry behavior |
| Alert evaluation and deduplication | No | Yes | Product rules |
| Push notification client | Yes | Service payload | Navigation contract |
| Historical aggregation | No | Yes | Report schema |
| Plant content presentation | Yes | Content/API | Data fields |
| Custom recipe UI | Yes | Validation/storage | Plausible ranges |
| QA and end-to-end acceptance | Yes | Yes | Joint |

---

## 23. Dependencies and Assumptions

### Dependencies

- Stable pH, EC, and ultrasonic sensor readings.
- Completed sensor calibration strategy.
- Reliable Serial UART payload between Arduino and ESP32.
- Backend authentication and ownership model.
- Realtime transport and snapshot endpoints.
- Historical aggregation.
- Push-notification credentials and platform setup.
- Plant-profile content and images.

### Assumptions

- One user account has one active tank in the MVP interface.
- The device is already associated with the user's account.
- Internet access is available for remote monitoring.
- EC is the authoritative nutrient measure.
- TDS is an estimated display value.
- Tank capacity and geometry are known or configured.
- Backend timestamps use a consistent standard such as UTC.
- The application converts timestamps to the user's local display time.

---

## 24. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Sensor drift or poor calibration | Misleading status | Device calibration workflow, plausible-range validation, sensor-health visibility |
| Ultrasonic readings fluctuate | False volume alerts | Device filtering, backend persistence window, tank-geometry validation |
| EC-to-TDS factor confusion | Inconsistent user interpretation | Treat EC as authoritative, label TDS as estimate, expose configured factor clearly |
| Network outages | Missing live updates | Cached snapshot, timestamps, reconnect, fallback polling |
| Notification spam | User disables notifications | Backend lifecycle deduplication and recovery logic |
| Backend and frontend schema drift | Runtime errors | Typed models, schema versioning, contract fixtures |
| Scope expansion | Delayed MVP | Enforce non-goals and deferred backlog |
| Plant recommendations vary by method or growth stage | Incorrect expectations | Present values as recommended ranges and include educational context |
| Small two-person team | Delivery bottlenecks | Feature-first boundaries, phased delivery, clear ownership, frequent integration |
| Unsaved recipe lost after session expiry | User frustration | Preserve form state and warn before discarding |

---

## 25. Delivery Phases

## Phase 1 — Foundation

- Flutter project and toolchain.
- Theme and application shell.
- Routing.
- Authentication.
- Shared networking and error handling.

**Exit criteria:** User can log in and reach the three-tab authenticated shell.

## Phase 2 — Monitoring

- Active tank loading.
- Current snapshot.
- Main condition card.
- Status, stale, offline, and partial-failure states.
- Realtime updates and fallback polling.

**Exit criteria:** Beranda reliably shows current or clearly timestamped cached data.

## Phase 3 — Reports and Alerts

- Report preview.
- Detailed report.
- Recent alerts.
- Alert history.
- Push notifications and deep navigation.

**Exit criteria:** User can understand trends and open alert context from a notification.

## Phase 4 — Education

- Plant grid.
- Search.
- Plant detail.
- Apply profile.
- Copy profile to custom recipe.

**Exit criteria:** Beginner can find a plant and apply its recommended profile.

## Phase 5 — Profile and Recipes

- Profile overview.
- Tank settings.
- Device status.
- Recipe CRUD and activation.
- Notification settings.
- Unit preferences.

**Exit criteria:** Experienced user can configure the tank and activate a custom recipe.

## Phase 6 — Hardening and Release Candidate

- Complete edge states.
- Accessibility review.
- Performance checks.
- Unit, widget, integration, and contract tests.
- Release configuration and documentation.

**Exit criteria:** Definition of Done and release checklist pass.

---

## 26. Release Acceptance Checklist

- [ ] Email/password authentication works.
- [ ] Bottom navigation contains only Beranda, Edukasi, and Profil.
- [ ] Beranda displays pH, EC, TDS, liters, and volume percentage.
- [ ] Each parameter displays a target range and status.
- [ ] Aggregate status handles normal, warning, critical, stale, offline, partial, and unconfigured states.
- [ ] Realtime updates work and reconnect gracefully.
- [ ] Cached values show timestamps and age.
- [ ] Daily, weekly, and monthly reports load.
- [ ] One chart switches between pH, EC/TDS, and volume.
- [ ] Alert history shows warning, critical, ongoing, and recovered events.
- [ ] Push notifications respect preferences and open relevant context.
- [ ] Education search and plant grid work without category filters.
- [ ] Plant detail shows recommended ranges and cultivation information.
- [ ] Built-in profile can be applied.
- [ ] Built-in profile can be copied into a custom recipe.
- [ ] Custom recipe validation and activation work.
- [ ] Tank and device states are visible under Profil.
- [ ] Notification permission denial does not block monitoring.
- [ ] No-data, error, stale, offline, and partial-sensor states have explicit UI.
- [ ] `flutter analyze` passes.
- [ ] Automated tests required by the implementation plan pass.
- [ ] No secret or production credential exists in the repository.

---

## 27. Future Backlog

The following items may be evaluated after the MVP is stable:

- Multi-tank switching and comparison.
- QR-based device pairing.
- In-app Wi-Fi provisioning.
- Automatic dosing and pH correction.
- Pump and irrigation control.
- Email and WhatsApp notifications.
- Report export.
- Plant-stage-specific profiles.
- Shared access for teams or families.
- Sensor calibration assistant.
- Maintenance reminders.
- Camera monitoring.
- Predictive recommendations and anomaly detection.
- Category filters in Edukasi when the content library becomes large.

---

## 28. Locked Product Decisions

- The product is an operational MVP, not only a classroom prototype.
- Monitoring works remotely through the internet.
- Arduino reads sensors and communicates with ESP32 using Serial UART.
- EC is authoritative; TDS/ppm is an estimated user-friendly display.
- Volume is displayed in liters and percentage using an ultrasonic sensor.
- Built-in plant profiles and user-created custom recipes are both supported.
- Warning and critical states require persistence to reduce false alarms.
- Push notifications and in-app alert history are included.
- The app displays current values and historical reports, not notifications alone.
- Important changes are transmitted quickly and one-minute summaries are stored.
- Authentication uses email and password.
- The primary navigation contains Beranda, Edukasi, and Profil only.
- Reports are located inside Beranda.
- Beranda displays current conditions before historical reports.
- pH, nutrient concentration, and volume share one main summary card.
- Edukasi contains search and a plant grid without category filters.
- One active tank is exposed in the MVP interface.
- Device pairing and Wi-Fi provisioning are deferred.

---

## 29. Reference Documents

This PRD is implemented and elaborated by:

- `docs/superpowers/specs/2026-07-23-hydroq-monitoring-app-design.md`
- `docs/superpowers/plans/2026-07-23-hydroq-flutter-mvp-implementation.md`

The frontend implementation plan is the task-level execution source. The design specification is the UX and architecture source. This PRD is the product-scope and acceptance source.
