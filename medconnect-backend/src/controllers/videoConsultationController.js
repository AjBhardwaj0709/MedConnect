const crypto = require("crypto");

const Appointment = require("../models/Appointment");
const VideoConsultation = require("../models/VideoConsultation");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");

const JITSI_SERVER_URL = "https://meet.jit.si";

const formatVideoSession = (session) => ({
    ...session.toObject(),
    serverUrl: JITSI_SERVER_URL,
    meetingUrl: `${JITSI_SERVER_URL}/${session.roomId}`,
});

const isValidObjectId = (id) =>
    /^[0-9a-fA-F]{24}$/.test(id || "");

const getProfile = async (req) => {
    if (req.user.role === "patient") {
        return Patient.findOne({ userId: req.user.userId });
    }

    if (req.user.role === "doctor") {
        return Doctor.findOne({ userId: req.user.userId });
    }

    return null;
};

const canAccessAppointment = (appointment, profile, role) => {
    if (!appointment || !profile) return false;

    if (role === "patient") {
        return appointment.patientId.toString() === profile._id.toString();
    }

    if (role === "doctor") {
        return appointment.doctorId.toString() === profile._id.toString();
    }

    return false;
};

// Convert appointment date + HH:mm into a real instant in India Standard Time.
const getAppointmentWindow = (appointment) => {
    const date = new Date(appointment.date);

    if (Number.isNaN(date.getTime())) {
        throw new Error("Invalid appointment date.");
    }

    // Use the UTC calendar date stored in the appointment's date field.
    const year = date.getUTCFullYear();
    const month = date.getUTCMonth();
    const day = date.getUTCDate();

    const toISTInstant = (time) => {
        const [hours, minutes] = time.split(":").map(Number);

        // IST is UTC+05:30.
        return new Date(
            Date.UTC(year, month, day, hours, minutes) - 330 * 60 * 1000
        );
    };

    return {
        start: toISTInstant(appointment.startTime),
        end: toISTInstant(appointment.endTime),
    };
};

const isWithinAppointmentTime = (appointment) => {
    const { start, end } = getAppointmentWindow(appointment);
    const now = new Date();

    return now >= start && now < end;
};

// Create or retrieve a session for a confirmed appointment.
const createVideoSession = async (req, res) => {
    try {
        const { appointmentId } = req.params;

        if (!isValidObjectId(appointmentId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid appointment ID.",
            });
        }

        const profile = await getProfile(req);

        if (!profile) {
            return res.status(404).json({
                success: false,
                message: "User profile not found.",
            });
        }

        const appointment = await Appointment.findById(appointmentId);

        if (!canAccessAppointment(appointment, profile, req.user.role)) {
            return res.status(403).json({
                success: false,
                message: "You cannot access this appointment.",
            });
        }

        if (appointment.status !== "confirmed") {
            return res.status(409).json({
                success: false,
                message: "Video sessions require a confirmed appointment.",
            });
        }

        let session = await VideoConsultation.findOne({ appointmentId });

        if (session) {
            if (session.status === "cancelled") {
                return res.status(409).json({
                    success: false,
                    message: "This video session has been cancelled.",
                });
            }

            return res.status(200).json({
                success: true,
                message: "Video session already exists.",
                session: formatVideoSession(session),
            });
        }

        session = await VideoConsultation.create({
            appointmentId: appointment._id,
            patientId: appointment.patientId,
            doctorId: appointment.doctorId,
            roomId: crypto.randomBytes(24).toString("hex"),
        });

        return res.status(201).json({
            success: true,
            message: "Video session created successfully.",
            session: formatVideoSession(session),
        });
    } catch (error) {
        if (error.code === 11000) {
            const session = await VideoConsultation.findOne({
                appointmentId: req.params.appointmentId,
            });

            if (session && session.status !== "cancelled") {
                return res.status(200).json({
                    success: true,
                    message: "Video session already exists.",
                    session: formatVideoSession(session),
                });
            }
        }

        console.error("Create video session error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to create video session.",
        });
    }
};

// Either participant can retrieve their own appointment's session.
const getVideoSession = async (req, res) => {
    try {
        const { appointmentId } = req.params;

        if (!isValidObjectId(appointmentId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid appointment ID.",
            });
        }

        const profile = await getProfile(req);

        if (!profile) {
            return res.status(404).json({
                success: false,
                message: "User profile not found.",
            });
        }

        const appointment = await Appointment.findById(appointmentId);

        if (!canAccessAppointment(appointment, profile, req.user.role)) {
            return res.status(403).json({
                success: false,
                message: "You cannot access this appointment.",
            });
        }

        const session = await VideoConsultation.findOne({ appointmentId });

        if (!session) {
            return res.status(404).json({
                success: false,
                message: "Video session not found.",
            });
        }

        return res.status(200).json({
            success: true,
            session: formatVideoSession(session),
        });
    } catch (error) {
        console.error("Get video session error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to fetch video session.",
        });
    }
};

// Doctors can initiate at any time.
// Patients can initiate only during the confirmed appointment window.
const startVideoSession = async (req, res) => {
    try {
        const { sessionId } = req.params;

        if (!isValidObjectId(sessionId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid video session ID.",
            });
        }

        const profile = await getProfile(req);

        if (!profile) {
            return res.status(404).json({
                success: false,
                message: "User profile not found.",
            });
        }

        const session = await VideoConsultation.findById(sessionId);

        if (!session) {
            return res.status(404).json({
                success: false,
                message: "Video session not found.",
            });
        }

        const appointment = await Appointment.findById(session.appointmentId);

        if (!canAccessAppointment(appointment, profile, req.user.role)) {
            return res.status(403).json({
                success: false,
                message: "You cannot access this video session.",
            });
        }

        if (appointment.status !== "confirmed") {
            return res.status(409).json({
                success: false,
                message: "Only confirmed appointments can start a video session.",
            });
        }

        if (session.status === "cancelled") {
            return res.status(409).json({
                success: false,
                message: "This video session has been cancelled.",
            });
        }

        if (session.status === "started") {
            return res.status(409).json({
                success: false,
                message: "This video session has already been started.",
            });
        }

        if (
            req.user.role === "patient" &&
            !isWithinAppointmentTime(appointment)
        ) {
            const { start, end } = getAppointmentWindow(appointment);

            return res.status(403).json({
                success: false,
                message: "Patients can initiate calls only during the appointment time.",
                appointmentStart: start.toISOString(),
                appointmentEnd: end.toISOString(),
            });
        }

        // An ended session can be restarted by an authorized caller.
        session.status = "started";
        session.startedAt = new Date();
        session.endedAt = null;

        await session.save();

        return res.status(200).json({
            success: true,
            message: "Video session started.",
            session: formatVideoSession(session),
        });
    } catch (error) {
        console.error("Start video session error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to start video session.",
        });
    }
};

// Either participant can end their own appointment's started session.
const endVideoSession = async (req, res) => {
    try {
        const { sessionId } = req.params;

        if (!isValidObjectId(sessionId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid video session ID.",
            });
        }

        const profile = await getProfile(req);

        if (!profile) {
            return res.status(404).json({
                success: false,
                message: "User profile not found.",
            });
        }

        const session = await VideoConsultation.findById(sessionId);

        if (!session) {
            return res.status(404).json({
                success: false,
                message: "Video session not found.",
            });
        }

        const appointment = await Appointment.findById(session.appointmentId);

        if (!canAccessAppointment(appointment, profile, req.user.role)) {
            return res.status(403).json({
                success: false,
                message: "You cannot access this video session.",
            });
        }

        if (session.status !== "started") {
            return res.status(409).json({
                success: false,
                message: "Only started sessions can be ended.",
            });
        }

        session.status = "ended";
        session.endedAt = new Date();

        await session.save();

        return res.status(200).json({
            success: true,
            message: "Video session ended.",
            session: formatVideoSession(session),
        });
    } catch (error) {
        console.error("End video session error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to end video session.",
        });
    }
};

module.exports = {
    createVideoSession,
    getVideoSession,
    startVideoSession,
    endVideoSession,
};