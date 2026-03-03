import * as repo from "./consultation.repository.js";
import { NotFoundError, ValidationError } from "../errors.js";

export async function create(data) {
  const { patient_id, doctor_id, consultation_date, comment } = data;

  if (!patient_id || !doctor_id || !consultation_date) {
    throw new ValidationError(
      "patient_id, doctor_id и consultation_date обязательны",
    );
  }

  return repo.createConsultation({
    patient_id,
    doctor_id,
    consultation_date,
    comment: comment ?? null,
  });
}

export async function list() {
  return repo.getAllConsultations();
}

export async function getById(id) {
  if (!id) throw new ValidationError("id обязателен");

  const item = await repo.getConsultationById(id);
  if (!item) throw new NotFoundError("Консультация не найдена");

  return item;
}

export async function update(id, data) {
  if (!id) throw new ValidationError("id обязателен");

  const { consultation_date, comment } = data;

  const updated = await repo.updateConsultation(id, {
    consultation_date,
    comment,
  });

  if (!updated) throw new NotFoundError("Консультация не найдена");
  return updated;
}

export async function remove(id) {
  if (!id) throw new ValidationError("id обязателен");

  const exists = await repo.getConsultationById(id);
  if (!exists) throw new NotFoundError("Консультация не найдена");

  await repo.deleteConsultation(id);
  return { message: "Консультация удалена" };
}
