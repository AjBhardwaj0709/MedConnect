
const express = require("express");

const {
    patientSignup,
    doctorSignup,
    login,
    getMe,
    verifyEmail,
    resendVerificationEmail,
    forgotPassword,
    resetPassword,
} = require("../controllers/authController");

const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/patient/signup", patientSignup);
router.post("/doctor/signup", doctorSignup);
router.post("/login", login);
router.get("/me", protect, getMe);

// Email verification
router.get("/verify-email", verifyEmail);
router.post("/resend-verification", resendVerificationEmail);

// Password recovery
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);

module.exports = router;
