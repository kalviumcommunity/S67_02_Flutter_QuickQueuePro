const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { body } = require('express-validator');
const db       = require('../config/db.config');
const { AppError } = require('../middleware/error.middleware');
const { validate } = require('../middleware/validator.middleware');

// ── Validation chains ─────────────────────────────────────────
const registerRules = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Valid email required').normalizeEmail(),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 chars'),
  body('role').isIn(['customer', 'vendor']).withMessage('Role must be customer or vendor'),
];

const loginRules = [
  body('email').isEmail().withMessage('Valid email required').normalizeEmail(),
  body('password').notEmpty().withMessage('Password is required'),
];

// ── Helpers ───────────────────────────────────────────────────
const signToken = (payload) =>
  jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });

// ── Controllers ───────────────────────────────────────────────
const register = [
  ...registerRules,
  validate,
  async (req, res, next) => {
    try {
      const { name, email, password, role, phone } = req.body;

      const [existing] = await db.query(
        'SELECT id FROM users WHERE email = ?', [email]
      );
      if (existing.length > 0) {
        return next(new AppError('Email already registered', 409));
      }

      const passwordHash = await bcrypt.hash(password, 12);
      const [result] = await db.query(
        'INSERT INTO users (name, email, password_hash, role, phone) VALUES (?, ?, ?, ?, ?)',
        [name, email, passwordHash, role, phone || null]
      );

      const userId = result.insertId;

      // If vendor, create vendor profile too
      if (role === 'vendor') {
        await db.query(
          'INSERT INTO vendors (user_id, name) VALUES (?, ?)',
          [userId, name]
        );
      }

      const token = signToken({ id: userId, role });
      const [rows] = await db.query(
        'SELECT id, name, email, role, phone, created_at FROM users WHERE id = ?',
        [userId]
      );

      res.status(201).json({ token, user: rows[0] });
    } catch (err) {
      next(err);
    }
  },
];

const login = [
  ...loginRules,
  validate,
  async (req, res, next) => {
    try {
      const { email, password } = req.body;

      const [rows] = await db.query(
        'SELECT id, name, email, password_hash, role, phone, created_at FROM users WHERE email = ?',
        [email]
      );
      if (rows.length === 0) {
        return next(new AppError('Invalid email or password', 401));
      }

      const user = rows[0];
      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return next(new AppError('Invalid email or password', 401));
      }

      const token = signToken({ id: user.id, role: user.role });
      const { password_hash, ...safeUser } = user;

      res.json({ token, user: safeUser });
    } catch (err) {
      next(err);
    }
  },
];

module.exports = { register, login };
