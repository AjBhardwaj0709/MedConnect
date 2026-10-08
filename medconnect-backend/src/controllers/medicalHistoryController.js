const MedicalHistory = require("../models/MedicalHistory");
const Doctor = require("../models/Doctor");
const Patient = require("../models/Patient");
const Appointment = require("../models/Appointment");

// ==========================================
// CREATE MEDICAL HISTORY
// POST /api/medical-history
// DOCTOR ONLY
// ==========================================
const createMedicalHistory = async (req, res) => {
    try {
        const {
            patientId,
            appointmentId,
            title,
            historyType,
            description,
            surgeryDetails,
            previousMedicines,
            doctorNotes,
        } = req.body;

        // --------------------------------------
        // 1. Required fields
        // --------------------------------------
        if (
            !patientId ||
            !appointmentId ||
            !title ||
            !historyType ||
            !description
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "patientId, appointmentId, title, historyType and description are required",
            });
        }

        // --------------------------------------
        // 2. Find approved doctor
        // --------------------------------------
        const doctor = await Doctor.findOne({
            userId: req.user.userId,
            isVerified: true,
            verificationStatus: "approved",
        });

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message:
                    "Only approved doctors can create medical history",
            });
        }

        // --------------------------------------
        // 3. Check patient
        // --------------------------------------
        const patient = await Patient.findById(patientId);

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient not found",
            });
        }

        // --------------------------------------
        // 4. Check appointment
        // --------------------------------------
        const appointment = await Appointment.findOne({
            _id: appointmentId,
            doctorId: doctor._id,
            patientId: patient._id,
        });

        if (!appointment) {
            return res.status(404).json({
                success: false,
                message:
                    "Appointment not found for this doctor and patient",
            });
        }

        // --------------------------------------
        // 5. Create history
        // --------------------------------------
        const history = await MedicalHistory.create({
            patientId: patient._id,
            doctorId: doctor._id,
            appointmentId: appointment._id,
            title,
            historyType,
            description,
            surgeryDetails: surgeryDetails || {},
            previousMedicines: previousMedicines || [],
            doctorNotes: doctorNotes || "",
        });

        return res.status(201).json({
            success: true,
            message: "Medical history added successfully",
            history,
        });
    } catch (error) {
        console.error("Create medical history error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// ==========================================
// PATIENT VIEW HISTORY
// GET /api/medical-history/my
// PATIENT ONLY
// ==========================================
const getMyMedicalHistory = async (req, res) => {
    try {
        const patient = await Patient.findOne({
            userId: req.user.userId,
        });

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient profile not found",
            });
        }

        const history = await MedicalHistory.find({
            patientId: patient._id,
        })
            .populate(
                "doctorId",
                "name specialization qualification"
            )
            .populate(
                "appointmentId",
                "date startTime endTime status"
            )
            .sort({
                createdAt: -1,
            });

        return res.status(200).json({
            success: true,
            count: history.length,
            history,
        });
    } catch (error) {
        console.error("Get patient medical history error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// ==========================================
// DOCTOR VIEW PATIENT HISTORY
// GET /api/medical-history/patient/:patientId
// DOCTOR ONLY
// ==========================================
const getPatientMedicalHistory = async (req, res) => {
    try {
        const { patientId } = req.params;

        // --------------------------------------
        // 1. Find approved doctor
        // --------------------------------------
        const doctor = await Doctor.findOne({
            userId: req.user.userId,
            isVerified: true,
            verificationStatus: "approved",
        });

        if (!doctor) {
            return res.status(403).json({
                success: false,
                message: "Approved doctor profile not found",
            });
        }

        // --------------------------------------
        // 2. Check patient
        // --------------------------------------
        const patient = await Patient.findById(patientId);

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient not found",
            });
        }

        // --------------------------------------
        // 3. Get history
        // --------------------------------------
        const history = await MedicalHistory.find({
            patientId: patient._id,
        })
            .populate(
                "doctorId",
                "name specialization qualification"
            )
            .populate(
                "appointmentId",
                "date startTime endTime status"
            )
            .sort({
                createdAt: -1,
            });

        return res.status(200).json({
            success: true,
            patient: {
                id: patient._id,
                name: patient.name,
                dateOfBirth: patient.dateOfBirth,
                gender: patient.gender,
                bloodGroup: patient.bloodGroup,
            },
            count: history.length,
            history,
        });
    } catch (error) {
        console.error(
            "Get patient medical history error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    createMedicalHistory,
    getMyMedicalHistory,
    getPatientMedicalHistory,
};