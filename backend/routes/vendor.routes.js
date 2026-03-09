const express = require('express');
const {
  getAllVendors,
  getVendorById,
  updateVendor,
} = require('../controllers/vendor.controller');
const { authenticate, requireRole } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/',     authenticate, getAllVendors);
router.get('/:id',  authenticate, getVendorById);
router.put('/me',   authenticate, requireRole('vendor'), updateVendor);

module.exports = router;
