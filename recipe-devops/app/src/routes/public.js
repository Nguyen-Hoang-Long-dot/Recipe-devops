'use strict';
const express = require('express');
const db = require('../db');
const { DIFFICULTY, splitSteps } = require('../util');

const router = express.Router();

// Trang chu: danh sach + tim kiem + loc theo danh muc
router.get('/', async (req, res, next) => {
  try {
    const q = String(req.query.q || '').trim().slice(0, 100);
    const categoryId = parseInt(req.query.category, 10) || null;

    const where = [];
    const params = [];
    if (q) {
      where.push('(r.title LIKE ? OR r.description LIKE ?)');
      params.push(`%${q}%`, `%${q}%`);
    }
    if (categoryId) {
      where.push('r.category_id = ?');
      params.push(categoryId);
    }

    const [recipes] = await db.query(
      `SELECT r.id, r.title, r.description, r.image_url, r.cook_time, r.servings, r.difficulty,
              r.views, c.name AS category_name
         FROM recipes r JOIN categories c ON c.id = r.category_id
        ${where.length ? 'WHERE ' + where.join(' AND ') : ''}
        ORDER BY r.created_at DESC, r.id DESC LIMIT 60`,
      params
    );
    const [categories] = await db.query(
      `SELECT c.id, c.name, COUNT(r.id) AS total
         FROM categories c LEFT JOIN recipes r ON r.category_id = c.id
        GROUP BY c.id, c.name ORDER BY c.name`
    );
    res.render('home', { title: 'Công thức nấu ăn', recipes, categories, q, categoryId, DIFFICULTY });
  } catch (e) { next(e); }
});

// Chi tiet cong thuc
router.get('/recipes/:id(\\d+)', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    const [rows] = await db.query(
      `SELECT r.*, c.name AS category_name FROM recipes r
         JOIN categories c ON c.id = r.category_id WHERE r.id = ?`, [id]);
    if (!rows.length) return next();
    const recipe = rows[0];
    const [ingredients] = await db.query(
      `SELECT i.name, ri.quantity FROM recipe_ingredients ri
         JOIN ingredients i ON i.id = ri.ingredient_id
        WHERE ri.recipe_id = ? ORDER BY i.name`, [id]);
    await db.query('UPDATE recipes SET views = views + 1 WHERE id = ?', [id]);
    res.render('recipe', {
      title: recipe.title, recipe, ingredients, steps: splitSteps(recipe.steps), DIFFICULTY,
    });
  } catch (e) { next(e); }
});

module.exports = router;
