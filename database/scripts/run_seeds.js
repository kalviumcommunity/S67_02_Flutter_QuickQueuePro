require('dotenv').config({ path: __dirname + '/../config/.env' });
const mysql = require('mysql2/promise');
const fs    = require('fs');
const path  = require('path');

async function runSeeds() {
  const connection = await mysql.createConnection({
    host:     process.env.DB_HOST     || 'localhost',
    port:     Number(process.env.DB_PORT) || 3306,
    user:     process.env.DB_USER     || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME     || 'quick_queue_pro',
    multipleStatements: true,
  });

  const seedsDir = path.join(__dirname, '../seeds');
  const files = fs.readdirSync(seedsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(seedsDir, file), 'utf8');
    console.log(`Seeding: ${file}`);
    await connection.query(sql);
  }

  console.log('Seeds applied successfully.');
  await connection.end();
}

runSeeds().catch((err) => {
  console.error('Seeding failed:', err.message);
  process.exit(1);
});
