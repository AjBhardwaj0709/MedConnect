const ChatConversation = require("../models/ChatConversation");
const ChatMessage = require("../models/ChatMessage");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");

// =====================================================
// CREATE / GET CONVERSATION
// =====================================================

const createConversation = async (req, res) => {
    try {
        const { patientId, doctorId } = req.body;

        if (!patientId || !doctorId) {
            return res.status(400).json({
                success: false,
                message: "patientId and doctorId are required",
            });
        }

        // Find logged-in user's profile
        let patient;
        let doctor;

        if (req.user.role === "patient") {
            patient = await Patient.findOne({
                _id: patientId,
                userId: req.user.userId,
            });

            if (!patient) {
                return res.status(403).json({
                    success: false,
                    message: "You can only create a conversation for yourself",
                });
            }

            doctor = await Doctor.findOne({
                _id: doctorId,
                isVerified: true,
                verificationStatus: "approved",
            });
        } else if (req.user.role === "doctor") {
            doctor = await Doctor.findOne({
                _id: doctorId,
                userId: req.user.userId,
                isVerified: true,
                verificationStatus: "approved",
            });

            if (!doctor) {
                return res.status(403).json({
                    success: false,
                    message: "You can only create a conversation for yourself",
                });
            }

            patient = await Patient.findById(patientId);
        }

        if (!patient) {
            return res.status(404).json({
                success: false,
                message: "Patient not found",
            });
        }

        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: "Approved doctor not found",
            });
        }

        let conversation = await ChatConversation.findOne({
            patientId: patient._id,
            doctorId: doctor._id,
        });

        if (!conversation) {
            conversation = await ChatConversation.create({
                patientId: patient._id,
                doctorId: doctor._id,
            });
        }

        return res.status(200).json({
            success: true,
            message: "Conversation ready",
            conversation,
        });
    } catch (error) {
        console.error("Create conversation error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to create conversation",
            error: error.message,
        });
    }
};

// =====================================================
// GET MY CONVERSATIONS
// =====================================================

const getMyConversations = async (req, res) => {
    try {
        let filter = {};

        if (req.user.role === "patient") {
            const patient = await Patient.findOne({
                userId: req.user.userId,
            });

            if (!patient) {
                return res.status(404).json({
                    success: false,
                    message: "Patient profile not found",
                });
            }

            filter.patientId = patient._id;
        } else if (req.user.role === "doctor") {
            const doctor = await Doctor.findOne({
                userId: req.user.userId,
            });

            if (!doctor) {
                return res.status(404).json({
                    success: false,
                    message: "Doctor profile not found",
                });
            }

            filter.doctorId = doctor._id;
        } else {
            return res.status(403).json({
                success: false,
                message: "Only patients and doctors can access chats",
            });
        }

        const conversations = await ChatConversation.find(filter)
            .populate("patientId", "name profileImage")
            .populate(
                "doctorId",
                "name specialization profileImage"
            )
            .sort({ lastMessageAt: -1, createdAt: -1 });

        return res.status(200).json({
            success: true,
            count: conversations.length,
            conversations,
        });
    } catch (error) {
        console.error("Get conversations error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to get conversations",
            error: error.message,
        });
    }
};

// =====================================================
// GET MESSAGES
// =====================================================

const getMessages = async (req, res) => {
    try {
        const { conversationId } = req.params;

        const conversation = await ChatConversation.findById(
            conversationId
        );

        if (!conversation) {
            return res.status(404).json({
                success: false,
                message: "Conversation not found",
            });
        }

        const isPatient =
            req.user.role === "patient" &&
            String(conversation.patientId) === String(req.user.profileId);

        const isDoctor =
            req.user.role === "doctor" &&
            String(conversation.doctorId) === String(req.user.profileId);

        // We will resolve profileId below if middleware doesn't provide it.
        let authorized = false;

        if (req.user.role === "patient") {
            const patient = await Patient.findOne({
                _id: conversation.patientId,
                userId: req.user.userId,
            });

            authorized = !!patient;
        }

        if (req.user.role === "doctor") {
            const doctor = await Doctor.findOne({
                _id: conversation.doctorId,
                userId: req.user.userId,
            });

            authorized = !!doctor;
        }

        if (!authorized) {
            return res.status(403).json({
                success: false,
                message: "You are not a member of this conversation",
            });
        }

        const messages = await ChatMessage.find({
            conversationId,
        })
            .sort({ createdAt: 1 })
            .populate("senderId", "email phone role");

        return res.status(200).json({
            success: true,
            count: messages.length,
            messages,
        });
    } catch (error) {
        console.error("Get messages error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to get messages",
            error: error.message,
        });
    }
};

// =====================================================
// MARK MESSAGE AS READ
// =====================================================

const markMessageAsRead = async (req, res) => {
    try {
        const { messageId } = req.params;

        const message = await ChatMessage.findById(messageId);

        if (!message) {
            return res.status(404).json({
                success: false,
                message: "Message not found",
            });
        }

        const conversation = await ChatConversation.findById(
            message.conversationId
        );

        if (!conversation) {
            return res.status(404).json({
                success: false,
                message: "Conversation not found",
            });
        }

        let authorized = false;

        if (req.user.role === "patient") {
            const patient = await Patient.findOne({
                _id: conversation.patientId,
                userId: req.user.userId,
            });

            authorized = !!patient;
        }

        if (req.user.role === "doctor") {
            const doctor = await Doctor.findOne({
                _id: conversation.doctorId,
                userId: req.user.userId,
            });

            authorized = !!doctor;
        }

        if (!authorized) {
            return res.status(403).json({
                success: false,
                message: "You are not a member of this conversation",
            });
        }

        message.isRead = true;
        await message.save();

        return res.status(200).json({
            success: true,
            message: "Message marked as read",
        });
    } catch (error) {
        console.error("Mark message read error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to mark message as read",
            error: error.message,
        });
    }
};

module.exports = {
    createConversation,
    getMyConversations,
    getMessages,
    markMessageAsRead,
};