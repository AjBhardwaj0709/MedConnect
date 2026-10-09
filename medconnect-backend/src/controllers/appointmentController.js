const Appointment = require("../models/Appointment");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");
const DoctorAvailability = require("../models/DoctorAvailability");
const DoctorLeave = require("../models/DoctorLeave");
const BlockedTimeSlot = require("../models/BlockedTimeSlot");
const { createNotification } = require("../services/notificationService");
const AppointmentAction = require("../models/AppointmentAction");
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


const getIndiaDayRange = () => {
    const now = new Date();

    // Convert current time to India Standard Time (UTC+5:30)
    const indiaNow = new Date(
        now.getTime() + 330 * 60 * 1000
    );

    const start = new Date(
        Date.UTC(
            indiaNow.getUTCFullYear(),
            indiaNow.getUTCMonth(),
            indiaNow.getUTCDate()
        ) - 330 * 60 * 1000
    );

    const end = new Date(start.getTime() + 24 * 60 * 60 * 1000);

    return { start, end };
};

const countPatientActionsToday = async (
    patientId,
    action
) => {
    const { start, end } = getIndiaDayRange();

    return AppointmentAction.countDocuments({
        patientId,
        action,
        createdAt: {
            $gte: start,
            $lt: end,
        },
    });
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


        // helper function for restrict multiple booking of the time slots 
        const activeAppointmentsToday = await Appointment.countDocuments({
            patientId: patient._id,
            date: normalizedDate,
            status: {
                $in: ["pending", "confirmed"],
            },
        });

        if (activeAppointmentsToday >= 2) {
            return res.status(409).json({
                success: false,
                message:
                    "Daily appointment limit reached. You can have a maximum of 2 active appointments per day.",
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


        await createNotification({
            userId: doctor.userId,
            type: "appointment_booked",
            title: "New Appointment",
            message: `You have received a new appointment request for ${normalizedDate}.`,
            data: {
                appointmentId: appointment._id,
                patientId: patient._id,
            },
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
// --------------------------------------------------
// CANCEL APPOINTMENT
// PUT /api/appointments/:id/cancel
// --------------------------------------------------

const cancelAppointment = async (req, res) => {
    try {
        const { id } = req.params;
        const { cancellationReason } = req.body;

        // ---------------------------------------------
        // 1. Find appointment
        // ---------------------------------------------
        const appointment = await Appointment.findById(id);

        if (!appointment) {
            return res.status(404).json({
                success: false,
                message: "Appointment not found",
            });
        }

        // ---------------------------------------------
        // 2. Only pending/confirmed can be cancelled
        // ---------------------------------------------
        if (
            appointment.status !== "pending" &&
            appointment.status !== "confirmed"
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Only pending or confirmed appointments can be cancelled",
            });
        }

        // ---------------------------------------------
        // 3. Check user role and ownership
        // ---------------------------------------------

        if (req.user.role === "patient") {
            const patient = await Patient.findOne({
                userId: req.user.userId,
            });

            if (!patient) {
                return res.status(404).json({
                    success: false,
                    message: "Patient profile not found",
                });
            }

            if (
                appointment.patientId.toString() !==
                patient._id.toString()
            ) {
                return res.status(403).json({
                    success: false,
                    message:
                        "You are not authorized to cancel this appointment",
                });
            }

            const cancellationCount = await countPatientActionsToday(
                patient._id,
                "cancelled"
            );

            if (cancellationCount >= 3) {
                return res.status(429).json({
                    success: false,
                    message:
                        "Daily cancellation limit reached. You can cancel a maximum of 3 appointments per day. Please try again tomorrow.",
                });
            }
            
            // Cancel appointment
            appointment.status = "cancelled";
            appointment.cancellationReason =
                cancellationReason || "Cancelled by patient";

            await appointment.save();
            await AppointmentAction.create({
                patientId: patient._id,
                appointmentId: appointment._id,
                action: "cancelled",
            });
            // Find doctor
            const doctor = await Doctor.findById(
                appointment.doctorId
            );

            // Notify doctor
            if (doctor) {
                await createNotification({
                    userId: doctor.userId,
                    type: "appointment_cancelled",
                    title: "Appointment Cancelled",
                    message:
                        "A patient has cancelled an appointment.",
                    data: {
                        appointmentId: appointment._id,
                        patientId: patient._id,
                    },
                });
            }
        } else if (req.user.role === "doctor") {
            const doctor = await Doctor.findOne({
                userId: req.user.userId,
                isVerified: true,
                verificationStatus: "approved",
            });

            if (!doctor) {
                return res.status(404).json({
                    success: false,
                    message:
                        "Approved doctor profile not found",
                });
            }

            if (
                appointment.doctorId.toString() !==
                doctor._id.toString()
            ) {
                return res.status(403).json({
                    success: false,
                    message:
                        "You are not authorized to cancel this appointment",
                });
            }

            // Cancel appointment
            appointment.status = "cancelled";
            appointment.cancellationReason =
                cancellationReason || "Cancelled by doctor";

            await appointment.save();

            // Find patient
            const patient = await Patient.findById(
                appointment.patientId
            );

            // Notify patient
            if (patient) {
                await createNotification({
                    userId: patient.userId,
                    type: "appointment_cancelled",
                    title: "Appointment Cancelled",
                    message:
                        "Your doctor has cancelled the appointment.",
                    data: {
                        appointmentId: appointment._id,
                        doctorId: doctor._id,
                    },
                });
            }
        } else {
            return res.status(403).json({
                success: false,
                message:
                    "Only patient or doctor can cancel an appointment",
            });
        }

        // ---------------------------------------------
        // 4. Response
        // ---------------------------------------------
        return res.status(200).json({
            success: true,
            message: "Appointment cancelled successfully",
            appointment,
        });
    } catch (error) {
        console.error("Cancel appointment error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// --------------------------------------------------
// RESCHEDULE APPOINTMENT
// PUT /api/appointments/:id/reschedule
// --------------------------------------------------
const rescheduleAppointment = async (req, res) => {
    try {
        const { id } = req.params;
        const { date, startTime, endTime } = req.body;

        // ---------------------------------------------
        // 1. Validate required fields
        // ---------------------------------------------
        if (!date || !startTime || !endTime) {
            return res.status(400).json({
                success: false,
                message: "date, startTime and endTime are required",
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

        const startMinutes = timeToMinutes(startTime);
        const endMinutes = timeToMinutes(endTime);

        // ---------------------------------------------
        // 3. Validate time
        // ---------------------------------------------
        if (startMinutes >= endMinutes) {
            return res.status(400).json({
                success: false,
                message: "startTime must be before endTime",
            });
        }

        // ---------------------------------------------
        // 4. Appointment duration must be 30 minutes
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
        // 6. Prevent rescheduling to past date
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
                message: "Cannot reschedule to a past date",
            });
        }

        // ---------------------------------------------
        // 7. Find appointment
        // ---------------------------------------------
        const appointment = await Appointment.findById(id);

        if (!appointment) {
            return res.status(404).json({
                success: false,
                message: "Appointment not found",
            });
        }

        // ---------------------------------------------
        // 8. Only pending/confirmed can be rescheduled
        // ---------------------------------------------
        if (
            appointment.status !== "pending" &&
            appointment.status !== "confirmed"
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Only pending or confirmed appointments can be rescheduled",
            });
        }

        // ---------------------------------------------
        // 9. Patient ownership check
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

        if (
            appointment.patientId.toString() !==
            patient._id.toString()
        ) {
            return res.status(403).json({
                success: false,
                message:
                    "You are not authorized to reschedule this appointment",
            });
        }

        const rescheduleCount = await countPatientActionsToday(
            patient._id,
            "rescheduled"
        );

        if (rescheduleCount >= 2) {
            return res.status(429).json({
                success: false,
                message:
                    "Daily reschedule limit reached. You can reschedule a maximum of 2 appointments per day. Please try again tomorrow.",
            });
        }

        // ---------------------------------------------
        // 10. Find approved doctor
        // ---------------------------------------------
        const doctor = await Doctor.findOne({
            _id: appointment.doctorId,
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
        // 11. Check doctor leave
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
        // 12. Check day availability
        // ---------------------------------------------
        const dayOfWeek = getDayOfWeek(normalizedDate);

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
        // 13. Check blocked time
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
        // 14. Check another appointment
        // ---------------------------------------------
        const existingAppointment = await Appointment.findOne({
            _id: { $ne: appointment._id },
            doctorId: doctor._id,
            date: normalizedDate,

            status: {
                $in: ["pending", "confirmed"],
            },

            startTime: { $lt: endTime },
            endTime: { $gt: startTime },
        });

        if (existingAppointment) {
            return res.status(409).json({
                success: false,
                message: "The selected time slot is already booked",
            });
        }

        // ---------------------------------------------
        // 15. Update appointment
        // ---------------------------------------------
        appointment.date = normalizedDate;
        appointment.startTime = startTime;
        appointment.endTime = endTime;

        // Rescheduled appointment goes back to pending
        appointment.status = "pending";

        await appointment.save();

        await AppointmentAction.create({
            patientId: patient._id,
            appointmentId: appointment._id,
            action: "rescheduled",
        });
        // ---------------------------------------------
        // Notify doctor about rescheduled appointment
        // ---------------------------------------------
        await createNotification({
            userId: doctor.userId,
            type: "appointment_rescheduled",
            title: "Appointment Rescheduled",
            message: `A patient has rescheduled their appointment to ${date} at ${startTime}.`,
            data: {
                appointmentId: appointment._id,
                patientId: patient._id,
                newDate: date,
                newStartTime: startTime,
                newEndTime: endTime,
            },
        });
        // ---------------------------------------------
        // 16. Response
        // ---------------------------------------------
        return res.status(200).json({
            success: true,
            message: "Appointment rescheduled successfully",
            appointment,
        });
    } catch (error) {
        console.error("Reschedule appointment error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};
// --------------------------------------------------
// CONFIRM APPOINTMENT
// PUT /api/appointments/:id/confirm
// --------------------------------------------------

const confirmAppointment = async (req, res) => {
    try {
        const { id } = req.params;

        // ---------------------------------------------
        // 1. Find logged-in doctor
        // ---------------------------------------------
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

        // ---------------------------------------------
        // 2. Find appointment
        // ---------------------------------------------
        const appointment = await Appointment.findById(id);

        if (!appointment) {
            return res.status(404).json({
                success: false,
                message: "Appointment not found",
            });
        }

        // ---------------------------------------------
        // 3. Doctor ownership check
        // ---------------------------------------------
        if (
            appointment.doctorId.toString() !==
            doctor._id.toString()
        ) {
            return res.status(403).json({
                success: false,
                message: "You are not authorized to confirm this appointment",
            });
        }

        // ---------------------------------------------
        // 4. Appointment must be pending
        // ---------------------------------------------
        if (appointment.status !== "pending") {
            return res.status(400).json({
                success: false,
                message: "Only pending appointments can be confirmed",
            });
        }

        // ---------------------------------------------
        // 5. Confirm appointment
        // ---------------------------------------------
        appointment.status = "confirmed";

        await appointment.save();

        // ---------------------------------------------
        // 6. Notify patient
        // ---------------------------------------------
        const patient = await Patient.findById(
            appointment.patientId
        );

        if (patient) {
            await createNotification({
                userId: patient.userId,
                type: "appointment_confirmed",
                title: "Appointment Confirmed",
                message: `Your appointment has been confirmed for ${appointment.date} at ${appointment.startTime}.`,
                data: {
                    appointmentId: appointment._id,
                    doctorId: doctor._id,
                },
            });
        }

        // ---------------------------------------------
        // 7. Response
        // ---------------------------------------------
        return res.status(200).json({
            success: true,
            message: "Appointment confirmed successfully",
            appointment,
        });
    } catch (error) {
        console.error("Confirm appointment error:", error);

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
    confirmAppointment,
    cancelAppointment,
    rescheduleAppointment,
};