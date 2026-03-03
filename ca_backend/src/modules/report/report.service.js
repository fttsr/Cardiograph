import * as repo from "./report.repository.js";
import { NotFoundError, ValidationError } from "../errors.js";

export async function create({ measurement_id, file_path }) {
  if (!measurement_id) {
    throw new ValidationError("measurement_id обязателен");
  }

  const exists = await repo.measurementExists(measurement_id);
  if (!exists) {
    throw new NotFoundError("Измерение ЭКГ не найдено.");
  }

  const report = await repo.createReport(measurement_id, file_path);

  return {
    message: "Отчёт успешно создан.",
    report,
  };
}
