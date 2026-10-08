const express = require("express");

const {
    createAppointment,
    getMyAppointments,
    getDoctorAppointments,
} = require("../controllers/appointmentController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();


// ==========================================
// PATIENT ROUTES
// ==========================================

// Patient books appointment
router.post(
    "/",
    protect,
    authorize("patient"),
    createAppointment
);

// Patient gets own appointments
router.get(
    "/my",
    protect,
    authorize("patient"),
    getMyAppointments
);


// ==========================================
// DOCTOR ROUTES
// ==========================================

// Doctor gets appointments
router.get(
    "/doctor",
    protect,
    authorize("doctor"),
    getDoctorAppointments
);


module.exports = router;