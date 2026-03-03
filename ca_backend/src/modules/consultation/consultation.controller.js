import * as service from "./consultation.service.js";
import { AppError } from "../errors.js";

export async function create(req, res) {
  try {
    const created = await service.create(req.body);
    return res.status(201).json(created);
  } catch (err) {
    return handleError(err, res, "Ошибка создания консультации");
  }
}

export async function list(_req, res) {
  try {
    const items = await service.list();
    return res.json(items);
  } catch (err) {
    return handleError(err, res, "Ошибка получения консультаций");
  }
}

export async function getById(req, res) {
  try {
    const item = await service.getById(req.params.id);
    return res.json(item);
  } catch (err) {
    return handleError(err, res, "Ошибка получения консультации");
  }
}

export async function update(req, res) {
  try {
    const updated = await service.update(req.params.id, req.body);
    return res.json(updated);
  } catch (err) {
    return handleError(err, res, "Ошибка обновления консультации");
  }
}

export async function remove(req, res) {
  try {
    const result = await service.remove(req.params.id);
    return res.json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка удаления консультации");
  }
}

function handleError(err, res, logPrefix) {
  console.error(`${logPrefix}:`, err);

  if (err instanceof AppError) {
    return res.status(err.status).json({ error: err.message });
  }

  return res.status(500).json({ error: "Ошибка сервера." });
}
