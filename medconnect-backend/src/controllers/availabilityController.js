const Doctor = require("../models/Doctor")
const DoctorAvailability= require("../models/DoctorAvailability");

//helper

const getApprovedDoctor= async (userId)=>{
return await Doctor.findOne({
    userId,
    isVerified: true,
    verificationStatus: "approved",
})
};

// create Availability 

const createAvailability = async (req, res)=>{
    try{
        const {
            dayOfWeek,
            startTime,
            endTime,
            isAvailable,
        } = req.body;

        // Required fields
        if (!dayOfWeek || !startTime || !endTime) {
            return res.status(400).json({
                success: false,
                message:
                    "dayOfWeek, startTime and endTime are required",
            });
        }
        // Find logged-in doctor
        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can manage availability",
            });
        }
        // Convert time into minutes for comparison
        const [startHour, startMinute] = startTime
            .split(":")
            .map(Number);

        const [endHour, endMinute] = endTime
            .split(":")
            .map(Number);

        const startTotalMinutes =
            startHour * 60 + startMinute;

        const endTotalMinutes =
            endHour * 60 + endMinute;

        if (startTotalMinutes >= endTotalMinutes) {
            return res.status(400).json({
                success: false,
                message: "End time must be after start time",
            });
        }

        // Check overlapping availability
        const existingAvailability =
            await DoctorAvailability.findOne({
                doctorId: doctor._id,
                dayOfWeek,
                $or: [
                    {
                        startTime: { $lt: endTime },
                        endTime: { $gt: startTime },
                    },
                ],
            });

        if (existingAvailability) {
            return res.status(409).json({
                success: false,
                message:
                    "This availability overlaps with an existing time period",
            });
        }
        const availability =
            await DoctorAvailability.create({
                doctorId: doctor._id,
                dayOfWeek,
                startTime,
                endTime,
                isAvailable:
                    isAvailable !== undefined
                        ? isAvailable
                        : true,
            });

        return res.status(201).json({
            success: true,
            message:
                "Doctor availability created successfully",
            availability,
        });


    }catch (error ){
        console.error(" there is an error in create availablity : ", error )
        return res.status(500).json({
            success: false,
            message:"Something went wrong"
        })
    }
}

// get Availability of the doctor 

const getMyAvailability = async (req, res) => {
    try {
        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can access availability",
            });
        }

        const availability =
            await DoctorAvailability.find({
                doctorId: doctor._id,
            }).sort({
                dayOfWeek: 1,
                startTime: 1,
            });

        return res.status(200).json({
            success: true,
            count: availability.length,
            availability,
        });
    } catch (error) {
        console.error(
            "Get availability error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// update Availability of the doctor 


const updateAvailability = async (req, res) => {
    try {
        const { id } = req.params;

        const {
            dayOfWeek,
            startTime,
            endTime,
            isAvailable,
        } = req.body;

        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can manage availability",
            });
        }

        const availability =
            await DoctorAvailability.findOne({
                _id: id,
                doctorId: doctor._id,
            });

        if (!availability) {
            return res.status(404).json({
                success: false,
                message: "Availability not found",
            });
        }

        const newDay =
            dayOfWeek !== undefined
                ? dayOfWeek
                : availability.dayOfWeek;

        const newStart =
            startTime !== undefined
                ? startTime
                : availability.startTime;

        const newEnd =
            endTime !== undefined
                ? endTime
                : availability.endTime;

        // Validate time
        const [startHour, startMinute] =
            newStart.split(":").map(Number);

        const [endHour, endMinute] =
            newEnd.split(":").map(Number);

        const startTotalMinutes =
            startHour * 60 + startMinute;

        const endTotalMinutes =
            endHour * 60 + endMinute;

        if (startTotalMinutes >= endTotalMinutes) {
            return res.status(400).json({
                success: false,
                message: "End time must be after start time",
            });
        }

        // Check overlapping availability
        const overlappingAvailability =
            await DoctorAvailability.findOne({
                _id: { $ne: id },
                doctorId: doctor._id,
                dayOfWeek: newDay,
                startTime: { $lt: newEnd },
                endTime: { $gt: newStart },
            });

        if (overlappingAvailability) {
            return res.status(409).json({
                success: false,
                message:
                    "This availability overlaps with another time period",
            });
        }

        availability.dayOfWeek = newDay;
        availability.startTime = newStart;
        availability.endTime = newEnd;

        if (isAvailable !== undefined) {
            availability.isAvailable = isAvailable;
        }

        await availability.save();

        return res.status(200).json({
            success: true,
            message:
                "Doctor availability updated successfully",
            availability,
        });
    } catch (error) {
        console.error(
            "Update availability error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// delete Availability 


const deleteAvailability = async (req, res) => {
    try {
        const { id } = req.params;

        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can manage availability",
            });
        }

        const availability =
            await DoctorAvailability.findOneAndDelete({
                _id: id,
                doctorId: doctor._id,
            });

        if (!availability) {
            return res.status(404).json({
                success: false,
                message: "Availability not found",
            });
        }

        return res.status(200).json({
            success: true,
            message:
                "Doctor availability deleted successfully",
        });
    } catch (error) {
        console.error(
            "Delete availability error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


module.exports = {
    createAvailability,
    getMyAvailability,
    updateAvailability,
    deleteAvailability,
};