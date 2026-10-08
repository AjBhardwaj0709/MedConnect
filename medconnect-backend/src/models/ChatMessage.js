const mongoose = require("mongoose");

const chatMessageSchema = new mongoose.Schema(
    {
        conversationId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "ChatConversation",
            required: true,
        },

        senderId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },

        senderRole: {
            type: String,
            enum: ["patient", "doctor"],
            required: true,
        },

        messageType: {
            type: String,
            enum: ["text", "image", "document", "pdf"],
            default: "text",
            required: true,
        },

        message: {
            type: String,
            trim: true,
            default: "",
        },

        fileName: {
            type: String,
            trim: true,
            default: null,
        },

        fileUrl: {
            type: String,
            trim: true,
            default: null,
        },

        fileType: {
            type: String,
            trim: true,
            default: null,
        },

        fileSize: {
            type: Number,
            default: null,
        },

        isRead: {
            type: Boolean,
            default: false,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model(
    "ChatMessage",
    chatMessageSchema
);