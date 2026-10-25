'use strict';
// Log dang JSON (1 dong / su kien) de Promtail/Loki parse bang LogQL "| json".
function write(level, msg, extra) {
  const line = JSON.stringify({ ts: new Date().toISOString(), level, msg, ...(extra || {}) });
  (level === 'error' ? process.stderr : process.stdout).write(line + '\n');
}

module.exports = {
  info: (msg, extra) => write('info', msg, extra),
  warn: (msg, extra) => write('warn', msg, extra),
  error: (msg, extra) => write('error', msg, extra),
};
