require('dotenv').config({ path: __dirname + '/../config/.env' });
const mysql = require('mysql2/promise');

async function runMigrations() {
  const fs   = require('fs');
  const path = require('path');

  const connection = await mysql.createConnection({
    host:     process.env.DB_HOST     || 'localhost',
    port:     Number(process.env.DB_PORT) || 3306,
    user:     process.env.DB_USER     || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true,
  });

  // Ensure database exists
  await connection.query(
    `CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME || 'quick_queue_pro'}
     CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
  );
  await connection.query(`USE ${process.env.DB_NAME || 'quick_queue_pro'}`);

  const migrationsDir = path.join(__dirname, '../migrations');
  const files = fs.readdirSync(migrationsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
    console.log(`Running migration: ${file}`);
    await connection.query(sql);
  }

  console.log('All migrations applied successfully.');
  await connection.end();
}

runMigrations().catch((err) => {
  console.error('Migration failed:', err.message);
  process.exit(1);
});
