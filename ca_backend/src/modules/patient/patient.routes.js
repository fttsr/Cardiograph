import express from "express";
import * as controller from "./patient.controller.js";

const router = express.Router();

router.get("/profile", controller.getProfile);
router.post("/profile", controller.upsertProfile);
router.get("/by-user/:user_id", controller.getByUserId);

export default router;
