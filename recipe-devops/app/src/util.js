'use strict';
const crypto = require('crypto');

const DIFFICULTY = { easy: 'Dễ', medium: 'Trung bình', hard: 'Khó' };

// Moi dong: "Ten nguyen lieu | so luong"  (vd: "Thit ba chi | 500 g")
function parseIngredients(text) {
  const seen = new Set();
  const out = [];
  String(text || '').split(/\r?\n/).forEach((line) => {
    const [rawName, rawQty] = line.split('|');
    const name = (rawName || '').trim().slice(0, 150);
    const quantity = (rawQty || '').trim().slice(0, 100);
    if (!name || seen.has(name.toLowerCase())) return;
    seen.add(name.toLowerCase());
    out.push({ name, quantity });
  });
  return out;
}

function ingredientsToText(list) {
  return list.map((i) => `${i.name} | ${i.quantity || ''}`).join('\n');
}

function splitSteps(text) {
  return String(text || '').split(/\r?\n/).map((s) => s.trim()).filter(Boolean);
}

function isHttpUrl(value) {
  try {
    const u = new URL(value);
    return u.protocol === 'http:' || u.protocol === 'https:';
  } catch (e) {
    return false;
  }
}

function newToken() {
  return crypto.randomBytes(24).toString('hex');
}

module.exports = { DIFFICULTY, parseIngredients, ingredientsToText, splitSteps, isHttpUrl, newToken };
