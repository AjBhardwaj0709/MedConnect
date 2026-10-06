const Doctor = require("../models/Doctor");
const Patient = require("../models/Patient");

// get Pending doctor list

const getPendingDoctor = async (req, res) => {
    try {
        const doctors = await Doctor.find({
            verificationStatus: "pending"
        }).populate("userId", "email role isActive")
            .sort({ createdAt: -1 });

        return res.status(200).json({
            success: true,
            message: "Doctor Pending list fetch Successfully",
            count: doctors.length,
            doctors
        })
    }
    catch (error) {
        console.error("There is an error in doctor pending list : ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
}

// get all doctors 

const getAllDoctorsForAdmin = async (req, res) => {
    try {
        const doctors = (await Doctor.find().populate("userId", "email role isActive ")).toSorted({ createdAt: -1 })
        return res.status(200).json({
            success: true,
            count: doctors.length,
            doctors
        })

    }
    catch (error) {
        console.error("There is an error in all doctor list : ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
}

// Approve Doctor

const approveDoctor = async (req, res) => {

    try {
        const { id } = req.params;
        const doctor = await Doctor.findById(id)

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Doctor not found "
            })
        }
        if (doctor.verificationStatus === "approved") {
            return res.status(400).json({
                success: false,
                message: "Doctor is already approved",
            });
        }
        doctor.isVerified = true;
        doctor.verificationStatus = "approved";
        doctor.rejectionReason = "";

        await doctor.save();
        return res.status(200).json({
            success: true,
            message: "Doctor approved successfully",
            doctors
        })

    }
    catch (error) {
        console.error("Approved doctor ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
}

// reject Doctors 
const rejectDoctor = async (req, res) => {
    try {
        const { id } = req.params;
        const { reason } = req.body;
        if (!reason || reason.trim().length == 0) {
            return res.status(400).json({
                success: false,
                message: "Rejection reason is required"
            });
        }

        const doctor = await Doctor.findById(id)
        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Doctor not found"
            });
        }
        doctor.isVerified = false;
        doctor.rejectionReason = reason.trim();
        doctor.verificationStatus = "rejected"
        await doctor.save();
        return res.status(200).json({
            success: true,
            message: "Doctor rejected successfully",
            doctor,
        })

    }
    catch (error) {
        console.error("Reject doctor ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
};

// activate / deactivate doctor status 
const updateDoctorAccountStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { isActive } = req.body;

        if (typeof isActive !== "boolean") {
            return res.status(400).json({
                success: false,
                message: "isActive must be true or false",
            });
        }
        const doctor = await Doctor.findById(id);

        if (!doctor) {
            return res.status(404).json({
                status: false,
                message: "Doctor not found"

            })
        }
        const user = await User.findById(doctor.userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: "Doctor user account not found",
            });
        }

        user.isActive = !isActive
        await user.save();
        return res.status(200).json({
            success: true,
            message: isActive
                ? "Doctor account activated"
                : "Doctor account deactivated",
        });

    }
    catch (error) {
        console.error("Doctor account status error : ", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong"
        })
    }
}

module.exports = {
    getPendingDoctor,
    getAllDoctorsForAdmin,
    approveDoctor,
    rejectDoctor,
    updateDoctorAccountStatus
}
