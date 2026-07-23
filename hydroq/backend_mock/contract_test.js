'use strict';

const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');

const port = 18787;
const child = spawn(process.execPath, ['server.js'], {
  cwd: __dirname,
  env: { ...process.env, PORT: String(port) },
  stdio: ['ignore', 'pipe', 'pipe'],
});

async function waitForHealth() {
  for (let attempt = 0; attempt < 40; attempt += 1) {
    try {
      const response = await fetch(`http://127.0.0.1:${port}/health`);
      if (response.ok) return;
    } catch (_) {
      // Server is still starting.
    }
    await new Promise((resolve) => setTimeout(resolve, 50));
  }
  throw new Error('Mock backend did not start in time.');
}

async function request(path, options) {
  const response = await fetch(`http://127.0.0.1:${port}${path}`, options);
  const body = response.status === 204 ? null : await response.json();
  return { response, body };
}

(async () => {
  try {
    await waitForHealth();

    const login = await request('/v1/auth/login', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email: 'demo@hydroq.app', password: 'hydroq123' }),
    });
    assert.equal(login.response.status, 200);
    assert.equal(login.body.user.email, 'demo@hydroq.app');

    const snapshot = await request('/v1/tanks/tank-main/snapshot');
    assert.equal(snapshot.response.status, 200);
    assert.equal(snapshot.body.readings.ec.unit, 'mS/cm');
    assert.ok(snapshot.body.readings.volume.percent > 0);

    const report = await request('/v1/tanks/tank-main/reports?metric=ec&period=weekly');
    assert.equal(report.response.status, 200);
    assert.equal(report.body.summary.sampleCount, 7);
    assert.ok(report.body.summary.abnormalDurationMinutes >= 0);

    const allPlants = await request('/v1/plants');
    assert.equal(allPlants.response.status, 200);
    assert.equal(allPlants.body.items.length, 8);

    const searchedPlants = await request('/v1/plants?q=sawi%20sendok');
    assert.equal(searchedPlants.response.status, 200);
    assert.equal(searchedPlants.body.items[0].id, 'pakcoy');

    const notificationPreferences = await request('/v1/users/me/notifications');
    assert.equal(notificationPreferences.response.status, 200);
    assert.equal(notificationPreferences.body.recoveryEnabled, true);

    const create = await request('/v1/recipes', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        name: 'Selada Pro', phMin: 5.6, phMax: 6.4, ecMin: 1.3, ecMax: 1.8,
        minimumVolumeLiters: 18, warningMarginPercent: 10, persistenceMinutes: 3,
      }),
    });
    assert.equal(create.response.status, 201);

    const activate = await request(`/v1/recipes/${create.body.id}`, {
      method: 'PATCH',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ active: true }),
    });
    assert.equal(activate.response.status, 200);
    assert.equal(activate.body.active, true);

    const activeSnapshot = await request('/v1/tanks/tank-main/snapshot');
    assert.equal(activeSnapshot.body.profileName, 'Selada Pro');
    assert.deepEqual(activeSnapshot.body.readings.ph.target, [5.6, 6.4]);

    const deleteActive = await request(`/v1/recipes/${create.body.id}`, { method: 'DELETE' });
    assert.equal(deleteActive.response.status, 409);

    const invalidTank = await request('/v1/tanks/tank-main', {
      method: 'PATCH',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ capacityLiters: 10 }),
    });
    assert.equal(invalidTank.response.status, 422);

    const invalid = await request('/v1/recipes', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        name: 'X', phMin: 7, phMax: 5, ecMin: 2, ecMax: 1,
        minimumVolumeLiters: 999, warningMarginPercent: 0, persistenceMinutes: 0,
      }),
    });
    assert.equal(invalid.response.status, 422);
    assert.equal(invalid.body.error.code, 'VALIDATION_ERROR');

    console.log('PASS: HydroQ mock backend contract tests');
  } finally {
    child.kill('SIGTERM');
  }
})().catch((error) => {
  console.error(error);
  child.kill('SIGTERM');
  process.exitCode = 1;
});
