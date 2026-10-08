const Doctor = require("../models/Doctor");
const DoctorAvailability = require("../models/DoctorAvailability");
const DoctorLeave = require("../models/DoctorLeave");
const BlockedTimeSlot = require("../models/BlockedTimeSlot");

// Get approved doctor
const getApprovedDoctor = async (userId) => {
    return await Doctor.findOne({
        userId,
        isVerified: true,
        verificationStatus: "approved",
    });
};

// Normalize date to UTC day
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

// Get day name
const getDayOfWeek = (date) => {
    const days = [
        "sunday",
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
    ];

    return days[date.getUTCDay()];
};

// Convert HH:mm to minutes
const timeToMinutes = (time) => {
    const [hours, minutes] = time.split(":").map(Number);

    return hours * 60 + minutes;
};

// Convert minutes to HH:mm
const minutesToTime = (minutes) => {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;

    return `${String(hours).padStart(2, "0")}:${String(mins).padStart(
        2,
        "0"
    )}`;
};

// Generate available slots
const getAvailableSlots = async (req, res) => {
    try {
        const { doctorId, date } = req.query;

        if (!doctorId || !date) {
            return res.status(400).json({
                success: false,
                message: "doctorId and date are required",
            });
        }

        const normalizedDate = normalizeDate(date);

        if (!normalizedDate) {
            return res.status(400).json({
                success: false,
                message: "Invalid date",
            });
        }

        // Find doctor
        const doctor = await Doctor.findOne({
            _id: doctorId,
            isVerified: true,
            verificationStatus: "approved",
        });

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Approved doctor not found",
            });
        }

        // Find day
        const dayOfWeek = getDayOfWeek(normalizedDate);

        // Find availability
        const availability = await DoctorAvailability.find({
            doctorId: doctor._id,
            dayOfWeek,
            isAvailable: true,
        }).sort({
            startTime: 1,
        });

        if (availability.length === 0) {
            return res.status(200).json({
                success: true,
                date: normalizedDate,
                doctorId: doctor._id,
                slots: [],
                message: "Doctor is not available on this day",
            });
        }

        // Check doctor leave
        const leave = await DoctorLeave.findOne({
            doctorId: doctor._id,
            startDate: { $lte: normalizedDate },
            endDate: { $gte: normalizedDate },
        });

        if (leave) {
            return res.status(200).json({
                success: true,
                date: normalizedDate,
                doctorId: doctor._id,
                slots: [],
                message: "Doctor is on leave on this date",
            });
        }

        // Get blocked slots
        const blockedSlots = await BlockedTimeSlot.find({
            doctorId: doctor._id,
            date: normalizedDate,
        });

        const slots = [];

        // Generate 30-minute slots
        for (const period of availability) {
            const startMinutes = timeToMinutes(period.startTime);
            const endMinutes = timeToMinutes(period.endTime);

            for (
                let current = startMinutes;
                current + 30 <= endMinutes;
                current += 30
            ) {
                const slotStart = current;
                const slotEnd = current + 30;

                // Check if slot overlaps blocked time
                const isBlocked = blockedSlots.some((blocked) => {
                    const blockedStart = timeToMinutes(blocked.startTime);
                    const blockedEnd = timeToMinutes(blocked.endTime);

                    return (
                        slotStart < blockedEnd &&
                        slotEnd > blockedStart
                    );
                });

                if (!isBlocked) {
                    slots.push({
                        startTime: minutesToTime(slotStart),
                        endTime: minutesToTime(slotEnd),
                    });
                }
            }
        }

        return res.status(200).json({
            success: true,
            date: normalizedDate,
            doctorId: doctor._id,
            slotDuration: 30,
            slots,
        });
    } catch (error) {
        console.error("Get available slots error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    getAvailableSlots,
};