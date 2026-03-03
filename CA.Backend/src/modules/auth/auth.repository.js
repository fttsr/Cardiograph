import { pool } from "../../db/db.js";

export async function findUserIdByLogin(login) {
  const result = await pool.query("SELECT id FROM app_user WHERE login = $1", [
    login,
  ]);
  return result.rows[0]?.id ?? null;
}

export async function findUserByLogin(login) {
  const result = await pool.query(
    `SELECT id, login, password, role
     FROM app_user
     WHERE login = $1`,
    [login],
  );
  return result.rows[0] ?? null;
}

export async function createUserPatient(login, password) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const userRes = await client.query(
      `INSERT INTO app_user (login, password, role)
       VALUES ($1, $2, 'patient')
       RETURNING id, login, role`,
      [login, password],
    );

    const user = userRes.rows[0];

    await client.query(`INSERT INTO patient (user_id) VALUES ($1)`, [user.id]);

    await client.query("COMMIT");
    return user;
  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release();
  }
}

export async function findUserIdByEmail(email) {
  const result = await pool.query(
    `
      SELECT u.id as user_id
      FROM patient p
      JOIN app_user u ON u.id = p.user_id
      WHERE p.email = $1
    `,
    [email],
  );

  return result.rows[0]?.user_id ?? null;
}

export async function updateUserPassword(userId, newPassword) {
  await pool.query(`UPDATE app_user SET password = $1 WHERE id = $2`, [
    newPassword,
    userId,
  ]);
}
