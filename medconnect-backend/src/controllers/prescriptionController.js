const Prescription = require("../models/Prescription");
const Doctor = require("../models/Doctor");
const Patient = require("../models/Patient");
const Appointment = require("../models/Appointment");
const { createNotification } = require("../services/notificationService");

// ==========================================
// CREATE PRESCRIPTION
// POST /api/prescriptions
// Doctor only
// ==========================================
const createPrescription = async (req, res) => {
    try {
        const {
            patientId,
            appointmentId,
            diagnosis,
            medicines,
            precautions,
            dietInstructions,
            additionalInstructions,
            followUpDate,
            prescriptionDate,
        } = req.body;

        // --------------------------------------
        // 1. Required fields
        // --------------------------------------
        if (!patientId || !medicines || !prescriptionDate) {
            return res.status(400).json({
                success: false,
                message:
                    "patientId, medicines and prescriptionDate are required",
            });
        }

        // --------------------------------------
        // 2. Validate medicines
        // --------------------------------------
        if (!Array.isArray(medicines) || medicines.length === 0) {
            return res.status(400).json({
                success: false,
                message: "At least one medicine is required",
            });
        }

        // --------------------------------------
        // 3. Find approved doctor
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
                    "Only approved doctors can create prescriptions",
            });
        }

        // --------------------------------------
        // 4. Check patient
        // --------------------------------------
        const patient = await Patient.findById(patientId);

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient not found",
            });
        }

        // --------------------------------------
        // 5. Validate prescription date
        // --------------------------------------
        const parsedDate = new Date(prescriptionDate);

        if (isNaN(parsedDate.getTime())) {
            return res.status(400).json({
                success: false,
                message: "Invalid prescription date",
            });
        }

        // --------------------------------------
        // 6. Optional appointment validation
        // --------------------------------------
        if (appointmentId) {
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
        }

        // --------------------------------------
        // 7. Create prescription
        // --------------------------------------
        const prescription = await Prescription.create({
            patientId: patient._id,
            doctorId: doctor._id,
            appointmentId: appointmentId || null,
            diagnosis: diagnosis || "",
            medicines,
            precautions: precautions || [],
            dietInstructions: dietInstructions || [],
            additionalInstructions:
                additionalInstructions || "",
            followUpDate: followUpDate
                ? new Date(followUpDate)
                : null,
            prescriptionDate: parsedDate,
        });
        // ---------------------------------------------
        // Notify patient about new prescription
        // ---------------------------------------------
        await createNotification({
            userId: patient.userId,
            type: "prescription_created",
            title: "New Prescription",
            message: "Your doctor has created a new prescription for you.",
            data: {
                prescriptionId: prescription._id,
                doctorId: doctor._id,
                appointmentId: appointmentId || null,
            },
        });
        return res.status(201).json({
            success: true,
            message: "Prescription created successfully",
            prescription,
        });
    } catch (error) {
        console.error("Create prescription error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// ==========================================
// GET PATIENT PRESCRIPTIONS
// GET /api/prescriptions/my
// Patient only
// ==========================================
const getMyPrescriptions = async (req, res) => {
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

        const prescriptions = await Prescription.find({
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
                prescriptionDate: -1,
            });

        return res.status(200).json({
            success: true,
            count: prescriptions.length,
            prescriptions,
        });
    } catch (error) {
        console.error(
            "Get patient prescriptions error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// ==========================================
// GET DOCTOR PRESCRIPTIONS
// GET /api/prescriptions/doctor
// Doctor only
// ==========================================
const getDoctorPrescriptions = async (req, res) => {
    try {
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

        const prescriptions = await Prescription.find({
            doctorId: doctor._id,
        })
            .populate(
                "patientId",
                "name dateOfBirth gender bloodGroup"
            )
            .populate(
                "appointmentId",
                "date startTime endTime status"
            )
            .sort({
                prescriptionDate: -1,
            });

        return res.status(200).json({
            success: true,
            count: prescriptions.length,
            prescriptions,
        });
    } catch (error) {
        console.error(
            "Get doctor prescriptions error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    createPrescription,
    getMyPrescriptions,
    getDoctorPrescriptions,
};