import * as service from "./report.service.js";
import { handleError } from "../errors.js";

export async function create(req, res) {
  try {
    const result = await service.create(req.body);
    return res.status(201).json(result);
  } catch (err) {
    return handleError(err, res, "Ошибка сохранения отчёта");
  }
}
