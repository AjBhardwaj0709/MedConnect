const mongoose = require("mongoose");

const chatConversationSchema = new mongoose.Schema(
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

        lastMessage: {
            type: String,
            default: "",
            trim: true,
        },

        lastMessageAt: {
            type: Date,
            default: null,
        },
    },
    {
        timestamps: true,
    }
);

chatConversationSchema.index(
    { patientId: 1, doctorId: 1 },
    { unique: true }
);

module.exports = mongoose.model(
    "ChatConversation",
    chatConversationSchema
);