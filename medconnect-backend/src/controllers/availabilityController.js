
const Doctor = require("../models/Doctor");
const DoctorAvailability = require("../models/DoctorAvailability");

const ALLOWED_DURATIONS = [15, 20, 30, 45, 60];

// Find the approved doctor associated with the logged-in user.
const getApprovedDoctor = async (userId) => {
    return Doctor.findOne({
        userId,
        isVerified: true,
        verificationStatus: "approved",
    });
};

// Resolve the authenticated and approved doctor.
async function resolveApprovedDoctor(req, res) {
    // Your previous controller used req.user.userId.
    const userId = req.user?.userId;

    console.log("[Availability] Authenticated user:", {
        userId,
        role: req.user?.role,
    });

    if (!userId) {
        res.status(401).json({
            success: false,
            message: "Authenticated user ID was not found.",
        });
        return null;
    }

    const doctor = await getApprovedDoctor(userId);

    if (!doctor) {
        res.status(403).json({
            success: false,
            message: "Only approved doctors can manage availability.",
        });
        return null;
    }

    return doctor;
}

// Validate a date in YYYY-MM-DD format.
function normalizeDate(value) {
    if (
        typeof value !== "string" ||
        !/^\d{4}-\d{2}-\d{2}$/.test(value)
    ) {
        return null;
    }

    const date = new Date(`${value}T00:00:00.000Z`);

    // Reject invalid dates, such as 2026-02-31.
    if (
        Number.isNaN(date.getTime()) ||
        date.toISOString().slice(0, 10) !== value
    ) {
        return null;
    }

    return date;
}

// Validate a time in HH:mm format.
function validTime(value) {
    return (
        typeof value === "string" &&
        /^([01]\d|2[0-3]):[0-5]\d$/.test(value)
    );
}

// Convert HH:mm into minutes after midnight.
function toMinutes(time) {
    const [hours, minutes] = time.split(":").map(Number);
    return hours * 60 + minutes;
}

// Validate the working period and slot duration.
function validPeriod(startTime, endTime, slotDuration) {
    if (!validTime(startTime) || !validTime(endTime)) {
        return false;
    }

    const duration = Number(slotDuration);

    return (
        toMinutes(endTime) > toMinutes(startTime) &&
        ALLOWED_DURATIONS.includes(duration) &&
        toMinutes(endTime) - toMinutes(startTime) >= duration
    );
}

// GET /api/doctors/availability

async function getAvailability(req, res, next) {
    try {
        console.log("[Availability] GET request received");

        const doctor = await resolveApprovedDoctor(req, res);
        if (!doctor) return;

        // Today's date at midnight UTC.
        const today = new Date();
        today.setUTCHours(0, 0, 0, 0);

        // MongoDB returns only today's and future availability.
        const records = await DoctorAvailability.find({
            doctorId: doctor._id,
            date: { $gte: today },
        }).sort({
            date: 1,
            startTime: 1,
        });

        console.log(
            `[Availability] Returned ${records.length} upcoming records`
        );

        return res.status(200).json({
            success: true,
            data: records,
        });
    } catch (error) {
        console.error("[Availability] Get error:", error);
        next(error);
    }
}

// POST /api/doctors/availability
async function createAvailability(req, res, next) {
    try {
        console.log("[Availability] POST request received");

        const doctor = await resolveApprovedDoctor(req, res);
        if (!doctor) return;

        const {
            date: dateValue,
            startTime,
            endTime,
            slotDuration = 30,
        } = req.body;

        const date = normalizeDate(dateValue);

        if (!date) {
            return res.status(400).json({
                success: false,
                message: "A valid date in YYYY-MM-DD format is required.",
            });
        }

        const today = normalizeDate(
            new Date().toISOString().slice(0, 10)
        );

        if (date < today) {
            return res.status(400).json({
                success: false,
                message: "Availability cannot be created for a past date.",
            });
        }

        if (!validPeriod(startTime, endTime, slotDuration)) {
            return res.status(400).json({
                success: false,
                message: "Check the time range and appointment duration.",
            });
        }

        // Reject overlapping periods for the same doctor and date.
        const overlap = await DoctorAvailability.findOne({
            doctorId: doctor._id,
            date,
            startTime: { $lt: endTime },
            endTime: { $gt: startTime },
        });

        if (overlap) {
            return res.status(409).json({
                success: false,
                message: "This period overlaps an existing working period.",
            });
        }

        const record = await DoctorAvailability.create({
            doctorId: doctor._id,
            date,
            startTime,
            endTime,
            slotDuration: Number(slotDuration),
            isAvailable: true,
        });

        console.log(
            "[Availability] Created record:",
            record._id.toString()
        );

        return res.status(201).json({
            success: true,
            message: "Availability created successfully.",
            data: record,
        });
    } catch (error) {
        console.error("[Availability] Create error:", error);
        next(error);
    }
}

// PUT /api/doctors/availability/:id
async function updateAvailability(req, res, next) {
    try {
        console.log("[Availability] PUT request received");

        const doctor = await resolveApprovedDoctor(req, res);
        if (!doctor) return;

        const {
            date: dateValue,
            startTime,
            endTime,
            slotDuration,
            isAvailable,
        } = req.body;

        const record = await DoctorAvailability.findOne({
            _id: req.params.id,
            doctorId: doctor._id,
        });

        if (!record) {
            return res.status(404).json({
                success: false,
                message: "Availability record not found.",
            });
        }

        // Allow omitted fields to retain their existing values.
        const date = dateValue === undefined
            ? record.date
            : normalizeDate(dateValue);

        const newStartTime = startTime ?? record.startTime;
        const newEndTime = endTime ?? record.endTime;
        const newSlotDuration = slotDuration ?? record.slotDuration;

        if (
            !date ||
            !validPeriod(
                newStartTime,
                newEndTime,
                newSlotDuration
            )
        ) {
            return res.status(400).json({
                success: false,
                message: "Check the date, time range, and appointment duration.",
            });
        }

        if (
            date < normalizeDate(
                new Date().toISOString().slice(0, 10)
            )
        ) {
            return res.status(400).json({
                success: false,
                message: "Availability cannot be updated to a past date.",
            });
        }

        const overlap = await DoctorAvailability.findOne({
            _id: { $ne: record._id },
            doctorId: doctor._id,
            date,
            startTime: { $lt: newEndTime },
            endTime: { $gt: newStartTime },
        });

        if (overlap) {
            return res.status(409).json({
                success: false,
                message: "This period overlaps an existing working period.",
            });
        }

        record.date = date;
        record.startTime = newStartTime;
        record.endTime = newEndTime;
        record.slotDuration = Number(newSlotDuration);

        if (isAvailable !== undefined) {
            record.isAvailable = isAvailable;
        }

        await record.save();

        console.log(
            "[Availability] Updated record:",
            record._id.toString()
        );

        return res.status(200).json({
            success: true,
            message: "Availability updated successfully.",
            data: record,
        });
    } catch (error) {
        console.error("[Availability] Update error:", error);
        next(error);
    }
}

// DELETE /api/doctors/availability/:id
async function deleteAvailability(req, res, next) {
    try {
        console.log("[Availability] DELETE request received");

        const doctor = await resolveApprovedDoctor(req, res);
        if (!doctor) return;

        const record = await DoctorAvailability.findOneAndDelete({
            _id: req.params.id,
            doctorId: doctor._id,
        });

        if (!record) {
            return res.status(404).json({
                success: false,
                message: "Availability record not found.",
            });
        }

        console.log(
            "[Availability] Deleted record:",
            record._id.toString()
        );

        return res.status(200).json({
            success: true,
            message: "Availability deleted successfully.",
        });
    } catch (error) {
        console.error("[Availability] Delete error:", error);
        next(error);
    }
}

module.exports = {
    getAvailability,
    createAvailability,
    updateAvailability,
    deleteAvailability,
};
