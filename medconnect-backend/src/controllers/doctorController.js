const Doctor = require("../models/Doctor")

// get logged in doctor profile

const getMyProfile = async (req, res) => {
    try {
        const doctor = await Doctor.findOne({
            userId: req.user.userId

        }).populate("userId", "email role");

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Doctor profile not found "
            })
        }
        return res.status(200).json({
            success: true,
            doctor
        })
    }
    catch (error) {
        console.error("There is an error: ", error)

        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        });

    }

}

// update login doctor profile 

const updateDoctorProfile = async (req, res) => {
    try {
        const {
            name,
            specialization,
            qualification,
            experience,
            consultationFee,
            bio,
            languages,
            clinicName,
            clinicAddress,
            profileImage,
        } = req.body;

        const doctor = await Doctor.findOne({
            userId: req.user.userId,
        });
        if (!doctor) {
            return res.status(400).json({
                success: false,
                message: "Doctor Profile not found"
            });
        }
        if (name !== undefined) {
            doctor.name = name;
        }
        if (specialization !== undefined) {
            doctor.specialization = specialization;
        }
        if (qualification !== undefined) {
            doctor.qualification = qualification;
        }
        if (experience !== undefined) {
            doctor.experience = experience;
        }
        if (consultationFee !== undefined) {
            doctor.consultationFee = consultationFee;
        }
        if (bio !== undefined) {
            doctor.bio = bio;
        }
        if (languages !== undefined) {
            doctor.languages = languages;
        }
        if (clinicName !== undefined) {
            doctor.clinicName = clinicName;
        }
        if (clinicAddress !== undefined) {
            doctor.clinicAddress = clinicAddress;
        }
        if (profileImage !== undefined) {
            doctor.profileImage = profileImage;
        }
        await doctor.save();
        return res.status(200).json({
            success: true,
            message: "Doctor Profile update successfully ",
            doctor
        });

    }
    catch (error) {
        console.error("There is an error in Doctor update profile: ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
}

// get all verified Doctor

const getAllDoctors = async (req, res) => {
    try {
        const doctors = await Doctor.find({
            isVerified: true
        }).select(
            "name specialization qualification experience consultationFee bio languages clinicName clinicAddress profileImage"
        ).sort({ createdAt: -1 });

        return res.status(200).json({
            success: true,
            count: doctors.length,
            doctors
        });
    }
    catch (error) {
        console.error("There is an error in Verified Doctor: ", error)
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        });

    }
};

// Get doctor byId

const getDoctorById = async (req, res) => {
    try {
        const { id } = req.params;
        const doctor = await Doctor.findById({
            _id: id,
            isVerified: true
        }).select("name specialization qualification experience consultationFee bio languages clinicName clinicAddress profileImage");
        if(!doctor){
            return res.status(400).json({
                success: false,
                message: "Doctor not found"
            });
        }
        return res.status(200).json({
            success: true,
            doctor
        });

    }
    catch (error) {
        console.error("There is an error find doctor by Id: ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"

        })
    }

}

module.exports={
    getMyProfile,
    updateDoctorProfile,
    getAllDoctors,
    getDoctorById,
}