const mongoose = require("mongoose");

const doctorSchema = new mongoose.Schema(
    {
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

        specialization: {
            type: String,
            required: true,
            trim: true,
        },

        qualification: {
            type: String,
            required: true,
            trim: true,
        },

        experience: {
            type: Number,
            default: 0,
            min: 0,
        },

        registrationNumber: {
            type: String,
            required: true,
            unique: true,
            trim: true,
        },

        consultationFee: {
            type: Number,
            default: 0,
            min: 0,
        },
        languages:{
            type: [String],
            default: [],
        },
        clinicName: {
            type: String,
            default: "",
            trim: true,
        },

        clinicAddress: {
            type: String,
            default: "",
            trim: true,
        },
        profileImage: {
            type: String,
        },

        isVerified: {
            type: Boolean,
            default: false,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model("Doctor", doctorSchema);