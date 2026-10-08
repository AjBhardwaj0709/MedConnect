const Appointment = require("../models/Appointment");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");
const DoctorAvailability = require("../models/DoctorAvailability");
const DoctorLeave = require("../models/DoctorLeave");
const BlockedTimeSlot = require("../models/BlockedTimeSlot");

// --------------------------------------------------
// Helper: Normalize date to UTC day
// --------------------------------------------------
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

// --------------------------------------------------
// Helper: Convert HH:mm to minutes
// --------------------------------------------------
const timeToMinutes = (time) => {
    const [hours, minutes] = time.split(":").map(Number);

    return hours * 60 + minutes;
};

// --------------------------------------------------
// Helper: Get day of week
// --------------------------------------------------
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

// --------------------------------------------------
// BOOK APPOINTMENT
// POST /api/appointments
// --------------------------------------------------
const createAppointment = async (req, res) => {
    try {
        const {
            doctorId,
            date,
            startTime,
            endTime,
            reason,
        } = req.body;

        // ---------------------------------------------
        // 1. Validate required fields
        // ---------------------------------------------
        if (!doctorId || !date || !startTime || !endTime) {
            return res.status(400).json({
                success: false,
                message:
                    "doctorId, date, startTime and endTime are required",
            });
        }

        // ---------------------------------------------
        // 2. Validate time format
        // ---------------------------------------------
        const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;

        if (!timeRegex.test(startTime) || !timeRegex.test(endTime)) {
            return res.status(400).json({
                success: false,
                message: "Time must be in HH:mm format",
            });
        }

        // ---------------------------------------------
        // 3. Validate start/end time
        // ---------------------------------------------
        const startMinutes = timeToMinutes(startTime);
        const endMinutes = timeToMinutes(endTime);

        if (startMinutes >= endMinutes) {
            return res.status(400).json({
                success: false,
                message: "startTime must be before endTime",
            });
        }

        // ---------------------------------------------
        // 4. Currently appointments are 30 minutes
        // ---------------------------------------------
        if (endMinutes - startMinutes !== 30) {
            return res.status(400).json({
                success: false,
                message: "Appointment duration must be exactly 30 minutes",
            });
        }

        // ---------------------------------------------
        // 5. Normalize date
        // ---------------------------------------------
        const normalizedDate = normalizeDate(date);

        if (!normalizedDate) {
            return res.status(400).json({
                success: false,
                message: "Invalid date",
            });
        }

        // ---------------------------------------------
        // 6. Prevent booking in the past
        // ---------------------------------------------
        const today = new Date();

        const todayUTC = new Date(
            Date.UTC(
                today.getUTCFullYear(),
                today.getUTCMonth(),
                today.getUTCDate()
            )
        );

        if (normalizedDate < todayUTC) {
            return res.status(400).json({
                success: false,
                message: "Cannot book an appointment for a past date",
            });
        }

        // ---------------------------------------------
        // 7. Find logged-in patient
        // ---------------------------------------------
        const patient = await Patient.findOne({
            userId: req.user.userId,
        });

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient profile not found",
            });
        }

        // ---------------------------------------------
        // 8. Find approved doctor
        // ---------------------------------------------
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

        // ---------------------------------------------
        // 9. Check doctor leave
        // ---------------------------------------------
        const leave = await DoctorLeave.findOne({
            doctorId: doctor._id,
            startDate: { $lte: normalizedDate },
            endDate: { $gte: normalizedDate },
        });

        if (leave) {
            return res.status(409).json({
                success: false,
                message: "Doctor is on leave on the selected date",
            });
        }

        // ---------------------------------------------
        // 10. Get day of week
        // ---------------------------------------------
        const dayOfWeek = getDayOfWeek(normalizedDate);

        // ---------------------------------------------
        // 11. Check doctor's availability
        // ---------------------------------------------
        const availability = await DoctorAvailability.findOne({
            doctorId: doctor._id,
            dayOfWeek,
            isAvailable: true,
            startTime: { $lte: startTime },
            endTime: { $gte: endTime },
        });

        if (!availability) {
            return res.status(409).json({
                success: false,
                message: "Doctor is not available at the selected time",
            });
        }

       
        // ---------------------------------------------
        // 12. Check blocked time
        // ---------------------------------------------
        const blockedSlot = await BlockedTimeSlot.findOne({
            doctorId: doctor._id,
            date: normalizedDate,
            startTime: { $lt: endTime },
            endTime: { $gt: startTime },
        });

        if (blockedSlot) {
            return res.status(409).json({
                success: false,
                message: "Selected time is blocked by the doctor",
            });
        }

        // ---------------------------------------------
        // 13. Check existing appointment
        // ---------------------------------------------
        const existingAppointment = await Appointment.findOne({
            doctorId: doctor._id,
            date: normalizedDate,

            // Only active appointments block the slot
            status: {
                $in: ["pending", "confirmed"],
            },

            // Overlap check
            startTime: { $lt: endTime },
            endTime: { $gt: startTime },
        });

        if (existingAppointment) {
            return res.status(409).json({
                success: false,
                message: "This appointment slot is already booked",
            });
        }

        // ---------------------------------------------
        // 14. Create appointment
        // ---------------------------------------------
        const appointment = await Appointment.create({
            patientId: patient._id,
            doctorId: doctor._id,
            date: normalizedDate,
            startTime,
            endTime,
            reason: reason || "",
            status: "pending",
        });

        // ---------------------------------------------
        // 15. Return response
        // ---------------------------------------------
        return res.status(201).json({
            success: true,
            message: "Appointment booked successfully",
            appointment,
        });
    } catch (error) {
        console.error("Create appointment error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};
// --------------------------------------------------
// GET PATIENT APPOINTMENTS
// GET /api/appointments/my
// --------------------------------------------------
const getMyAppointments = async (req, res) => {
    try {
        // Find logged-in patient
        const patient = await Patient.findOne({
            userId: req.user.userId,
        });

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient profile not found",
            });
        }

        const appointments = await Appointment.find({
            patientId: patient._id,
        })
            .populate(
                "doctorId",
                "name specialization qualification experience consultationFee clinicName clinicAddress profileImage"
            )
            .sort({
                date: 1,
                startTime: 1,
            });

        return res.status(200).json({
            success: true,
            count: appointments.length,
            appointments,
        });
    } catch (error) {
        console.error("Get patient appointments error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// --------------------------------------------------
// GET DOCTOR APPOINTMENTS
// GET /api/appointments/doctor
// --------------------------------------------------
const getDoctorAppointments = async (req, res) => {
    try {
        // Find logged-in doctor
        const doctor = await Doctor.findOne({
            userId: req.user.userId,
            isVerified: true,
            verificationStatus: "approved",
        });

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Approved doctor profile not found",
            });
        }

        const appointments = await Appointment.find({
            doctorId: doctor._id,
        })
            .populate(
                "patientId",
                "name dateOfBirth gender bloodGroup emergencyContact profileImage"
            )
            .sort({
                date: 1,
                startTime: 1,
            });

        return res.status(200).json({
            success: true,
            count: appointments.length,
            appointments,
        });
    } catch (error) {
        console.error("Get doctor appointments error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    createAppointment,
    getMyAppointments,
    getDoctorAppointments,
};
