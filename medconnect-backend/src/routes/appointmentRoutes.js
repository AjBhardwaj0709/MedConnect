const express = require("express");

const {
    createAppointment,
    getMyAppointments,
    getDoctorAppointments,
    confirmAppointment,
    cancelAppointment,
    rescheduleAppointment,
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

// apointment reschedule
router.put(
    "/:id/reschedule",
    protect,
    authorize("patient"),
    rescheduleAppointment
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

// Doctor confirms appointment
router.put(
    "/:id/confirm",
    protect,
    authorize("doctor"),
    confirmAppointment
);

// Cancel appointment
router.put(
    "/:id/cancel",
    protect,
    authorize("patient", "doctor"),
    cancelAppointment
);
module.exports = router;