'use strict';
const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../db');
const logger = require('../logger');
const { DIFFICULTY, parseIngredients, ingredientsToText, isHttpUrl, newToken } = require('../util');

const router = express.Router();

// ---- Tien ich chung cho khu vuc admin ----
router.use((req, res, next) => {
  res.locals.user = req.session.user || null;
  res.locals.flash = req.session.flash || null;
  delete req.session.flash;
  if (!req.session.csrf) req.session.csrf = newToken();
  res.locals.csrfToken = req.session.csrf;
  res.locals.DIFFICULTY = DIFFICULTY;
  next();
});

// Chong CSRF cho moi request thay doi du lieu
router.use((req, res, next) => {
  if (req.method === 'POST' && req.body._csrf !== req.session.csrf) {
    logger.warn('csrf_rejected', { path: req.originalUrl, ip: req.ip });
    return res.status(403).render('error', { title: 'Yêu cầu không hợp lệ' });
  }
  next();
});

function requireAuth(req, res, next) {
  if (!req.session.user) return res.redirect('/admin/login');
  next();
}

// ---- Dang nhap / dang xuat ----
router.get('/login', (req, res) => {
  if (req.session.user) return res.redirect('/admin');
  res.render('admin/login', { title: 'Đăng nhập quản trị', error: null });
});

router.post('/login', async (req, res, next) => {
  try {
    const username = String(req.body.username || '').trim().slice(0, 50);
    const password = String(req.body.password || '').slice(0, 200);
    const [rows] = await db.query('SELECT id, username, password_hash FROM users WHERE username = ?', [username]);
    const ok = rows.length && (await bcrypt.compare(password, rows[0].password_hash));
    if (!ok) {
      logger.warn('login_failed', { user: username, ip: req.ip });
      return res.status(401).render('admin/login', { title: 'Đăng nhập quản trị', error: 'Sai tên đăng nhập hoặc mật khẩu.' });
    }
    req.session.regenerate((err) => {
      if (err) return next(err);
      req.session.user = { id: rows[0].id, username: rows[0].username };
      req.session.csrf = newToken();
      logger.info('login_success', { user: rows[0].username, ip: req.ip });
      res.redirect('/admin');
    });
  } catch (e) { next(e); }
});

router.post('/logout', (req, res) => {
  const name = req.session.user && req.session.user.username;
  req.session.destroy(() => {
    logger.info('logout', { user: name });
    res.redirect('/');
  });
});

// ---- Bang dieu khien ----
router.get('/', requireAuth, async (req, res, next) => {
  try {
    const [recipes] = await db.query(
      `SELECT r.id, r.title, r.cook_time, r.difficulty, r.views, r.created_at, c.name AS category_name
         FROM recipes r JOIN categories c ON c.id = r.category_id ORDER BY r.id DESC`);
    res.render('admin/dashboard', { title: 'Quản trị công thức', recipes });
  } catch (e) { next(e); }
});

// ---- CRUD cong thuc ----
async function loadCategories() {
  const [cats] = await db.query('SELECT id, name FROM categories ORDER BY name');
  return cats;
}

function readRecipeForm(body) {
  const data = {
    title: String(body.title || '').trim().slice(0, 200),
    description: String(body.description || '').trim().slice(0, 2000),
    steps: String(body.steps || '').trim().slice(0, 10000),
    image_url: String(body.image_url || '').trim().slice(0, 500),
    cook_time: Math.min(Math.max(parseInt(body.cook_time, 10) || 0, 1), 1440),
    servings: Math.min(Math.max(parseInt(body.servings, 10) || 0, 1), 100),
    difficulty: ['easy', 'medium', 'hard'].includes(body.difficulty) ? body.difficulty : 'easy',
    category_id: parseInt(body.category_id, 10) || 0,
    ingredientsText: String(body.ingredients || ''),
  };
  data.ingredients = parseIngredients(data.ingredientsText);
  const errors = [];
  if (!data.title) errors.push('Tên món ăn không được để trống.');
  if (!data.steps) errors.push('Các bước thực hiện không được để trống.');
  if (!data.category_id) errors.push('Hãy chọn danh mục.');
  if (!data.ingredients.length) errors.push('Cần ít nhất một nguyên liệu.');
  if (data.image_url && !isHttpUrl(data.image_url)) errors.push('Link ảnh phải bắt đầu bằng http:// hoặc https://');
  return { data, errors };
}

async function saveRecipe(id, d) {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    let recipeId = id;
    const fields = [d.title, d.description || null, d.steps, d.image_url || null, d.cook_time, d.servings, d.difficulty, d.category_id];
    if (id) {
      await conn.query(
        `UPDATE recipes SET title=?, description=?, steps=?, image_url=?, cook_time=?, servings=?, difficulty=?, category_id=? WHERE id=?`,
        [...fields, id]);
      await conn.query('DELETE FROM recipe_ingredients WHERE recipe_id = ?', [id]);
    } else {
      const [r] = await conn.query(
        `INSERT INTO recipes (title, description, steps, image_url, cook_time, servings, difficulty, category_id) VALUES (?,?,?,?,?,?,?,?)`,
        fields);
      recipeId = r.insertId;
    }
    for (const ing of d.ingredients) {
      const [r] = await conn.query(
        'INSERT INTO ingredients (name) VALUES (?) ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)', [ing.name]);
      await conn.query(
        'INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity) VALUES (?,?,?)',
        [recipeId, r.insertId, ing.quantity || null]);
    }
    await conn.commit();
    return recipeId;
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    conn.release();
  }
}

router.get('/recipes/new', requireAuth, async (req, res, next) => {
  try {
    res.render('admin/recipe-form', {
      title: 'Thêm công thức', action: '/admin/recipes', errors: [],
      categories: await loadCategories(),
      recipe: { title: '', description: '', steps: '', image_url: '', cook_time: 30, servings: 2, difficulty: 'easy', category_id: 0 },
      ingredientsText: '',
    });
  } catch (e) { next(e); }
});

router.post('/recipes', requireAuth, async (req, res, next) => {
  try {
    const { data, errors } = readRecipeForm(req.body);
    if (errors.length) {
      return res.status(400).render('admin/recipe-form', {
        title: 'Thêm công thức', action: '/admin/recipes', errors,
        categories: await loadCategories(), recipe: data, ingredientsText: data.ingredientsText,
      });
    }
    const id = await saveRecipe(null, data);
    logger.info('recipe_created', { id, user: req.session.user.username });
    req.session.flash = 'Đã thêm công thức mới.';
    res.redirect('/admin');
  } catch (e) { next(e); }
});

router.get('/recipes/:id(\\d+)/edit', requireAuth, async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    const [rows] = await db.query('SELECT * FROM recipes WHERE id = ?', [id]);
    if (!rows.length) return next();
    const [ings] = await db.query(
      `SELECT i.name, ri.quantity FROM recipe_ingredients ri JOIN ingredients i ON i.id = ri.ingredient_id
        WHERE ri.recipe_id = ? ORDER BY i.name`, [id]);
    res.render('admin/recipe-form', {
      title: 'Sửa công thức', action: `/admin/recipes/${id}`, errors: [],
      categories: await loadCategories(), recipe: rows[0], ingredientsText: ingredientsToText(ings),
    });
  } catch (e) { next(e); }
});

router.post('/recipes/:id(\\d+)', requireAuth, async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    const { data, errors } = readRecipeForm(req.body);
    if (errors.length) {
      return res.status(400).render('admin/recipe-form', {
        title: 'Sửa công thức', action: `/admin/recipes/${id}`, errors,
        categories: await loadCategories(), recipe: data, ingredientsText: data.ingredientsText,
      });
    }
    const [exists] = await db.query('SELECT id FROM recipes WHERE id = ?', [id]);
    if (!exists.length) return next();
    await saveRecipe(id, data);
    logger.info('recipe_updated', { id, user: req.session.user.username });
    req.session.flash = 'Đã cập nhật công thức.';
    res.redirect('/admin');
  } catch (e) { next(e); }
});

router.post('/recipes/:id(\\d+)/delete', requireAuth, async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    await db.query('DELETE FROM recipes WHERE id = ?', [id]);
    await db.query('DELETE FROM ingredients WHERE id NOT IN (SELECT ingredient_id FROM recipe_ingredients)');
    logger.info('recipe_deleted', { id, user: req.session.user.username });
    req.session.flash = 'Đã xóa công thức.';
    res.redirect('/admin');
  } catch (e) { next(e); }
});

// ---- Danh muc ----
router.get('/categories', requireAuth, async (req, res, next) => {
  try {
    const [categories] = await db.query(
      `SELECT c.id, c.name, c.description, COUNT(r.id) AS total
         FROM categories c LEFT JOIN recipes r ON r.category_id = c.id
        GROUP BY c.id, c.name, c.description ORDER BY c.name`);
    res.render('admin/categories', { title: 'Quản lý danh mục', categories });
  } catch (e) { next(e); }
});

router.post('/categories', requireAuth, async (req, res, next) => {
  try {
    const name = String(req.body.name || '').trim().slice(0, 100);
    const description = String(req.body.description || '').trim().slice(0, 255);
    if (!name) {
      req.session.flash = 'Tên danh mục không được để trống.';
    } else {
      try {
        await db.query('INSERT INTO categories (name, description) VALUES (?, ?)', [name, description || null]);
        req.session.flash = 'Đã thêm danh mục.';
      } catch (e) {
        if (e.code !== 'ER_DUP_ENTRY') throw e;
        req.session.flash = 'Danh mục đã tồn tại.';
      }
    }
    res.redirect('/admin/categories');
  } catch (e) { next(e); }
});

router.post('/categories/:id(\\d+)/delete', requireAuth, async (req, res, next) => {
  try {
    await db.query('DELETE FROM categories WHERE id = ?', [parseInt(req.params.id, 10)]);
    req.session.flash = 'Đã xóa danh mục.';
  } catch (e) {
    if (e.code !== 'ER_ROW_IS_REFERENCED_2') return next(e);
    req.session.flash = 'Không thể xóa: danh mục vẫn còn công thức.';
  }
  res.redirect('/admin/categories');
});

module.exports = router;
