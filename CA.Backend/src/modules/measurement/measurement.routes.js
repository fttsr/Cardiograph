import express from "express";
import * as controller from "./measurement.controller.js";

const router = express.Router();

router.post("/", controller.create);
router.post("/:id/heart-rate", controller.saveHeartRate);
router.get("/by-date", controller.getByDate);

export default router;
