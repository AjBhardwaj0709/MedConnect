const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
    {
        medicineName: {
            type: String,
            required: true,
            trim: true,
        },

        dosage: {
            type: String,
            required: true,
            trim: true,
        },

        frequency: {
            type: String,
            required: true,
            trim: true,
        },

        duration: {
            type: String,
            required: true,
            trim: true,
        },

        instructions: {
            type: String,
            trim: true,
            default: "",
        },
    },
    {
        _id: false,
    }
);

const prescriptionSchema = new mongoose.Schema(
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

        diagnosis: {
            type: String,
            trim: true,
            default: "",
        },

        medicines: {
            type: [medicineSchema],
            required: true,
            validate: {
                validator: function (medicines) {
                    return medicines.length > 0;
                },
                message: "At least one medicine is required",
            },
        },

        // Overall precautions / parhez
        precautions: {
            type: [String],
            default: [],
        },

        // Food/diet restrictions
        dietInstructions: {
            type: [String],
            default: [],
        },

        // General instructions
        additionalInstructions: {
            type: String,
            trim: true,
            default: "",
        },

        // Follow-up information
        followUpDate: {
            type: Date,
            default: null,
        },

        prescriptionDate: {
            type: Date,
            required: true,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model(
    "Prescription",
    prescriptionSchema
);
