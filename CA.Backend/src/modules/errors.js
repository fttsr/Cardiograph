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
