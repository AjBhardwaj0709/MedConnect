const mongoose = require("mongoose");

const medicalHistorySchema = new mongoose.Schema(
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
            required: true,
        },

        title: {
            type: String,
            required: true,
            trim: true,
        },

        historyType: {
            type: String,
            enum: [
                "surgery",
                "medical_condition",
                "previous_treatment",
                "allergy",
                "medication_history",
                "other",
            ],
            required: true,
        },

        description: {
            type: String,
            required: true,
            trim: true,
        },

        surgeryDetails: {
            surgeryName: {
                type: String,
                trim: true,
                default: "",
            },

            surgeryDate: {
                type: Date,
                default: null,
            },

            hospitalName: {
                type: String,
                trim: true,
                default: "",
            },

            notes: {
                type: String,
                trim: true,
                default: "",
            },
        },

        previousMedicines: [
            {
                medicineName: {
                    type: String,
                    trim: true,
                },

                dosage: {
                    type: String,
                    trim: true,
                },

                frequency: {
                    type: String,
                    trim: true,
                },

                duration: {
                    type: String,
                    trim: true,
                },

                prescribedBy: {
                    type: String,
                    trim: true,
                },
            },
        ],

        doctorNotes: {
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
    "MedicalHistory",
    medicalHistorySchema
);