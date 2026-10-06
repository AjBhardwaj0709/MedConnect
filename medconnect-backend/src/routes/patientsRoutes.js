const express =require("express");

const{
    getPatientProfile,
    updateMyProfile,
}= require("../controllers/patientController");

const{
    protect,
    authorize,
}= require("../middleware/authMiddleware");

const router= express.Router();


// patient profile

router.get(
    "/profile",
    protect,
    authorize("patient"),
    getPatientProfile
)

// patient update profile
router.put(
    "/profile",
    protect,
    authorize("patient"),
    updateMyProfile
);

module.exports=router;