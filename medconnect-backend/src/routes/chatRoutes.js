const express = require("express");

const {
    createConversation,
    getMyConversations,
    getMessages,
    markMessageAsRead,
} = require("../controllers/chatController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const upload = require("../config/upload");

const {
    uploadChatFile,
} = require("../controllers/chatUploadController");

const router = express.Router();

router.use(
    protect,
    authorize("patient", "doctor")
);

// =====================================================
// FILE UPLOAD ERROR HANDLER
// =====================================================

const handleChatFileUpload = (req, res, next) => {
    upload.single("file")(req, res, (error) => {
        if (error) {

            // File larger than 10 MB
            if (error.code === "LIMIT_FILE_SIZE") {
                return res.status(400).json({
                    success: false,
                    message:
                        "File size must not exceed 10 MB",
                });
            }

            // Invalid file type
            return res.status(400).json({
                success: false,
                message: error.message,
            });
        }

        next();
    });
};

// =====================================================
// CHAT FILE UPLOAD
// =====================================================

router.post(
    "/upload",
    handleChatFileUpload,
    uploadChatFile
);

// =====================================================
// CREATE OR GET CONVERSATION
// =====================================================

router.post(
    "/",
    createConversation
);

// =====================================================
// GET MY CONVERSATIONS
// =====================================================

router.get(
    "/",
    getMyConversations
);

// =====================================================
// GET CONVERSATION MESSAGES
// =====================================================

router.get(
    "/:conversationId/messages",
    getMessages
);

// =====================================================
// MARK MESSAGE AS READ
// =====================================================

router.put(
    "/messages/:messageId/read",
    markMessageAsRead
);

module.exports = router;