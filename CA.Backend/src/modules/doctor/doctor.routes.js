import express from "express";
import { pool } from "../../db/db.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const {
    specialization_id,
    last_name,
    first_name,
    middle_name,
    phone,
    email,
    user_id,
  } = req.body;

  const result = await pool.query(
    `INSERT INTO doctor
     (specialization_id, last_name, first_name, middle_name, phone, email, user_id)
     VALUES ($1,$2,$3,$4,$5,$6,$7)
     RETURNING *`,
    [
      specialization_id,
      last_name,
      first_name,
      middle_name,
      phone,
      email,
      user_id,
    ],
  );

  res.status(201).json(result.rows[0]);
});

router.get("/", async (_, res) => {
  const result = await pool.query(`SELECT * FROM doctor`);
  res.json(result.rows);
});

router.get("/:id", async (req, res) => {
  const result = await pool.query(`SELECT * FROM doctor WHERE id=$1`, [
    req.params.id,
  ]);
  res.json(result.rows[0]);
});

router.put("/:id", async (req, res) => {
  const {
    specialization_id,
    last_name,
    first_name,
    middle_name,
    phone,
    email,
  } = req.body;

  const result = await pool.query(
    `UPDATE doctor
     SET specialization_id=$1, last_name=$2, first_name=$3,
         middle_name=$4, phone=$5, email=$6
     WHERE id=$7
     RETURNING *`,
    [
      specialization_id,
      last_name,
      first_name,
      middle_name,
      phone,
      email,
      req.params.id,
    ],
  );

  res.json(result.rows[0]);
});

router.delete("/:id", async (req, res) => {
  await pool.query(`DELETE FROM doctor WHERE id=$1`, [req.params.id]);
  res.json({ message: "Врач удалён" });
});

export default router;
