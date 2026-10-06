const mongoose = require("mongoose");
const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true
    },
    password: {
        type: String,
        required: true,
        minlength: 8,
        select: false,
    }, role: {
        type: String,
        require: true,
        enum: ["patient", "doctor", "admin"]
    }, isActive: {
        type: Boolean,
        default: true,

    }
}, { timestamps: true }
);
module.exports = mongoose.model("User",userSchema);