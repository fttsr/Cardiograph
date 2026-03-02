import express from "express";
import { pool } from "../../db/db.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { name, phone, email } = req.body;

  const result = await pool.query(
    `INSERT INTO manufacturer (name, phone, email)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [name, phone, email],
  );

  res.status(201).json(result.rows[0]);
});

router.get("/", async (_, res) => {
  const result = await pool.query(`SELECT * FROM manufacturer`);
  res.json(result.rows);
});

router.get("/:id", async (req, res) => {
  const result = await pool.query(`SELECT * FROM manufacturer WHERE id = $1`, [
    req.params.id,
  ]);
  res.json(result.rows[0]);
});

router.put("/:id", async (req, res) => {
  const { name, phone, email } = req.body;

  const result = await pool.query(
    `UPDATE manufacturer
     SET name=$1, phone=$2, email=$3
     WHERE id=$4
     RETURNING *`,
    [name, phone, email, req.params.id],
  );

  res.json(result.rows[0]);
});

router.delete("/:id", async (req, res) => {
  await pool.query(`DELETE FROM manufacturer WHERE id=$1`, [req.params.id]);
  res.json({ message: "Производитель удалён" });
});

export default router;
