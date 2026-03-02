import express from "express";
import { pool } from "../../db/db.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { name, description } = req.body;

  const result = await pool.query(
    `INSERT INTO specialization (name, description)
     VALUES ($1, $2)
     RETURNING *`,
    [name, description],
  );

  res.status(201).json(result.rows[0]);
});

router.get("/", async (_, res) => {
  const result = await pool.query(`SELECT * FROM specialization`);
  res.json(result.rows);
});

router.get("/:id", async (req, res) => {
  const result = await pool.query(`SELECT * FROM specialization WHERE id=$1`, [
    req.params.id,
  ]);
  res.json(result.rows[0]);
});

router.put("/:id", async (req, res) => {
  const { name, description } = req.body;

  const result = await pool.query(
    `UPDATE specialization
     SET name=$1, description=$2
     WHERE id=$3
     RETURNING *`,
    [name, description, req.params.id],
  );

  res.json(result.rows[0]);
});

router.delete("/:id", async (req, res) => {
  await pool.query(`DELETE FROM specialization WHERE id=$1`, [req.params.id]);
  res.json({ message: "Специализация удалена" });
});

export default router;
