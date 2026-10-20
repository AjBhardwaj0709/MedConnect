const express = require("express");

const {
    getMyProfile,
    updateDoctorProfile,
    getAllDoctors,
    getDoctorById,
    uploadDoctorProfileImage,
    deleteDoctorProfileImage,
} = require("../controllers/doctorController");

const { protect, authorize } = require("../middleware/authMiddleware");
const upload = require("../config/upload");

const router = express.Router();

// Existing routes
router.get(
    "/profile",
    protect,
    authorize("doctor"),
    getMyProfile
);

router.put(
    "/profile",
    protect,
    authorize("doctor"),
    updateDoctorProfile
);

// Profile image routes
router.post(
    "/profile/image",
    protect,
    authorize("doctor"),
    upload.single("image"),
    uploadDoctorProfileImage
);

router.delete(
    "/profile/image",
    protect,
    authorize("doctor"),
    deleteDoctorProfileImage
);

router.get("/", getAllDoctors);
router.get("/:id", getDoctorById);

module.exports = router;