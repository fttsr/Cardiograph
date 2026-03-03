import * as service from "./auth.service.js";
import { AppError } from "../errors.js";

export async function register(req, res) {
  try {
    const result = await service.register(req.body);
    return res.status(201).json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка регистрации");
  }
}

export async function login(req, res) {
  try {
    const result = await service.login(req.body);
    return res.json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка авторизации");
  }
}

function handleError(err, res, logPrefix) {
  console.error(`${logPrefix}:`, err);

  if (err instanceof AppError) {
    return res.status(err.status).json({ error: err.message });
  }

  return res.status(500).json({ error: "Ошибка сервера." });
}

export async function forgotPassword(req, res) {
  const { email } = req.body;

  try {
    const result = await service.forgotPassword(email);
    return res.json(result);
  } catch (err) {
    console.error("Ошибка восстановления пароля:", err);

    const status = err.status || 500;
    const message = status === 500 ? "Ошибка отправки письма." : err.message;

    return res.status(status).json({ error: message });
  }
}

export async function resetPassword(req, res) {
  const { email, code, new_password } = req.body;

  try {
    const result = await service.resetPassword(email, code, new_password);
    return res.json(result);
  } catch (err) {
    console.error("Ошибка смены пароля:", err);

    const status = err.status || 500;
    const message = status === 500 ? "Ошибка сервера." : err.message;

    return res.status(status).json({ error: message });
  }
}
