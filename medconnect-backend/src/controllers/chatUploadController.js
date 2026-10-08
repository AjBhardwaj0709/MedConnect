const cloudinary = require("../config/cloudinary");
const ChatConversation = require("../models/ChatConversation");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");

const uploadChatFile = async (req, res) => {
    try {
        const { conversationId } = req.body;

        // =================================================
        // CONVERSATION ID VALIDATION
        // =================================================

        if (!conversationId) {
            return res.status(400).json({
                success: false,
                message: "conversationId is required",
            });
        }

        // =================================================
        // FILE VALIDATION
        // =================================================

        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "No file uploaded",
            });
        }

        // Empty file validation
        if (req.file.size === 0) {
            return res.status(400).json({
                success: false,
                message: "Empty files are not allowed",
            });
        }

        // =================================================
        // FIND CONVERSATION
        // =================================================

        const conversation =
            await ChatConversation.findById(
                conversationId
            );

        if (!conversation) {
            return res.status(404).json({
                success: false,
                message: "Conversation not found",
            });
        }

        // =================================================
        // CHECK CONVERSATION MEMBERSHIP
        // =================================================

        let authorized = false;

        // Patient authorization
        if (req.user.role === "patient") {
            const patient =
                await Patient.findOne({
                    _id: conversation.patientId,
                    userId: req.user.userId,
                });

            authorized = !!patient;
        }

        // Doctor authorization
        if (req.user.role === "doctor") {
            const doctor =
                await Doctor.findOne({
                    _id: conversation.doctorId,
                    userId: req.user.userId,
                });

            authorized = !!doctor;
        }

        // =================================================
        // UNAUTHORIZED CONVERSATION
        // =================================================

        if (!authorized) {
            return res.status(403).json({
                success: false,
                message:
                    "You are not a member of this conversation",
            });
        }

        // =================================================
        // FILE
        // =================================================

        const file = req.file;

        // =================================================
        // DETERMINE MESSAGE TYPE
        // =================================================

        let messageType;

        if (file.mimetype.startsWith("image/")) {
            messageType = "image";
        } else if (
            file.mimetype === "application/pdf"
        ) {
            messageType = "pdf";
        } else {
            messageType = "document";
        }

        // =================================================
        // UPLOAD TO CLOUDINARY
        // =================================================

        const uploadResult = await new Promise(
            (resolve, reject) => {
                const resourceType =
                    messageType === "image"
                        ? "image"
                        : "raw";

                const uploadStream =
                    cloudinary.uploader.upload_stream(
                        {
                            resource_type: resourceType,
                            folder: "medconnect/chat",
                            use_filename: true,
                            unique_filename: true,
                        },
                        (error, result) => {
                            if (error) {
                                return reject(error);
                            }

                            resolve(result);
                        }
                    );

                uploadStream.end(file.buffer);
            }
        );

        // =================================================
        // SUCCESS RESPONSE
        // =================================================

        return res.status(200).json({
            success: true,
            message: "File uploaded successfully",

            file: {
                fileName: file.originalname,
                fileUrl: uploadResult.secure_url,
                fileType: file.mimetype,
                fileSize: file.size,
                messageType,
                publicId: uploadResult.public_id,
            },
        });
    } catch (error) {
        console.error(
            "Chat file upload error:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Failed to upload file",
            error: error.message,
        });
    }
};

module.exports = {
    uploadChatFile,
};