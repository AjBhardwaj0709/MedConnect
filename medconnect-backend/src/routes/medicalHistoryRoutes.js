const express = require("express");

const {
    createMedicalHistory,
    getMyMedicalHistory,
    getPatientMedicalHistory,
} = require("../controllers/medicalHistoryController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();

// ==========================================
// DOCTOR
// ==========================================

// Doctor writes medical history
router.post(
    "/",
    protect,
    authorize("doctor"),
    createMedicalHistory
);

// Doctor can view patient's history
router.get(
    "/patient/:patientId",
    protect,
    authorize("doctor"),
    getPatientMedicalHistory
);


// ==========================================
// PATIENT
// ==========================================

// Patient can ONLY VIEW history
router.get(
    "/my",
    protect,
    authorize("patient"),
    getMyMedicalHistory
);

module.exports = router;