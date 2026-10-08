const mongoose = require("mongoose");

const medicalReportSchema = new mongoose.Schema(
    {
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Patient",
            required: true,
        },

        doctorId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Doctor",
            required: true,
        },

        appointmentId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Appointment",
            required: false,
        },

        title: {
            type: String,
            required: true,
            trim: true,
        },

        description: {
            type: String,
            trim: true,
            default: "",
        },

        reportType: {
            type: String,
            enum: [
                "lab",
                "prescription",
                "diagnostic",
                "imaging",
                "discharge",
                "other",
            ],
            default: "other",
        },

        reportDate: {
            type: Date,
            required: true,
        },

        fileUrl: {
            type: String,
            trim: true,
            default: "",
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model(
    "MedicalReport",
    medicalReportSchema
);