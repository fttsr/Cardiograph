import express from "express";
import * as controller from "./patient.controller.js";

const router = express.Router();

router.get("/", controller.search);

export default router;
