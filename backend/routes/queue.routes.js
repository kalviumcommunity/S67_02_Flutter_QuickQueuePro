const express = require('express');
const {
  joinQueue,
  getMyQueue,
  cancelQueue,
  getVendorQueue,
  serveNext,
} = require('../controllers/queue.controller');
const { authenticate, requireRole } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(authenticate);

// Customer routes
router.post('/join',                      requireRole('customer'), joinQueue);
router.get('/my',                         requireRole('customer'), getMyQueue);
router.patch('/:id/cancel',              requireRole('customer'), cancelQueue);

// Vendor routes
router.get('/vendor/:vendorId',           getVendorQueue);
router.patch('/vendor/:vendorId/serve-next', requireRole('vendor'), serveNext);

module.exports = router;
