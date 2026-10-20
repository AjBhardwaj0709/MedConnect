const Doctor = require("../models/Doctor")
const cloudinary = require("../config/cloudinary");
const { Readable } = require("stream");


const uploadToCloudinary = (buffer) => {
    return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
            {
                folder: "medconnect/doctor_profiles",
                resource_type: "image",
                transformation: [
                    { width: 800, height: 800, crop: "limit" },
                ],
            },
            (error, result) => {
                if (error) return reject(error);
                resolve(result);
            }
        );

        Readable.from(buffer).pipe(stream);
    });
};

// Upload or replace the logged-in doctor's profile image
const uploadDoctorProfileImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "Please select an image",
            });
        }

        const doctor = await Doctor.findOne({
            userId: req.user.userId,
        });

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Doctor profile not found",
            });
        }

        const result = await uploadToCloudinary(req.file.buffer);

        // Save the new image URL and Cloudinary public ID.
        const oldPublicId = doctor.profileImagePublicId;

        doctor.profileImage = result.secure_url;
        doctor.profileImagePublicId = result.public_id;

        await doctor.save();

        // Delete the previous image only after the new image is saved.
        if (oldPublicId) {
            try {
                await cloudinary.uploader.destroy(oldPublicId, {
                    resource_type: "image",
                });
            } catch (deleteError) {
                console.error("Could not delete previous image:", deleteError);
            }
        }

        const updatedDoctor = await Doctor.findById(doctor._id)
            .populate("userId", "email role");

        return res.status(200).json({
            success: true,
            message: "Profile image uploaded successfully",
            doctor: updatedDoctor,
        });
    } catch (error) {
        console.error("Profile image upload error:", error);

        return res.status(500).json({
            success: false,
            message: "Could not upload profile image",
        });
    }
};

// Delete the logged-in doctor's profile image
const deleteDoctorProfileImage = async (req, res) => {
    try {
        const doctor = await Doctor.findOne({
            userId: req.user.userId,
        });

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Doctor profile not found",
            });
        }

        if (!doctor.profileImage && !doctor.profileImagePublicId) {
            return res.status(400).json({
                success: false,
                message: "No profile image to delete",
            });
        }

        // Delete from Cloudinary first if a public ID exists.
        if (doctor.profileImagePublicId) {
            const result = await cloudinary.uploader.destroy(
                doctor.profileImagePublicId,
                { resource_type: "image" }
            );

            if (result.result !== "ok" && result.result !== "not found") {
                return res.status(502).json({
                    success: false,
                    message: "Could not delete image from Cloudinary",
                });
            }
        }

        doctor.profileImage = "";
        doctor.profileImagePublicId = "";

        await doctor.save();

        const updatedDoctor = await Doctor.findById(doctor._id)
            .populate("userId", "email role");

        return res.status(200).json({
            success: true,
            message: "Profile image deleted successfully",
            doctor: updatedDoctor,
        });
    } catch (error) {
        console.error("Profile image deletion error:", error);

        return res.status(500).json({
            success: false,
            message: "Could not delete profile image",
        });
    }
};


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
            registrationNumber,
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
        if (registrationNumber !== undefined) {
            doctor.registrationNumber = registrationNumber;
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

        const updatedDoctor = await Doctor.findById(doctor._id)
            .populate("userId", "email role");

        return res.status(200).json({
            success: true,
            message: "Doctor Profile updated successfully",
            doctor: updatedDoctor
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
            isVerified: true,
            verificationStatus: "approved",
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
            isVerified: true,
            verificationStatus: "approved",
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

module.exports = {
    getMyProfile,
    updateDoctorProfile,
    getAllDoctors,
    getDoctorById,
    uploadDoctorProfileImage,
    deleteDoctorProfileImage,
};