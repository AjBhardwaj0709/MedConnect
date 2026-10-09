
const mongoose = require("mongoose");

const videoConsultationSchema = new mongoose.Schema(
    {
        appointmentId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Appointment",
            required: true,
            unique: true,
        },

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

        roomId: {
            type: String,
            required: true,
            unique: true,
        },

        status: {
            type: String,
            enum: ["scheduled", "started", "ended", "cancelled"],
            default: "scheduled",
        },

        startedAt: {
            type: Date,
            default: null,
        },

        endedAt: {
            type: Date,
            default: null,
        },
    },
    { timestamps: true }
);

module.exports = mongoose.model(
    "VideoConsultation",
    videoConsultationSchema
);
