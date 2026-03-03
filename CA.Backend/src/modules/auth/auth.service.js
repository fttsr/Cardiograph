import {
  ConflictError,
  NotFoundError,
  UnauthorizedError,
  ValidationError,
} from "../errors.js";
import * as repo from "./auth.repository.js";
import { transporter } from "../../utils/mailer.js";

const passwordResetCodes = new Map();

export async function register({ login, password }) {
  if (!login || !password) {
    throw new ValidationError("Логин и пароль обязательны для заполнения.");
  }

  const existsId = await repo.findUserIdByLogin(login);
  if (existsId) {
    throw new ConflictError("Такой пользователь уже существует.");
  }

  const user = await repo.createUserPatient(login, password);
  return {
    message: "Пользователь успешно зарегистрирован.",
    user,
  };
}

export async function login({ login, password }) {
  if (!login || !password) {
    throw new ValidationError("Логин и пароль обязательны для заполнения");
  }

  const user = await repo.findUserByLogin(login);
  if (!user) {
    throw new UnauthorizedError("Неверный логин или пароль.");
  }

  if (user.password !== password) {
    throw new UnauthorizedError("Неверный логин или пароль.");
  }

  return {
    id: user.id,
    login: user.login,
    role: user.role,
  };
}

export async function forgotPassword(email) {
  if (!email) {
    throw new ValidationError("Email обязателен для заполнения.");
  }

  const userId = await repo.findUserIdByEmail(email);

  if (!userId) {
    throw new NotFoundError("Пользователь с таким email не найден.");
  }

  const code = Math.floor(100000 + Math.random() * 900000).toString();

  passwordResetCodes.set(email, {
    code,
    user_id: userId,
    createdAt: Date.now(),
  });

  await transporter.sendMail({
    from: `"Домашний Кардиограф" <${process.env.MAIL_USER}>`,
    to: email,
    subject: "Восстановление пароля",
    text: `Ваш код для восстановления пароля: ${code}`,
    html: `
      <h2>Восстановление пароля</h2>
      <p>Ваш код:</p>
      <h1>${code}</h1>
      <p>>Если вы не запрашивали восстановление - проигнорируйте это письмо.</p>
    `,
  });

  return { message: "Код для восстановления отправлен на электронную почту." };
}

export async function resetPassword(email, code, newPassword) {
  const record = passwordResetCodes.get(email);

  if (!record) {
    throw new NotFoundError("Код не найден.");
  }

  if (record.code !== code) {
    throw new ValidationError("Неверный код.");
  }

  await repo.updateUserPassword(record.user_id, newPassword);

  passwordResetCodes.delete(email);

  return { message: "Пароль успешно изменён." };
}
