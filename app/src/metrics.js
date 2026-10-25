'use strict';
const client = require('prom-client');
const db = require('./db');

const register = new client.Registry();
client.collectDefaultMetrics({ register }); // CPU, heap, event loop lag cua Node.js

const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Tong so HTTP request',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Thoi gian xu ly HTTP request (giay)',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [register],
});

// Gauge nghiep vu: lay truc tiep tu DB moi lan Prometheus scrape
new client.Gauge({
  name: 'recipes_total',
  help: 'So cong thuc trong CSDL',
  registers: [register],
  async collect() {
    try {
      const [rows] = await db.query('SELECT COUNT(*) AS n FROM recipes');
      this.set(Number(rows[0].n));
    } catch (e) { /* DB tam thoi loi: bo qua */ }
  },
});

new client.Gauge({
  name: 'recipe_views_total',
  help: 'Tong luot xem cong thuc',
  registers: [register],
  async collect() {
    try {
      const [rows] = await db.query('SELECT COALESCE(SUM(views),0) AS n FROM recipes');
      this.set(Number(rows[0].n));
    } catch (e) { /* bo qua */ }
  },
});

function middleware(req, res, next) {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    const route = req.route
      ? ((req.baseUrl || '') + req.route.path).replace(/\([^)]*\)/g, '') // bo regex (\\d+) khoi nhan
      : 'unmatched';
    const labels = { method: req.method, route, status_code: res.statusCode };
    httpRequests.inc(labels);
    end(labels);
  });
  next();
}

async function handler(req, res) {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
}

module.exports = { middleware, handler };
