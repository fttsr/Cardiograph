import * as service from "./patient.service.js";
import { handleError } from "../errors.js";

export async function getProfile(req, res) {
  try {
    const result = await service.getProfile(req.query.user_id);
    return res.json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка получения профиля пациента");
  }
}

export async function upsertProfile(req, res) {
  try {
    const result = await service.upsertProfile(req.body);

    const status = result.message.includes("создан") ? 201 : 200;
    return res.status(status).json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка профиля пациента");
  }
}

export async function search(req, res) {
  try {
    const rows = await service.search(req.query.search);
    return res.json(rows);
  } catch (err) {
    return handleError(err, res, "Ошибка поиска пациента по ФИО");
  }
}

export async function getByUserId(req, res) {
  try {
    const result = await service.getPatientIdByUserId(req.params.user_id);
    return res.json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка поиска patient_id по user_id");
  }
}
