const Patient = require("../models/Patient");

// get Patient profile

const getPatientProfile = async (req, res) => {
    try {
        const patient = await Patient.findOne({
            userId: req.user.userId,

        }).populate("userId", "email phone role");

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient not found"
            });
        }
        return res.status(200).json({
            success: true,
            patient
        })

    }
    catch (error) {
        console.error("There is an error in Patient profile: ", error)
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }

};

// update patient profile self
const updateMyProfile= async (req, res)=>{
    try{
        const{
            name,
            dateOfBirth,
            gender,
            address,
            bloodGroup,
            emergencyContact,
            profileImage,
        }=req.body;

        const patient= await Patient.findOne({
            userId: req.user.userId
        });
        if(!patient){
            return res.status(404).json({
                success: false,
                message: "Patient profile not found"
            });

        }
        // Update only fields provided

        if (name !== undefined) {
            patient.name = name;
        }

        if (dateOfBirth !== undefined) {
            patient.dateOfBirth = dateOfBirth;
        }

        if (gender !== undefined) {
            patient.gender = gender;
        }

        if (address !== undefined) {
            patient.address = address;
        }

        if (bloodGroup !== undefined) {
            patient.bloodGroup = bloodGroup;
        }

        if (emergencyContact !== undefined) {
            patient.emergencyContact = {
                ...patient.emergencyContact.toObject(),
                ...emergencyContact,
            };
        }

        if (profileImage !== undefined) {
            patient.profileImage = profileImage;
        }


        await patient.save();

        return res.status(200).json({
            success: true,
            message: "Patient profile updated successfully",
            patient
        })

    }
    catch(error){
        console.error("There is an error in Patient update profile: ", error)
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
};

module.exports={
    getPatientProfile,
    updateMyProfile,
}