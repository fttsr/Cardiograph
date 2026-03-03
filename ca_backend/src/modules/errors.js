export class AppError extends Error {
  constructor(msg, status = 500) {
    super(msg);
    this.status = status;
  }
}

export class ValidationError extends AppError {
  constructor(msg) {
    super(msg, 400);
  }
}

export class ConflictError extends AppError {
  constructor(msg) {
    super(msg, 409);
  }
}

export class UnauthorizedError extends AppError {
  constructor(msg) {
    super(msg, 401);
  }
}

export class NotFoundError extends AppError {
  constructor(msg) {
    super(msg, 404);
  }
}

export function handleError(err, res, logPrefix = "Error") {
  console.error(`${logPrefix}:`, err);

  if (err instanceof AppError) {
    return res.status(err.status).json({
      error: err.message,
    });
  }

  return res.status(500).json({
    error: "Ошибка сервера.",
  });
}
