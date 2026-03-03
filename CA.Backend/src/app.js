import express from "express";

import consultationRoutes from "./modules/consultation/consultation.routes.js";
import deviceRoutes from "./modules/device/device.routes.js";
import diagnosisRoutes from "./modules/diagnosis/diagnosis.routes.js";
import doctorRoutes from "./modules/doctor/doctor.routes.js";
import manufacturerRoutes from "./modules/manufacturer/manufacturer.routes.js";
import specializationRoutes from "./modules/specialization/specialization.routes.js";
import authRoutes from "./modules/auth/auth.routes.js";

const app = express();
app.use(express.json());

app.use("/manufacturer", manufacturerRoutes);
app.use("/device", deviceRoutes);
app.use("/specialization", specializationRoutes);
app.use("/doctor", doctorRoutes);
app.use("/consultation", consultationRoutes);
app.use("/diagnosis", diagnosisRoutes);
app.use("/auth", authRoutes);

export default app;
