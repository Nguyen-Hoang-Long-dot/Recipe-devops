'use strict';
const bcrypt = require('bcryptjs');
const db = require('./db');
const logger = require('./logger');

// Cho DB san sang (compose da co healthcheck nhung van retry cho chac)
async function waitForDb(retries = 30) {
  for (let i = 1; i <= retries; i++) {
    try {
      await db.query('SELECT 1');
      return;
    } catch (e) {
      logger.warn('db_not_ready', { attempt: i, error: e.code || e.message });
      await new Promise((r) => setTimeout(r, 2000));
    }
  }
  throw new Error('Khong ket noi duoc CSDL');
}

// Tao tai khoan admin tu bien moi truong neu chua co (mat khau luu dang bcrypt)
async function ensureAdmin() {
  const username = process.env.ADMIN_USERNAME || 'admin';
  const password = process.env.ADMIN_PASSWORD;
  if (!password) throw new Error('Thieu ADMIN_PASSWORD');
  const [rows] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
  if (rows.length) return;
  const hash = await bcrypt.hash(password, 12);
  await db.query('INSERT INTO users (username, password_hash) VALUES (?, ?)', [username, hash]);
  logger.info('admin_created', { username });
}

module.exports = { waitForDb, ensureAdmin };
