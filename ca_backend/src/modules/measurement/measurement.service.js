import * as repo from "./measurement.repository.js";
import { NotFoundError, ValidationError } from "../errors.js";

export async function create({ patient_id }) {
  if (!patient_id) {
    throw new ValidationError("patient_id обязателен");
  }

  const exists = await repo.patientExists(patient_id);
  if (!exists) {
    throw new NotFoundError("Пациент не найден.");
  }

  const measurement = await repo.createMeasurement(patient_id);

  return {
    message: "Измерение ЭКГ создано.",
    measurement,
  };
}

export async function saveHeartRate(measurementId, { data }) {
  if (!Array.isArray(data) || data.length === 0) {
    throw new ValidationError("Предоставлен пустой массив.");
  }

  const exists = await repo.measurementExists(measurementId);
  if (!exists) {
    throw new NotFoundError("Измерение ЭКГ не найдено.");
  }

  await repo.insertHeartRateBatch(measurementId, data);

  return {
    message: "Данные ЭКГ успешно сохранены.",
    count: data.length,
  };
}

export async function findByDate(date) {
  if (!date) {
    throw new ValidationError("date обязателен");
  }

  return repo.getMeasurementsByDate(date);
}
