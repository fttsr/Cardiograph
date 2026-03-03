import { pool } from "../../db/db.js";

export async function measurementExists(measurementId) {
  const result = await pool.query("SELECT id FROM measurement WHERE id = $1", [
    measurementId,
  ]);
  return result.rows.length > 0;
}

export async function createReport(measurementId, filePath) {
  const result = await pool.query(
    `INSERT INTO report (measurement_id, file_path)
     VALUES ($1, $2)
     RETURNING id, measurement_id, created_at, file_path`,
    [measurementId, filePath || null],
  );

  return result.rows[0];
}
