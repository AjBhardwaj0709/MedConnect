const Doctor = require("../models/Doctor");
const BlockedTimeSlot = require("../models/BlockedTimeSlot");

// Get approved doctor
const getApprovedDoctor = async (userId) => {
    return await Doctor.findOne({
        userId,
        isVerified: true,
        verificationStatus: "approved",
    });
};

// Convert date to UTC day
const normalizeDate = (date) => {
    const newDate = new Date(date);

    if (isNaN(newDate.getTime())) {
        return null;
    }

    return new Date(
        Date.UTC(
            newDate.getUTCFullYear(),
            newDate.getUTCMonth(),
            newDate.getUTCDate()
        )
    );
};

// Create blocked time slot
const createBlockedTimeSlot = async (req, res) => {
    try {
        const { date, startTime, endTime, reason } = req.body;

        if (!date || !startTime || !endTime) {
            return res.status(400).json({
                success: false,
                message: "Date, startTime and endTime are required",
            });
        }

        if (startTime >= endTime) {
            return res.status(400).json({
                success: false,
                message: "startTime must be before endTime",
            });
        }

        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message: "Only approved doctors can create blocked time slots",
            });
        }

        const normalizedDate = normalizeDate(date);

        if (!normalizedDate) {
            return res.status(400).json({
                success: false,
                message: "Invalid date",
            });
        }

        // Check overlapping blocked slot
        const existingSlot = await BlockedTimeSlot.findOne({
            doctorId: doctor._id,
            date: normalizedDate,
            startTime: { $lt: endTime },
            endTime: { $gt: startTime },
        });

        if (existingSlot) {
            return res.status(409).json({
                success: false,
                message: "Blocked time slot overlaps with an existing slot",
            });
        }

        const blockedSlot = await BlockedTimeSlot.create({
            doctorId: doctor._id,
            date: normalizedDate,
            startTime,
            endTime,
            reason,
        });

        return res.status(201).json({
            success: true,
            message: "Blocked time slot created successfully",
            blockedSlot,
        });
    } catch (error) {
        console.error("Create blocked time slot error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// Get blocked time slots
const getBlockedTimeSlots = async (req, res) => {
    try {
        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message: "Only approved doctors can view blocked time slots",
            });
        }

        const filter = {
            doctorId: doctor._id,
        };

        // Optional date filter
        if (req.query.date) {
            const normalizedDate = normalizeDate(req.query.date);

            if (!normalizedDate) {
                return res.status(400).json({
                    success: false,
                    message: "Invalid date",
                });
            }

            filter.date = normalizedDate;
        }

        const blockedSlots = await BlockedTimeSlot.find(filter).sort({
            date: 1,
            startTime: 1,
        });

        return res.status(200).json({
            success: true,
            count: blockedSlots.length,
            blockedSlots,
        });
    } catch (error) {
        console.error("Get blocked time slots error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// Update blocked time slot
const updateBlockedTimeSlot = async (req, res) => {
    try {
        const { id } = req.params;
        const { date, startTime, endTime, reason } = req.body;

        if (!date || !startTime || !endTime) {
            return res.status(400).json({
                success: false,
                message: "Date, startTime and endTime are required",
            });
        }

        if (startTime >= endTime) {
            return res.status(400).json({
                success: false,
                message: "startTime must be before endTime",
            });
        }

        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message: "Only approved doctors can update blocked time slots",
            });
        }

        const blockedSlot = await BlockedTimeSlot.findOne({
            _id: id,
            doctorId: doctor._id,
        });

        if (!blockedSlot) {
            return res.status(404).json({
                success: false,
                message: "Blocked time slot not found",
            });
        }

        const normalizedDate = normalizeDate(date);

        if (!normalizedDate) {
            return res.status(400).json({
                success: false,
                message: "Invalid date",
            });
        }

        // Check overlap excluding current slot
        const existingSlot = await BlockedTimeSlot.findOne({
            _id: { $ne: id },
            doctorId: doctor._id,
            date: normalizedDate,
            startTime: { $lt: endTime },
            endTime: { $gt: startTime },
        });

        if (existingSlot) {
            return res.status(409).json({
                success: false,
                message: "Blocked time slot overlaps with an existing slot",
            });
        }

        blockedSlot.date = normalizedDate;
        blockedSlot.startTime = startTime;
        blockedSlot.endTime = endTime;
        blockedSlot.reason = reason;

        await blockedSlot.save();

        return res.status(200).json({
            success: true,
            message: "Blocked time slot updated successfully",
            blockedSlot,
        });
    } catch (error) {
        console.error("Update blocked time slot error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// Delete blocked time slot
const deleteBlockedTimeSlot = async (req, res) => {
    try {
        const { id } = req.params;

        const doctor = await getApprovedDoctor(req.user.userId);

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message: "Only approved doctors can delete blocked time slots",
            });
        }

        const blockedSlot = await BlockedTimeSlot.findOneAndDelete({
            _id: id,
            doctorId: doctor._id,
        });

        if (!blockedSlot) {
            return res.status(404).json({
                success: false,
                message: "Blocked time slot not found",
            });
        }

        return res.status(200).json({
            success: true,
            message: "Blocked time slot deleted successfully",
        });
    } catch (error) {
        console.error("Delete blocked time slot error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    createBlockedTimeSlot,
    getBlockedTimeSlots,
    updateBlockedTimeSlot,
    deleteBlockedTimeSlot,
};