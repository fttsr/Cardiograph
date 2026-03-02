import express from "express";
import { pool } from "../../db/db.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { measurement_id, patient_id, description } = req.body;

  const result = await pool.query(
    `INSERT INTO diagnosis
     (measurement_id, patient_id, date_set, description)
     VALUES ($1,$2,NOW(),$3)
     RETURNING *`,
    [measurement_id, patient_id, description],
  );

  res.status(201).json(result.rows[0]);
});

router.get("/", async (_, res) => {
  const result = await pool.query(`SELECT * FROM diagnosis`);
  res.json(result.rows);
});

router.get("/:id", async (req, res) => {
  const result = await pool.query(`SELECT * FROM diagnosis WHERE id=$1`, [
    req.params.id,
  ]);
  res.json(result.rows[0]);
});

router.put("/:id", async (req, res) => {
  const { description } = req.body;

  const result = await pool.query(
    `UPDATE diagnosis
     SET description=$1
     WHERE id=$2
     RETURNING *`,
    [description, req.params.id],
  );

  res.json(result.rows[0]);
});

router.delete("/:id", async (req, res) => {
  await pool.query(`DELETE FROM diagnosis WHERE id=$1`, [req.params.id]);
  res.json({ message: "Диагноз удалён" });
});

export default router;
