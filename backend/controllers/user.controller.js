const db = require('../config/db.config');
const { AppError } = require('../middleware/error.middleware');

const getProfile = async (req, res, next) => {
  try {
    const [rows] = await db.query(
      'SELECT id, name, email, role, phone, created_at FROM users WHERE id = ?',
      [req.user.id]
    );
    if (rows.length === 0) return next(new AppError('User not found', 404));
    res.json({ user: rows[0] });
  } catch (err) {
    next(err);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { name, phone } = req.body;
    await db.query(
      'UPDATE users SET name = ?, phone = ? WHERE id = ?',
      [name, phone || null, req.user.id]
    );
    const [rows] = await db.query(
      'SELECT id, name, email, role, phone, created_at FROM users WHERE id = ?',
      [req.user.id]
    );
    res.json({ user: rows[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { getProfile, updateProfile };
