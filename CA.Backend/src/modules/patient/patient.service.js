import * as repo from "./patient.repository.js";
import { NotFoundError, ValidationError } from "../errors.js";

export async function getProfile(userId) {
  if (!userId) throw new ValidationError("user_id обязателен");

  const profile = await repo.getProfileByUserId(userId);
  return profile ?? {};
}

export async function upsertProfile(data) {
  const { user_id } = data;
  if (!user_id) throw new ValidationError("user_id обязателен");

  const existsId = await repo.patientRowExistsByUserId(user_id);

  if (!existsId) {
    const patient = await repo.createPatientProfile(data);
    return {
      message: "Профиль пациента успешно создан.",
      patient,
    };
  }

  const patient = await repo.updatePatientProfileByUserId(data);
  return {
    message: "Профиль пациента успешно обновлён.",
    patient,
  };
}

export async function search(search) {
  if (!search) throw new ValidationError("Параметр search обязателен");
  return repo.searchPatientsByName(search);
}

export async function getPatientIdByUserId(userId) {
  if (!userId) throw new ValidationError("user_id обязателен");

  const id = await repo.getPatientIdByUserId(userId);
  if (!id) throw new NotFoundError("Пациент не найден");

  return { id };
}
