import { pool } from "../../db/db.js";

export async function createConsultation({
  patient_id,
  doctor_id,
  consultation_date,
  comment,
}) {
  const result = await pool.query(
    `INSERT INTO consultation
     (patient_id, doctor_id, consultation_date, comment)
     VALUES ($1,$2,$3,$4)
     RETURNING *`,
    [patient_id, doctor_id, consultation_date, comment],
  );

  return result.rows[0];
}

export async function getAllConsultations() {
  const result = await pool.query(`SELECT * FROM consultation`);
  return result.rows;
}

export async function getConsultationById(id) {
  const result = await pool.query(`SELECT * FROM consultation WHERE id=$1`, [
    id,
  ]);
  return result.rows[0] ?? null;
}

export async function updateConsultation(id, { consultation_date, comment }) {
  const result = await pool.query(
    `UPDATE consultation
     SET consultation_date=$1, comment=$2
     WHERE id=$3
     RETURNING *`,
    [consultation_date, comment, id],
  );

  return result.rows[0] ?? null;
}

export async function deleteConsultation(id) {
  await pool.query(`DELETE FROM consultation WHERE id=$1`, [id]);
}
