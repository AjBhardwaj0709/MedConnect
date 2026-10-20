const mongoose = require("mongoose");

const doctorAvailabilitySchema = new mongoose.Schema(
    {
        doctorId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Doctor",
            required: true,
            index: true,
        },

        // The date this period applies to, normalized to UTC midnight.
        date: {
            type: Date,
            required: true,
        },

        startTime: {
            type: String,
            required: true,
            match: /^([01]\d|2[0-3]):[0-5]\d$/,
        },

        endTime: {
            type: String,
            required: true,
            match: /^([01]\d|2[0-3]):[0-5]\d$/,
        },

        slotDuration: {
            type: Number,
            required: true,
            enum: [15, 20, 30, 45, 60],
            default: 30,
        },

        isAvailable: {
            type: Boolean,
            default: true,
        },
    },
    { timestamps: true }
);

doctorAvailabilitySchema.index({ doctorId: 1, date: 1 });

module.exports = mongoose.model(
    "DoctorAvailability",
    doctorAvailabilitySchema
);