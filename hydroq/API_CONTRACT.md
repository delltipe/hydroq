# HydroQ MVP API Contract

The production backend is authoritative for authentication, active tank/profile state, sensor freshness, alert lifecycle decisions, persistence duration, cooldown, notification delivery, and deduplication. The Flutter demo intentionally uses an in-process repository; `backend_mock/server.js` implements a compatible zero-dependency REST sandbox.

Base path: `/v1`  
Encoding: UTF-8 JSON  
Timestamps: UTC ISO 8601  
Authorization: `Bearer <accessToken>` outside login/refresh

## Endpoint matrix

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/auth/login` | Email/password authentication |
| `POST` | `/auth/refresh` | Refresh access token |
| `GET` | `/tanks` | Tanks available to the user |
| `GET` | `/tanks/{tankId}/snapshot` | Latest pH, EC/TDS, volume, freshness, and aggregate state |
| `PATCH` | `/tanks/{tankId}` | Update name, capacity, geometry, and minimum safe volume |
| `GET` | `/tanks/{tankId}/reports?metric=&period=` | Prepared historical points and summary statistics |
| `GET` | `/devices/{deviceId}` | Device, firmware, last contact, and sensor availability |
| `GET` | `/alerts` | Alert and recovery history, newest first |
| `GET` | `/plants?q=` | Built-in plant profiles and alias search |
| `GET` | `/plants/{plantId}` | Plant detail |
| `GET` | `/recipes` | Custom recipe list |
| `POST` | `/recipes` | Create custom recipe |
| `PATCH` | `/recipes/{recipeId}` | Edit or activate recipe |
| `DELETE` | `/recipes/{recipeId}` | Delete a non-active recipe |
| `GET` | `/users/me/notifications` | Read notification preferences |
| `PATCH` | `/users/me/notifications` | Update notification preferences |
| `POST` | `/devices/push-token` | Register or replace an FCM/APNs token in production |
| `WS` | `/realtime` | Snapshot, device-state, and alert lifecycle events |

## Authentication response

```json
{
  "accessToken": "opaque-short-lived-token",
  "refreshToken": "opaque-rotating-token",
  "expiresIn": 3600,
  "user": {
    "id": "user-demo",
    "name": "Pengguna HydroQ",
    "email": "demo@hydroq.app"
  }
}
```

## Snapshot example

```json
{
  "tankId": "tank-main",
  "tankName": "Tangki Utama",
  "profileName": "Selada",
  "deviceConfigured": true,
  "deviceOnline": true,
  "updatedAt": "2026-07-23T08:15:00Z",
  "overallState": "warning",
  "readings": {
    "ph": {
      "value": 6.2,
      "unit": "",
      "state": "normal",
      "capturedAt": "2026-07-23T08:15:00Z",
      "target": [5.5, 6.5]
    },
    "ec": {
      "value": 1.78,
      "unit": "mS/cm",
      "estimatedTds": 1139,
      "tdsFactor": 640,
      "state": "warning",
      "capturedAt": "2026-07-23T08:15:00Z",
      "target": [1.2, 1.8]
    },
    "volume": {
      "value": 42.5,
      "unit": "L",
      "percent": 71,
      "state": "normal",
      "capturedAt": "2026-07-23T08:15:00Z",
      "target": [18, 60]
    }
  }
}
```

A missing or failed sensor uses `"value": null` plus `"state": "unavailable"`; it must never be serialized as zero. Supported aggregate/reading states:

- `normal`
- `warning`
- `critical`
- `stale`
- `offline`
- `incomplete`
- `unavailable`

## Report response

```json
{
  "metric": "ec",
  "period": "weekly",
  "points": [
    {"label": "Sen", "value": 1.62},
    {"label": "Sel", "value": 1.71},
    {"label": "Rab", "value": 1.84}
  ],
  "summary": {
    "average": 1.72,
    "minimum": 1.62,
    "maximum": 1.84,
    "sampleCount": 3,
    "warningCount": 1,
    "criticalCount": 0,
    "abnormalDurationMinutes": 8
  }
}
```

Weekly and monthly responses are backend-aggregated from one-minute summaries. Empty periods return an empty `points` array and nullable summary values rather than fake zero-valued lines.

## Alert event

```json
{
  "id": "alert-1",
  "tankId": "tank-main",
  "title": "EC mendekati batas atas",
  "message": "Nutrisi mendekati batas atas rentang ideal untuk Selada.",
  "state": "warning",
  "metric": "EC",
  "valueText": "1.78 mS/cm",
  "targetRange": "1.2–1.8 mS/cm",
  "createdAt": "2026-07-23T08:15:00Z",
  "endedAt": null,
  "durationMinutes": 4,
  "resolved": false
}
```

The backend maintains one lifecycle per parameter condition:

```text
Normal → Warning → Critical → Recovered
```

No duplicate notification is emitted for the same unresolved state. Historical events retain the target range active at event time.

## Custom recipe

```json
{
  "id": "recipe-selada-pro",
  "name": "Selada Pro",
  "phMin": 5.6,
  "phMax": 6.4,
  "ecMin": 1.3,
  "ecMax": 1.8,
  "minimumVolumeLiters": 18,
  "warningMarginPercent": 10,
  "persistenceMinutes": 3,
  "sourcePlantId": "lettuce",
  "active": false
}
```

Validation errors use exact field names:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Data yang dikirim belum valid.",
    "fields": {
      "phMax": "Harus lebih besar dari pH minimum.",
      "minimumVolumeLiters": "Tidak boleh melebihi kapasitas tangki."
    }
  }
}
```

## Notification preferences

```json
{
  "allEnabled": true,
  "phEnabled": true,
  "ecEnabled": true,
  "volumeEnabled": true,
  "recoveryEnabled": true,
  "deviceOfflineEnabled": true
}
```

The frontend controls categories only. Severity, thresholds, persistence, cooldown, and deduplication remain backend-controlled.

## Realtime envelope

```json
{
  "type": "snapshot.updated",
  "eventId": "evt-2407",
  "occurredAt": "2026-07-23T08:15:00Z",
  "tankId": "tank-main",
  "data": {}
}
```

Supported production event types:

- `snapshot.updated`
- `device.online`
- `device.offline`
- `alert.warning`
- `alert.critical`
- `alert.recovered`
- `profile.activated`

## Device-to-backend reading payload

```json
{
  "deviceId": "HQ-ESP32-24071",
  "capturedAt": "2026-07-23T08:15:00Z",
  "ph": 6.2,
  "ecMsCm": 1.78,
  "waterDistanceCm": 12.4,
  "waterVolumeLiters": 42.5,
  "sensorHealth": {"ph": true, "ec": true, "level": true}
}
```

EC is authoritative. TDS/ppm is a display estimate supplied by the backend together with its configured factor.
