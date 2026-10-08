const express = require("express");

const {
    createMedicalReport,
    getMyMedicalReports,
    getDoctorMedicalReports,
} = require("../controllers/medicalReportController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// DOCTOR
// ==========================================

router.post(
    "/",
    protect,
    authorize("doctor"),
    createMedicalReport
);

router.get(
    "/doctor",
    protect,
    authorize("doctor"),
    getDoctorMedicalReports
);


// ==========================================
// PATIENT
// ==========================================

router.get(
    "/my",
    protect,
    authorize("patient"),
    getMyMedicalReports
);

module.exports = router;