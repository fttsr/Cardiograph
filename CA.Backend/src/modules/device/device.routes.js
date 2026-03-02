import express from "express";
import { pool } from "../../db/db.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { patient_id, doctor_id, consultation_date, comment } = req.body;

  const result = await pool.query(
    `INSERT INTO consultation
     (patient_id, doctor_id, consultation_date, comment)
     VALUES ($1,$2,$3,$4)
     RETURNING *`,
    [patient_id, doctor_id, consultation_date, comment],
  );

  res.status(201).json(result.rows[0]);
});

router.get("/", async (_, res) => {
  const result = await pool.query(`SELECT * FROM consultation`);
  res.json(result.rows);
});

router.get("/:id", async (req, res) => {
  const result = await pool.query(`SELECT * FROM consultation WHERE id=$1`, [
    req.params.id,
  ]);
  res.json(result.rows[0]);
});

router.put("/:id", async (req, res) => {
  const { consultation_date, comment } = req.body;

  const result = await pool.query(
    `UPDATE consultation
     SET consultation_date=$1, comment=$2
     WHERE id=$3
     RETURNING *`,
    [consultation_date, comment, req.params.id],
  );

  res.json(result.rows[0]);
});

router.delete("/:id", async (req, res) => {
  await pool.query(`DELETE FROM consultation WHERE id=$1`, [req.params.id]);
  res.json({ message: "Консультация удалена" });
});

export default router;
