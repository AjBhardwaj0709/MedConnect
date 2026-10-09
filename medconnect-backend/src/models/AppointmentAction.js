
const mongoose = require("mongoose");

const appointmentActionSchema = new mongoose.Schema(
    {
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Patient",
            required: true,
            index: true,
        },

        appointmentId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Appointment",
            required: true,
        },

        action: {
            type: String,
            enum: ["cancelled", "rescheduled"],
            required: true,
        },
    },
    {
        timestamps: true,
    }
);

appointmentActionSchema.index({
    patientId: 1,
    action: 1,
    createdAt: 1,
});

module.exports = mongoose.model(
    "AppointmentAction",
    appointmentActionSchema
);
