'use strict';
const path = require('path');
const express = require('express');
const session = require('express-session');
const logger = require('./logger');
const db = require('./db');
const { waitForDb, ensureAdmin } = require('./bootstrap');
const metrics = require('./metrics');

const app = express();
app.disable('x-powered-by');
app.set('trust proxy', Number(process.env.TRUST_PROXY || 1)); // dang sau Nginx
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '..', 'views'));

app.use(metrics.middleware);

// Access log dang JSON (bo qua healthcheck / metrics cho do nhieu)
app.use((req, res, next) => {
  const start = process.hrtime.bigint();
  res.on('finish', () => {
    if (req.path === '/healthz' || req.path === '/metrics') return;
    logger.info('http_request', {
      method: req.method,
      path: req.originalUrl.split('?')[0],
      status: res.statusCode,
      ms: Number((process.hrtime.bigint() - start) / 1000000n),
      ip: req.ip,
    });
  });
  next();
});

app.use(express.urlencoded({ extended: false, limit: '100kb' }));
app.use('/static', express.static(path.join(__dirname, '..', 'public'), { maxAge: '1d' }));

app.use(session({
  name: 'sid',
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { httpOnly: true, sameSite: 'lax', secure: 'auto', maxAge: 2 * 60 * 60 * 1000 },
}));

app.get('/healthz', async (req, res) => {
  try {
    await db.query('SELECT 1');
    res.json({ status: 'ok' });
  } catch (e) {
    res.status(503).json({ status: 'db_unavailable' });
  }
});
// /metrics chi mo cho mang noi bo (Nginx chan route nay tu ben ngoai)
app.get('/metrics', metrics.handler);

app.use('/admin', require('./routes/admin'));
app.use('/', require('./routes/public'));

app.use((req, res) => res.status(404).render('404', { title: 'Không tìm thấy trang' }));

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  logger.error('unhandled_error', { path: req.path, error: err.message });
  res.status(500).render('error', { title: 'Lỗi hệ thống' });
});

(async () => {
  if (!process.env.SESSION_SECRET) throw new Error('Thieu SESSION_SECRET');
  await waitForDb();
  await ensureAdmin();
  const port = Number(process.env.PORT || 3000);
  app.listen(port, () => logger.info('server_started', { port }));
})().catch((e) => {
  logger.error('startup_failed', { error: e.message });
  process.exit(1);
});
