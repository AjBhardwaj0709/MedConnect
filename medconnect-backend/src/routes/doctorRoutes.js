const express= require("express");

const {
    getMyProfile,
    updateDoctorProfile,
    getAllDoctors,
    getDoctorById,
}= require("../controllers/doctorController");
const {
    protect,
    authorize,

}=require("../middleware/authMiddleware");

const router=express.Router();



//doctor own profile
router.get("/profile", protect,authorize("doctor"), getMyProfile);


router.put("/profile", protect, authorize("doctor"), updateDoctorProfile);



//doctor public list

router.get("/", getAllDoctors);

// single doctor by id
router.get("/:id",getDoctorById);


module.exports=router;