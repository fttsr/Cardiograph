import dotenv from "dotenv";
dotenv.config();

import pkg from "pg";
const { Pool } = pkg;

export const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 5432,
});

pool
  .query(
    `
  SELECT
    current_database() as db,
    current_schema() as schema,
    current_user as usr,
    inet_server_addr() as host,
    inet_server_port() as port
`,
  )
  .then((r) => console.log("DB INFO:", r.rows[0]));
