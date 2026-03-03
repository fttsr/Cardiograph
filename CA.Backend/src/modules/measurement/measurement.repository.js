import { pool } from "../../db/db.js";

export async function patientExists(patientId) {
  const result = await pool.query("SELECT id FROM patient WHERE id = $1", [
    patientId,
  ]);
  return result.rows.length > 0;
}

export async function measurementExists(measurementId) {
  const result = await pool.query("SELECT id FROM measurement WHERE id = $1", [
    measurementId,
  ]);
  return result.rows.length > 0;
}

export async function createMeasurement(patientId) {
  const result = await pool.query(
    `INSERT INTO measurement (patient_id)
     VALUES ($1)
     RETURNING id, patient_id`,
    [patientId],
  );

  return result.rows[0];
}

export async function insertHeartRateBatch(measurementId, data) {
  const values = [];
  const placeholders = [];

  data.forEach((item, index) => {
    const baseIndex = index * 3;

    placeholders.push(
      `($${baseIndex + 1}, $${baseIndex + 2}, $${baseIndex + 3})`,
    );

    values.push(measurementId, item.second, item.bpm);
  });

  const query = `
    INSERT INTO heart_rate (measurement_id, second, bpm)
    VALUES ${placeholders.join(", ")}
  `;

  await pool.query(query, values);
}

export async function getMeasurementsByDate(date) {
  const result = await pool.query(
    `
    SELECT
      m.patient_id,
      r.created_at,
      hr.second,
      hr.bpm
    FROM measurement m
    JOIN report r ON r.measurement_id = m.id
    LEFT JOIN heart_rate hr ON hr.measurement_id = m.id
    WHERE DATE(r.created_at) = $1
    ORDER BY r.created_at, hr.second
    `,
    [date],
  );

  return result.rows;
}