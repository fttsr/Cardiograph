import * as service from "./measurement.service.js";
import { handleError } from "../errors.js";

export async function create(req, res) {
  try {
    const result = await service.create(req.body);
    return res.status(201).json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка создания измерения ЭКГ");
  }
}

export async function saveHeartRate(req, res) {
  try {
    const result = await service.saveHeartRate(req.params.id, req.body);
    return res.status(201).json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка данных ЭКГ");
  }
}

export async function getByDate(req, res) {
  try {
    const rows = await service.findByDate(req.query.date);
    return res.json(rows);
  } catch (err) {
    return handleError(err, res, "Ошибка поиска измерений по дате");
  }
}
