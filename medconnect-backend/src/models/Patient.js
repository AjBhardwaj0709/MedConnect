const mongoose = require("mongoose");

const patientSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
        unique: true,
    },
    name: {
        type: String,
        required: true,
        trim: true,

    },
    dateOfBirth: {
        type: Date,
    },
    gender: {
        type: String,
        enum: ["male", "female", "other"]
    },
    address: {
        type: String,
        trim: true,
        default: "",
    },
    bloodGroup: {
        type: String,
        enum: [
            "A+",
            "A-",
            "B+",
            "B-",
            "AB+",
            "AB-",
            "O+",
            "O-",
            "Unknown",
        ],
        default: "Unknown",
    },

    emergencyContact: {
        name: {
            type: String,
            trim: true,
            default: "",
        },

        phone: {
            type: String,
            trim: true,
            default: "",
        },
    }, relationship: {
        type: String,
        trim: true,
        default: "",
    },

    profileimage: {
        type: String,
    }
}, {
    timestamps: true,
});
module.exports = mongoose.model("Patient", patientSchema)
