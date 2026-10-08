const MedicalReport = require("../models/MedicalReport");
const Doctor = require("../models/Doctor");
const Patient = require("../models/Patient");
const Appointment = require("../models/Appointment");

// ==========================================
// CREATE MEDICAL REPORT
// POST /api/medical-reports
// Doctor only
// ==========================================
const createMedicalReport = async (req, res) => {
    try {
        const {
            patientId,
            appointmentId,
            title,
            description,
            reportType,
            reportDate,
            fileUrl,
        } = req.body;

        // --------------------------------------
        // 1. Required fields
        // --------------------------------------
        if (!patientId || !title || !reportDate) {
            return res.status(400).json({
                success: false,
                message: "patientId, title and reportDate are required",
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
                message: "Only approved doctors can create medical reports",
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
        // 4. Validate report date
        // --------------------------------------
        const parsedDate = new Date(reportDate);

        if (isNaN(parsedDate.getTime())) {
            return res.status(400).json({
                success: false,
                message: "Invalid report date",
            });
        }

        // --------------------------------------
        // 5. Optional appointment validation
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
        // 6. Create report
        // --------------------------------------
        const report = await MedicalReport.create({
            patientId: patient._id,
            doctorId: doctor._id,
            appointmentId: appointmentId || null,
            title,
            description: description || "",
            reportType: reportType || "other",
            reportDate: parsedDate,
            fileUrl: fileUrl || "",
        });

        return res.status(201).json({
            success: true,
            message: "Medical report created successfully",
            report,
        });
    } catch (error) {
        console.error("Create medical report error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// ==========================================
// GET PATIENT REPORTS
// GET /api/medical-reports/my
// Patient only
// ==========================================
const getMyMedicalReports = async (req, res) => {
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

        const reports = await MedicalReport.find({
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
                reportDate: -1,
            });

        return res.status(200).json({
            success: true,
            count: reports.length,
            reports,
        });
    } catch (error) {
        console.error("Get patient medical reports error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

// ==========================================
// GET DOCTOR REPORTS
// GET /api/medical-reports/doctor
// Doctor only
// ==========================================
const getDoctorMedicalReports = async (req, res) => {
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

        const reports = await MedicalReport.find({
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
                reportDate: -1,
            });

        return res.status(200).json({
            success: true,
            count: reports.length,
            reports,
        });
    } catch (error) {
        console.error("Get doctor medical reports error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    createMedicalReport,
    getMyMedicalReports,
    getDoctorMedicalReports,
};