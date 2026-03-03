import { pool } from "../../db/db.js";

export async function getProfileByUserId(userId) {
  const result = await pool.query(
    `SELECT first_name, last_name, middle_name, phone, email
     FROM patient
     WHERE user_id = $1`,
    [userId],
  );

  return result.rows[0] ?? null;
}

export async function patientRowExistsByUserId(userId) {
  const result = await pool.query("SELECT id FROM patient WHERE user_id = $1", [
    userId,
  ]);
  return result.rows[0]?.id ?? null;
}

export async function createPatientProfile(data) {
  const {
    user_id,
    last_name,
    first_name,
    middle_name,
    date_of_birth,
    phone,
    email,
  } = data;

  const result = await pool.query(
    `INSERT INTO patient
      (user_id, last_name, first_name, middle_name, date_of_birth, phone, email)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING *`,
    [user_id, last_name, first_name, middle_name, date_of_birth, phone, email],
  );

  return result.rows[0];
}

export async function updatePatientProfileByUserId(data) {
  const {
    user_id,
    last_name,
    first_name,
    middle_name,
    date_of_birth,
    phone,
    email,
  } = data;

  const result = await pool.query(
    `UPDATE patient
     SET
       last_name = COALESCE($2, last_name),
       first_name = COALESCE($3, first_name),
       middle_name = COALESCE($4, middle_name),
       date_of_birth = COALESCE($5, date_of_birth),
       phone = COALESCE($6, phone),
       email = COALESCE($7, email)
     WHERE user_id = $1
     RETURNING *`,
    [user_id, last_name, first_name, middle_name, date_of_birth, phone, email],
  );

  return result.rows[0] ?? null;
}

export async function searchPatientsByName(search) {
  const pattern = `%${search}%`;

  const result = await pool.query(
    `
    SELECT
      p.id,
      p.last_name,
      p.first_name,
      p.middle_name,
      p.date_of_birth,
      p.phone,
      p.email
    FROM patient p
    WHERE
      p.last_name ILIKE $1
      OR p.first_name ILIKE $1
      OR p.middle_name ILIKE $1
    ORDER BY p.last_name
    `,
    [pattern],
  );

  return result.rows;
}

export async function getPatientIdByUserId(userId) {
  const result = await pool.query(`SELECT id FROM patient WHERE user_id = $1`, [
    userId,
  ]);
  return result.rows[0]?.id ?? null;
}
