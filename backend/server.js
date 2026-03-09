require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const helmet  = require('helmet');
const morgan  = require('morgan');

const authRoutes   = require('./routes/auth.routes');
const userRoutes   = require('./routes/user.routes');
const vendorRoutes = require('./routes/vendor.routes');
const queueRoutes  = require('./routes/queue.routes');
const { errorHandler } = require('./middleware/error.middleware');

const app  = express();
const PORT = process.env.PORT || 5000;

// ── Security & utilities ──────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());
app.use(morgan('dev'));

// ── Routes ────────────────────────────────────────────────────
app.use('/api/auth',    authRoutes);
app.use('/api/users',   userRoutes);
app.use('/api/vendors', vendorRoutes);
app.use('/api/queues',  queueRoutes);

// ── Health Check ──────────────────────────────────────────────
app.get('/api/health', (_, res) =>
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
);

// ── Global Error Handler ──────────────────────────────────────
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`QuickQueuePro API running on port ${PORT}`);
});

module.exports = app;
