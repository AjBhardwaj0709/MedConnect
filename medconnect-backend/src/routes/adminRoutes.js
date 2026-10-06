const express = require("express");

const {
    getPendingDoctor,
    getAllDoctorsForAdmin,
    approveDoctor,
    rejectDoctor,
    updateDoctorAccountStatus
} = require("../controllers/adminController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();


// ==========================================
// ALL ADMIN ROUTES
// ==========================================

router.use(
    protect,
    authorize("admin")
);


// ==========================================
// DOCTOR MANAGEMENT
// ==========================================

router.get(
    "/doctors/pending",
    getPendingDoctor
);


router.get(
    "/doctors",
    getAllDoctorsForAdmin
);


router.put(
    "/doctors/:id/approve",
    approveDoctor
);


router.put(
    "/doctors/:id/reject",
    rejectDoctor
);


router.put(
    "/doctors/:id/status",
    updateDoctorAccountStatus
);


module.exports = router;