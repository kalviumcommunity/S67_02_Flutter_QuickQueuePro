const db = require('../config/db.config');
const { AppError } = require('../middleware/error.middleware');

const getAllVendors = async (req, res, next) => {
  try {
    const [vendors] = await db.query(`
      SELECT
        v.id,
        v.name,
        v.category,
        v.address,
        v.phone,
        v.is_open,
        v.avg_service_minutes,
        COUNT(CASE WHEN q.status = 'waiting' THEN 1 END) AS current_queue_length
      FROM vendors v
      LEFT JOIN queues q ON q.vendor_id = v.id
      GROUP BY v.id
      ORDER BY v.name
    `);
    res.json({ vendors });
  } catch (err) {
    next(err);
  }
};

const getVendorById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(
      `SELECT v.*,
        COUNT(CASE WHEN q.status = 'waiting' THEN 1 END) AS current_queue_length
       FROM vendors v
       LEFT JOIN queues q ON q.vendor_id = v.id
       WHERE v.id = ?
       GROUP BY v.id`,
      [id]
    );
    if (rows.length === 0) return next(new AppError('Vendor not found', 404));
    res.json({ vendor: rows[0] });
  } catch (err) {
    next(err);
  }
};

const updateVendor = async (req, res, next) => {
  try {
    const { name, category, address, phone, is_open, avg_service_minutes } = req.body;
    // Only the owning vendor user (matched via user_id) may update
    await db.query(
      `UPDATE vendors
       SET name = ?, category = ?, address = ?, phone = ?,
           is_open = ?, avg_service_minutes = ?
       WHERE user_id = ?`,
      [name, category || null, address || null, phone || null,
       is_open ?? true, avg_service_minutes || 5, req.user.id]
    );
    const [rows] = await db.query(
      'SELECT * FROM vendors WHERE user_id = ?', [req.user.id]
    );
    res.json({ vendor: rows[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllVendors, getVendorById, updateVendor };
