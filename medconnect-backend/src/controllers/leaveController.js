const Doctor = require("../models/Doctor");
const DoctorLeave = require("../models/DoctorLeave");


// ==========================================
// HELPER
// ==========================================

const getApprovedDoctor = async (userId) => {
    return await Doctor.findOne({
        userId,
        isVerified: true,
        verificationStatus: "approved",
    });
};


// ==========================================
// DATE HELPER
// ==========================================

const normalizeDate = (date) => {
    const parsedDate = new Date(date);

    if (Number.isNaN(parsedDate.getTime())) {
        return null;
    }

    // Normalize to start of UTC day
    return new Date(
        Date.UTC(
            parsedDate.getUTCFullYear(),
            parsedDate.getUTCMonth(),
            parsedDate.getUTCDate()
        )
    );
};


// ==========================================
// CREATE DOCTOR LEAVE
// ==========================================

const createLeave = async (req, res) => {
    try {
        const {
            startDate,
            endDate,
            reason,
        } = req.body;


        // Required fields
        if (!startDate || !endDate) {
            return res.status(400).json({
                success: false,
                message: "startDate and endDate are required",
            });
        }


        // Find approved doctor
        const doctor = await getApprovedDoctor(
            req.user.userId
        );

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can manage leave",
            });
        }


        // Normalize dates
        const normalizedStartDate =
            normalizeDate(startDate);

        const normalizedEndDate =
            normalizeDate(endDate);


        if (
            !normalizedStartDate ||
            !normalizedEndDate
        ) {
            return res.status(400).json({
                success: false,
                message: "Invalid date format",
            });
        }


        // Start cannot be after end
        if (
            normalizedStartDate >
            normalizedEndDate
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Start date cannot be after end date",
            });
        }


        // Check overlapping leave
        const existingLeave =
            await DoctorLeave.findOne({
                doctorId: doctor._id,

                startDate: {
                    $lte: normalizedEndDate,
                },

                endDate: {
                    $gte: normalizedStartDate,
                },
            });


        if (existingLeave) {
            return res.status(409).json({
                success: false,
                message:
                    "This leave overlaps with an existing leave period",
            });
        }


        // Create leave
        const leave = await DoctorLeave.create({
            doctorId: doctor._id,
            startDate: normalizedStartDate,
            endDate: normalizedEndDate,
            reason: reason?.trim() || "",
        });


        return res.status(201).json({
            success: true,
            message:
                "Doctor leave created successfully",
            leave,
        });

    } catch (error) {

        console.error(
            "Create doctor leave error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// ==========================================
// GET MY LEAVES
// ==========================================

const getMyLeaves = async (req, res) => {
    try {

        const doctor = await getApprovedDoctor(
            req.user.userId
        );


        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can access leave",
            });
        }


        const leaves = await DoctorLeave.find({
            doctorId: doctor._id,
        }).sort({
            startDate: 1,
        });


        return res.status(200).json({
            success: true,
            count: leaves.length,
            leaves,
        });

    } catch (error) {

        console.error(
            "Get doctor leaves error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// ==========================================
// UPDATE LEAVE
// ==========================================

const updateLeave = async (req, res) => {
    try {

        const { id } = req.params;

        const {
            startDate,
            endDate,
            reason,
        } = req.body;


        const doctor = await getApprovedDoctor(
            req.user.userId
        );


        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can manage leave",
            });
        }


        // Find only this doctor's leave
        const leave = await DoctorLeave.findOne({
            _id: id,
            doctorId: doctor._id,
        });


        if (!leave) {
            return res.status(404).json({
                success: false,
                message: "Leave not found",
            });
        }


        // Use existing values if not provided
        const newStartDate = startDate
            ? normalizeDate(startDate)
            : leave.startDate;

        const newEndDate = endDate
            ? normalizeDate(endDate)
            : leave.endDate;


        if (
            !newStartDate ||
            !newEndDate
        ) {
            return res.status(400).json({
                success: false,
                message: "Invalid date format",
            });
        }


        if (newStartDate > newEndDate) {
            return res.status(400).json({
                success: false,
                message:
                    "Start date cannot be after end date",
            });
        }


        // Check overlap with another leave
        const overlappingLeave =
            await DoctorLeave.findOne({
                _id: {
                    $ne: id,
                },

                doctorId: doctor._id,

                startDate: {
                    $lte: newEndDate,
                },

                endDate: {
                    $gte: newStartDate,
                },
            });


        if (overlappingLeave) {
            return res.status(409).json({
                success: false,
                message:
                    "This leave overlaps with another leave period",
            });
        }


        leave.startDate = newStartDate;
        leave.endDate = newEndDate;


        if (reason !== undefined) {
            leave.reason = reason.trim();
        }


        await leave.save();


        return res.status(200).json({
            success: true,
            message:
                "Doctor leave updated successfully",
            leave,
        });

    } catch (error) {

        console.error(
            "Update doctor leave error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// ==========================================
// DELETE LEAVE
// ==========================================

const deleteLeave = async (req, res) => {
    try {

        const { id } = req.params;


        const doctor = await getApprovedDoctor(
            req.user.userId
        );


        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can manage leave",
            });
        }


        const leave =
            await DoctorLeave.findOneAndDelete({
                _id: id,
                doctorId: doctor._id,
            });


        if (!leave) {
            return res.status(404).json({
                success: false,
                message: "Leave not found",
            });
        }


        return res.status(200).json({
            success: true,
            message:
                "Doctor leave deleted successfully",
        });

    } catch (error) {

        console.error(
            "Delete doctor leave error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


module.exports = {
    createLeave,
    getMyLeaves,
    updateLeave,
    deleteLeave,
};