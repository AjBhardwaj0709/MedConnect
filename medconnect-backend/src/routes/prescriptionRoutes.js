const express = require("express");

const {
    createPrescription,
    getMyPrescriptions,
    getDoctorPrescriptions,
} = require("../controllers/prescriptionController");

const { protect, authorize } = require("../middleware/authMiddleware");

const router = express.Router();

router.post(
    "/",
    protect,
    authorize("doctor"),
    createPrescription
);

router.get(
    "/my",
    protect,
    authorize("patient"),
    getMyPrescriptions
);

router.get(
    "/doctor",
    protect,
    authorize("doctor"),
    getDoctorPrescriptions
);

module.exports = router;