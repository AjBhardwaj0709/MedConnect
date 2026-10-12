
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
    {
        email: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true,
        },

        password: {
            type: String,
            required: true,
            minlength: 8,
            select: false,
        },

        role: {
            type: String,
            required: true,
            enum: ["patient", "doctor", "admin"],
        },

        isActive: {
            type: Boolean,
            default: true,
        },

        // Email verification
        isEmailVerified: {
            type: Boolean,
            default: false,
        },

        emailVerificationTokenHash: {
            type: String,
            select: false,
        },

        emailVerificationExpires: {
            type: Date,
            select: false,
        },

        // Password reset
        passwordResetTokenHash: {
            type: String,
            select: false,
        },

        passwordResetExpires: {
            type: Date,
            select: false,
        },
    },
    { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
