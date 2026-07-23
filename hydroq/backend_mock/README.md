# HydroQ Mock Backend

A zero-dependency Node.js REST server for exercising the HydroQ backend contract without a cloud account.

## Start

```bash
node server.js
```

Default base URL: `http://127.0.0.1:8787`

## Implemented demo endpoints

- `GET /health`
- `POST /v1/auth/login`
- `POST /v1/auth/refresh`
- `GET /v1/tanks`
- `GET/PATCH /v1/tanks/tank-main`
- `GET /v1/tanks/tank-main/snapshot`
- `GET /v1/tanks/tank-main/reports?metric=ph&period=daily`
- `GET /v1/devices/HQ-ESP32-24071`
- `GET /v1/plants?q=pak`
- `GET /v1/plants/:id`
- `GET /v1/alerts`
- `GET/POST /v1/recipes`
- `PATCH/DELETE /v1/recipes/:id`
- `GET/PATCH /v1/users/me/notifications`

State is stored in memory and resets when the server restarts. The current Flutter demo repository runs in-process for maximum portability; use `API_CONTRACT.md` when replacing it with a production repository.
