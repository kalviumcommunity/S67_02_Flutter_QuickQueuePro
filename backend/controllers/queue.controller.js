const db = require('../config/db.config');
const { AppError } = require('../middleware/error.middleware');

// ── Customer: join a vendor's queue ──────────────────────────
const joinQueue = async (req, res, next) => {
  try {
    const { vendor_id } = req.body;
    if (!vendor_id) return next(new AppError('vendor_id is required', 422));

    // Verify vendor exists and is open
    const [vendors] = await db.query(
      'SELECT id, is_open, avg_service_minutes FROM vendors WHERE id = ?',
      [vendor_id]
    );
    if (vendors.length === 0) return next(new AppError('Vendor not found', 404));
    if (!vendors[0].is_open) return next(new AppError('Vendor is currently closed', 400));

    // Block duplicate active tokens for the same vendor
    const [active] = await db.query(
      `SELECT id FROM queues
       WHERE vendor_id = ? AND customer_id = ? AND status IN ('waiting','serving')`,
      [vendor_id, req.user.id]
    );
    if (active.length > 0) {
      return next(new AppError('You already have an active token for this vendor', 409));
    }

    // Determine next token number
    const [countRows] = await db.query(
      `SELECT COUNT(*) AS cnt FROM queues WHERE vendor_id = ? AND DATE(created_at) = CURDATE()`,
      [vendor_id]
    );
    const tokenNumber = (countRows[0].cnt || 0) + 1;

    // Estimated wait: waiting queue length × avg service time
    const [waitRows] = await db.query(
      `SELECT COUNT(*) AS cnt FROM queues
       WHERE vendor_id = ? AND status = 'waiting'`,
      [vendor_id]
    );
    const estimatedWait = waitRows[0].cnt * vendors[0].avg_service_minutes;

    const [result] = await db.query(
      `INSERT INTO queues
         (vendor_id, customer_id, token_number, status, estimated_wait_minutes)
       VALUES (?, ?, ?, 'waiting', ?)`,
      [vendor_id, req.user.id, tokenNumber, estimatedWait]
    );

    const [queue] = await db.query(
      `SELECT q.*, v.name AS vendor_name,
              u.name AS customer_name
       FROM queues q
       JOIN vendors v ON v.id = q.vendor_id
       JOIN users   u ON u.id = q.customer_id
       WHERE q.id = ?`,
      [result.insertId]
    );

    res.status(201).json({ queue: queue[0] });
  } catch (err) {
    next(err);
  }
};

// ── Customer: list own active tokens ──────────────────────────
const getMyQueue = async (req, res, next) => {
  try {
    const [queues] = await db.query(
      `SELECT q.*, v.name AS vendor_name
       FROM queues q
       JOIN vendors v ON v.id = q.vendor_id
       WHERE q.customer_id = ? AND q.status IN ('waiting','serving')
       ORDER BY q.created_at DESC`,
      [req.user.id]
    );
    res.json({ queues });
  } catch (err) {
    next(err);
  }
};

// ── Customer: cancel own token ────────────────────────────────
const cancelQueue = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(
      `SELECT id, customer_id, status FROM queues WHERE id = ?`, [id]
    );
    if (rows.length === 0) return next(new AppError('Token not found', 404));
    if (rows[0].customer_id !== req.user.id) {
      return next(new AppError('Not authorised', 403));
    }
    if (rows[0].status !== 'waiting') {
      return next(new AppError('Only waiting tokens can be cancelled', 400));
    }
    await db.query(
      `UPDATE queues SET status = 'cancelled' WHERE id = ?`, [id]
    );
    res.json({ message: 'Token cancelled' });
  } catch (err) {
    next(err);
  }
};

// ── Vendor: view their queue ───────────────────────────────────
const getVendorQueue = async (req, res, next) => {
  try {
    const { vendorId } = req.params;
    const [queues] = await db.query(
      `SELECT q.*, v.name AS vendor_name,
              u.name AS customer_name
       FROM queues q
       JOIN vendors v ON v.id  = q.vendor_id
       JOIN users   u ON u.id  = q.customer_id
       WHERE q.vendor_id = ? AND q.status IN ('waiting','serving')
       ORDER BY q.token_number ASC`,
      [vendorId]
    );
    res.json({ queues });
  } catch (err) {
    next(err);
  }
};

// ── Vendor: serve the next customer ───────────────────────────
const serveNext = async (req, res, next) => {
  try {
    const { vendorId } = req.params;

    // Only the vendor who owns this queue may serve
    const [vendor] = await db.query(
      'SELECT id FROM vendors WHERE id = ? AND user_id = ?',
      [vendorId, req.user.id]
    );
    if (vendor.length === 0) {
      return next(new AppError('Not authorised or vendor not found', 403));
    }

    // Complete any currently serving token first
    await db.query(
      `UPDATE queues SET status = 'completed', served_at = NOW()
       WHERE vendor_id = ? AND status = 'serving'`,
      [vendorId]
    );

    // Promote the oldest waiting token to serving
    const [next_token] = await db.query(
      `SELECT id FROM queues
       WHERE vendor_id = ? AND status = 'waiting'
       ORDER BY token_number ASC LIMIT 1`,
      [vendorId]
    );

    if (next_token.length === 0) {
      return res.json({ message: 'Queue is empty' });
    }

    await db.query(
      `UPDATE queues SET status = 'serving' WHERE id = ?`,
      [next_token[0].id]
    );

    const [serving] = await db.query(
      `SELECT q.*, v.name AS vendor_name, u.name AS customer_name
       FROM queues q
       JOIN vendors v ON v.id = q.vendor_id
       JOIN users   u ON u.id = q.customer_id
       WHERE q.id = ?`,
      [next_token[0].id]
    );

    res.json({ message: 'Now serving', queue: serving[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { joinQueue, getMyQueue, cancelQueue, getVendorQueue, serveNext };
