# QuickQueuePro – Database

This directory contains all database-related files for the QuickQueuePro application.

## Structure

```
database/
├── schema.sql              # Full schema (single-file reference)
├── migrations/             # Ordered migration scripts
│   ├── 001_create_users_table.sql
│   ├── 002_create_vendors_table.sql
│   ├── 003_create_queues_table.sql
│   └── 004_create_notifications_table.sql
├── seeds/                  # Sample/dev data
│   ├── seed_users.sql
│   └── seed_vendors.sql
├── scripts/                # Node.js helper scripts
│   ├── run_migrations.js
│   └── run_seeds.js
├── config/
│   └── .env.example        # DB connection template
└── package.json
```

## Setup

```bash
cd database
cp config/.env.example config/.env   # fill in your DB credentials
npm install
npm run setup                         # runs migrate + seed
```

## ER Diagram (simplified)

```
users ──< vendors    (one vendor user → one vendor profile)
users ──< queues     (one customer → many queue tokens)
vendors ──< queues   (one vendor → many queue tokens)
queues ──< notifications
```

## Tables

| Table          | Purpose                               |
|----------------|---------------------------------------|
| users          | All app users (customers & vendors)   |
| vendors        | Vendor business profiles              |
| queues         | Queue tokens issued to customers      |
| notifications  | In-app notifications                  |
