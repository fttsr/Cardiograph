import express from "express";
import * as controller from "./consultation.controller.js";

const router = express.Router();

router.post("/", controller.create);
router.get("/", controller.list);
router.get("/:id", controller.getById);
router.put("/:id", controller.update);
router.delete("/:id", controller.remove);

export default router;
