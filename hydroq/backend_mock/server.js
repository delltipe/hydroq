'use strict';

const http = require('node:http');
const { URL } = require('node:url');

const port = Number(process.env.PORT || 8787);
const startedAt = new Date();

const plants = [
  { id: 'lettuce', name: 'Selada', aliases: ['lettuce'], difficulty: 'Pemula', category: 'Sayuran daun', phMin: 5.5, phMax: 6.5, ecMin: 1.2, ecMax: 1.8, waterTempMin: 18, waterTempMax: 24, daysToHarvest: 35 },
  { id: 'pakcoy', name: 'Pakcoy', aliases: ['pak choi', 'bok choy', 'sawi sendok'], difficulty: 'Pemula', category: 'Sayuran daun', phMin: 5.8, phMax: 6.5, ecMin: 1.5, ecMax: 2.0, waterTempMin: 18, waterTempMax: 24, daysToHarvest: 40 },
  { id: 'water-spinach', name: 'Kangkung', aliases: ['water spinach'], difficulty: 'Pemula', category: 'Sayuran daun', phMin: 5.5, phMax: 6.5, ecMin: 1.5, ecMax: 2.0, waterTempMin: 18, waterTempMax: 26, daysToHarvest: 28 },
  { id: 'spinach', name: 'Bayam', aliases: ['spinach'], difficulty: 'Pemula', category: 'Sayuran daun', phMin: 5.8, phMax: 6.5, ecMin: 1.8, ecMax: 2.3, waterTempMin: 18, waterTempMax: 24, daysToHarvest: 32 },
  { id: 'tomato', name: 'Tomat', aliases: ['tomato'], difficulty: 'Menengah', category: 'Tanaman buah', phMin: 5.5, phMax: 6.5, ecMin: 2.0, ecMax: 3.5, waterTempMin: 18, waterTempMax: 24, daysToHarvest: 85 },
  { id: 'strawberry', name: 'Stroberi', aliases: ['strawberry'], difficulty: 'Menengah', category: 'Tanaman buah', phMin: 5.5, phMax: 6.2, ecMin: 1.4, ecMax: 2.0, waterTempMin: 16, waterTempMax: 22, daysToHarvest: 95 },
  { id: 'basil', name: 'Basil', aliases: ['kemangi italia'], difficulty: 'Pemula', category: 'Herbal', phMin: 5.5, phMax: 6.5, ecMin: 1.0, ecMax: 1.6, waterTempMin: 18, waterTempMax: 24, daysToHarvest: 45 },
  { id: 'cucumber', name: 'Mentimun', aliases: ['timun', 'cucumber'], difficulty: 'Menengah', category: 'Tanaman buah', phMin: 5.5, phMax: 6.5, ecMin: 1.7, ecMax: 2.5, waterTempMin: 18, waterTempMax: 24, daysToHarvest: 60 },
];

let tank = {
  id: 'tank-main',
  name: 'Tangki Utama',
  capacityLiters: 60,
  heightCm: 45,
  minimumSafeVolumeLiters: 18,
  activeProfile: { type: 'plant', id: 'lettuce', name: 'Selada' },
};

let notificationPreferences = {
  allEnabled: true,
  phEnabled: true,
  ecEnabled: true,
  volumeEnabled: true,
  recoveryEnabled: true,
  deviceOfflineEnabled: true,
};

let recipes = [];

const alerts = [
  {
    id: 'alert-1',
    state: 'warning',
    metric: 'ec',
    valueText: '1.78 mS/cm',
    targetRange: '1.2–1.8 mS/cm',
    title: 'EC mendekati batas atas',
    message: 'Nutrisi mendekati batas atas rentang ideal untuk Selada.',
    createdAt: new Date(Date.now() - 18 * 60_000).toISOString(),
    durationMinutes: 4,
    resolved: false,
  },
  {
    id: 'alert-2',
    state: 'normal',
    metric: 'volume',
    valueText: '42.5 L',
    targetRange: '≥ 18 L',
    title: 'Volume kembali stabil',
    message: 'Volume air kembali di atas batas minimum.',
    createdAt: new Date(Date.now() - 3 * 3_600_000).toISOString(),
    endedAt: new Date(Date.now() - 3 * 3_600_000).toISOString(),
    resolved: true,
  },
];

function classify(value, minimum, maximum, warningMarginPercent = 10) {
  if (value < minimum || value > maximum) return 'critical';
  const margin = (maximum - minimum) * Math.min(Math.max(warningMarginPercent, 0), 50) / 100;
  if (value <= minimum + margin || value >= maximum - margin) return 'warning';
  return 'normal';
}

function activeTargets() {
  if (tank.activeProfile.type === 'recipe') {
    const recipe = recipes.find((item) => item.id === tank.activeProfile.id);
    if (recipe) {
      return {
        ph: [recipe.phMin, recipe.phMax],
        ec: [recipe.ecMin, recipe.ecMax],
        volume: [recipe.minimumVolumeLiters, tank.capacityLiters],
        warningMarginPercent: recipe.warningMarginPercent,
      };
    }
  }
  const plant = plants.find((item) => item.id === tank.activeProfile.id) || plants[0];
  return {
    ph: [plant.phMin, plant.phMax],
    ec: [plant.ecMin, plant.ecMax],
    volume: [tank.minimumSafeVolumeLiters, tank.capacityLiters],
    warningMarginPercent: 10,
  };
}

function snapshot() {
  const seconds = Math.floor((Date.now() - startedAt.getTime()) / 1000);
  const ec = 1.78 + Math.sin(seconds / 6) * 0.07;
  const ph = 6.2 + Math.sin(seconds / 8) * 0.08;
  const volume = 42.5;
  const targets = activeTargets();
  const phState = classify(ph, targets.ph[0], targets.ph[1], targets.warningMarginPercent);
  const ecState = classify(ec, targets.ec[0], targets.ec[1], targets.warningMarginPercent);
  const volumeState = classify(volume, targets.volume[0], targets.volume[1], targets.warningMarginPercent);
  const states = [phState, ecState, volumeState];
  const overallState = states.includes('critical') ? 'critical' : states.includes('warning') ? 'warning' : 'normal';
  const capturedAt = new Date().toISOString();
  return {
    tankId: tank.id,
    tankName: tank.name,
    profileName: tank.activeProfile.name,
    deviceOnline: true,
    deviceConfigured: true,
    updatedAt: capturedAt,
    overallState,
    readings: {
      ph: { value: ph, unit: '', state: phState, capturedAt, target: targets.ph },
      ec: { value: ec, unit: 'mS/cm', estimatedTds: Math.round(ec * 640), tdsFactor: 640, state: ecState, capturedAt, target: targets.ec },
      volume: { value: volume, unit: 'L', percent: Math.round((volume / tank.capacityLiters) * 100), state: volumeState, capturedAt, target: targets.volume },
    },
  };
}

function report(metric = 'ph', period = 'daily') {
  const count = period === 'weekly' ? 7 : 12;
  const points = Array.from({ length: count }, (_, index) => {
    let value;
    if (metric === 'ec') value = 1.63 + Math.sin(index / 1.8) * 0.2 + index * 0.012;
    else if (metric === 'volume') value = 53 - index * (period === 'monthly' ? 1.2 : 0.72) + Math.sin(index) * 1.4;
    else value = 6.05 + Math.sin(index / 1.6) * 0.18 + Math.cos(index / 2.5) * 0.06;
    const label = period === 'daily'
      ? `${String(index * 2).padStart(2, '0')}:00`
      : period === 'weekly'
        ? ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][index]
        : `M${index + 1}`;
    return { label, value: Number(value.toFixed(metric === 'ec' ? 2 : 1)) };
  });
  const values = points.map((point) => point.value);
  return {
    metric,
    period,
    points,
    summary: {
      average: values.reduce((a, b) => a + b, 0) / values.length,
      minimum: Math.min(...values),
      maximum: Math.max(...values),
      sampleCount: values.length,
      warningCount: metric === 'ec' ? 2 : 1,
      criticalCount: metric === 'ph' ? 1 : 0,
      abnormalDurationMinutes: metric === 'ec' ? 18 : metric === 'ph' ? 6 : 0,
    },
  };
}

function json(res, statusCode, body) {
  if (statusCode === 204) {
    res.writeHead(204, corsHeaders());
    return res.end();
  }
  const payload = JSON.stringify(body, null, 2);
  res.writeHead(statusCode, {
    ...corsHeaders(),
    'content-type': 'application/json; charset=utf-8',
    'content-length': Buffer.byteLength(payload),
  });
  res.end(payload);
}

function corsHeaders() {
  return {
    'access-control-allow-origin': '*',
    'access-control-allow-headers': 'authorization, content-type',
    'access-control-allow-methods': 'GET, POST, PATCH, DELETE, OPTIONS',
    'cache-control': 'no-store',
  };
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 1_000_000) req.destroy();
    });
    req.on('end', () => {
      if (!data) return resolve({});
      try { resolve(JSON.parse(data)); } catch (error) { reject(error); }
    });
    req.on('error', reject);
  });
}

function validationError(res, fields) {
  return json(res, 422, {
    error: {
      code: 'VALIDATION_ERROR',
      message: 'Data yang dikirim belum valid.',
      fields,
    },
  });
}

function validateRecipe(body) {
  const fields = {};
  if (String(body.name || '').trim().length < 3) fields.name = 'Nama minimal 3 karakter.';
  for (const key of ['phMin', 'phMax', 'ecMin', 'ecMax', 'minimumVolumeLiters']) {
    if (!Number.isFinite(Number(body[key]))) fields[key] = 'Wajib berupa angka.';
  }
  if (Number(body.phMin) >= Number(body.phMax)) fields.phMax = 'Harus lebih besar dari pH minimum.';
  if (Number(body.ecMin) >= Number(body.ecMax)) fields.ecMax = 'Harus lebih besar dari EC minimum.';
  if (Number(body.minimumVolumeLiters) > tank.capacityLiters) fields.minimumVolumeLiters = 'Tidak boleh melebihi kapasitas tangki.';
  const margin = Number(body.warningMarginPercent);
  if (!Number.isInteger(margin) || margin < 1 || margin > 50) fields.warningMarginPercent = 'Harus 1–50%.';
  const persistence = Number(body.persistenceMinutes);
  if (!Number.isInteger(persistence) || persistence < 1 || persistence > 60) fields.persistenceMinutes = 'Harus 1–60 menit.';
  return fields;
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') return json(res, 204, null);
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  try {
    if (req.method === 'GET' && url.pathname === '/health') {
      return json(res, 200, { status: 'ok', service: 'hydroq-mock-backend', now: new Date().toISOString() });
    }
    if (req.method === 'POST' && url.pathname === '/v1/auth/login') {
      const body = await readJson(req);
      if (!String(body.email || '').includes('@') || String(body.password || '').length < 6) {
        return validationError(res, { credentials: 'Email atau kata sandi tidak valid.' });
      }
      return json(res, 200, {
        accessToken: 'demo-access-token',
        refreshToken: 'demo-refresh-token',
        expiresIn: 3600,
        user: { id: 'user-demo', name: 'Pengguna HydroQ', email: body.email },
      });
    }
    if (req.method === 'POST' && url.pathname === '/v1/auth/refresh') {
      return json(res, 200, { accessToken: 'demo-access-token-refreshed', expiresIn: 3600 });
    }
    if (req.method === 'GET' && url.pathname === '/v1/tanks') {
      return json(res, 200, { items: [tank] });
    }
    if (req.method === 'GET' && url.pathname === `/v1/tanks/${tank.id}/snapshot`) {
      return json(res, 200, snapshot());
    }
    if (req.method === 'PATCH' && url.pathname === `/v1/tanks/${tank.id}`) {
      const body = await readJson(req);
      const next = { ...tank, ...body, id: tank.id };
      const activeRecipe = tank.activeProfile.type === 'recipe'
        ? recipes.find((recipe) => recipe.id === tank.activeProfile.id)
        : null;
      const activeMinimum = activeRecipe ? Number(activeRecipe.minimumVolumeLiters) : 0;
      if (
        Number(next.capacityLiters) <= 0 ||
        Number(next.heightCm) <= 0 ||
        Number(next.minimumSafeVolumeLiters) > Number(next.capacityLiters) ||
        activeMinimum > Number(next.capacityLiters)
      ) {
        return validationError(res, { tank: 'Periksa kapasitas, tinggi, minimum volume, dan resep aktif.' });
      }
      tank = next;
      return json(res, 200, tank);
    }
    if (req.method === 'GET' && url.pathname === `/v1/tanks/${tank.id}/reports`) {
      return json(res, 200, report(url.searchParams.get('metric') || 'ph', url.searchParams.get('period') || 'daily'));
    }
    if (req.method === 'GET' && url.pathname === '/v1/devices/HQ-ESP32-24071') {
      return json(res, 200, {
        id: 'HQ-ESP32-24071', name: 'HydroQ Hub', online: true, firmwareVersion: '1.0.0', wifiName: 'Greenhouse-WiFi',
        lastSeen: new Date().toISOString(), sensors: { ph: true, ec: true, level: true },
      });
    }
    if (req.method === 'GET' && url.pathname === '/v1/plants') {
      const query = String(url.searchParams.get('q') || '').toLowerCase().trim();
      const items = query
        ? plants.filter((plant) => plant.name.toLowerCase().includes(query) || plant.aliases.some((alias) => alias.includes(query)))
        : plants;
      return json(res, 200, { items });
    }
    if (req.method === 'GET' && url.pathname.startsWith('/v1/plants/')) {
      const id = url.pathname.split('/').pop();
      const plant = plants.find((item) => item.id === id);
      return plant ? json(res, 200, plant) : json(res, 404, { error: { code: 'NOT_FOUND', message: 'Profil tanaman tidak ditemukan.' } });
    }
    if (req.method === 'GET' && url.pathname === '/v1/alerts') {
      return json(res, 200, { items: alerts });
    }
    if (req.method === 'GET' && url.pathname === '/v1/recipes') {
      return json(res, 200, { items: recipes });
    }
    if (req.method === 'POST' && url.pathname === '/v1/recipes') {
      const body = await readJson(req);
      const fields = validateRecipe(body);
      if (Object.keys(fields).length) return validationError(res, fields);
      const recipe = { ...body, id: `recipe-${Date.now()}`, active: false };
      recipes.push(recipe);
      return json(res, 201, recipe);
    }
    if ((req.method === 'PATCH' || req.method === 'DELETE') && url.pathname.startsWith('/v1/recipes/')) {
      const id = url.pathname.split('/').pop();
      const index = recipes.findIndex((recipe) => recipe.id === id);
      if (index < 0) return json(res, 404, { error: { code: 'NOT_FOUND', message: 'Resep tidak ditemukan.' } });
      if (req.method === 'DELETE') {
        if (recipes[index].active) return json(res, 409, { error: { code: 'ACTIVE_RECIPE', message: 'Resep aktif tidak dapat dihapus.' } });
        recipes.splice(index, 1);
        return json(res, 204, null);
      }
      const body = await readJson(req);
      const candidate = { ...recipes[index], ...body, id };
      const fields = validateRecipe(candidate);
      if (Object.keys(fields).length) return validationError(res, fields);
      if (body.active === true) recipes = recipes.map((recipe) => ({ ...recipe, active: recipe.id === id }));
      const refreshedIndex = recipes.findIndex((recipe) => recipe.id === id);
      recipes[refreshedIndex] = { ...recipes[refreshedIndex], ...candidate, active: body.active === true ? true : candidate.active };
      if (recipes[refreshedIndex].active) tank.activeProfile = { type: 'recipe', id, name: recipes[refreshedIndex].name };
      return json(res, 200, recipes[refreshedIndex]);
    }
    if (req.method === 'GET' && url.pathname === '/v1/users/me/notifications') {
      return json(res, 200, notificationPreferences);
    }
    if (req.method === 'PATCH' && url.pathname === '/v1/users/me/notifications') {
      notificationPreferences = { ...notificationPreferences, ...(await readJson(req)) };
      return json(res, 200, notificationPreferences);
    }
    return json(res, 404, { error: { code: 'NOT_FOUND', message: 'Endpoint tidak ditemukan.' } });
  } catch (error) {
    return json(res, 400, { error: { code: 'INVALID_JSON', message: 'Body JSON tidak valid.' } });
  }
});

server.listen(port, '127.0.0.1', () => {
  console.log(`HydroQ mock backend listening on http://127.0.0.1:${port}`);
});

function shutdown() {
  server.close(() => process.exit(0));
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
