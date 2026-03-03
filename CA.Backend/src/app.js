import express from "express";

import consultationRoutes from "./modules/consultation/consultation.routes.js";
import authRoutes from "./modules/auth/auth.routes.js";
import reportRoutes from "./modules/report/report.routes.js";
import measurementRoutes from "./modules/measurement/measurement.routes.js";

const app = express();
app.use(express.json());

app.use("/consultation", consultationRoutes);
app.use("/auth", authRoutes);
app.use("/reports", reportRoutes);
app.use("/measurement", measurementRoutes);

export default app;
