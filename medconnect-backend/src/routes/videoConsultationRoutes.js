
const express = require("express");
const router = express.Router();

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const {
    createVideoSession,
    getVideoSession,
    startVideoSession,
    endVideoSession,
} = require("../controllers/videoConsultationController");

router.use(protect);
router.use(authorize("patient", "doctor"));

// Create or retrieve a session for a confirmed appointment.
router.post(
    "/appointment/:appointmentId",
    createVideoSession
);

// Get the session for an appointment.
router.get(
    "/appointment/:appointmentId",
    getVideoSession
);

// Start a session.
router.put(
    "/:sessionId/start",
    startVideoSession
);

// End a session.
router.put(
    "/:sessionId/end",
    endVideoSession
);

module.exports = router;
