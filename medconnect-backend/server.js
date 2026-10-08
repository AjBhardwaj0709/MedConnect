require("dotenv").config();

const http = require("http");
const jwt = require("jsonwebtoken");
const dns = require("dns");
const { Server } = require("socket.io");

const app = require("./src/app");

const {
    startAppointmentReminderJob,
} = require("./src/jobs/appointmentReminderJob");

const connectDB = require("./src/config/db");

const ChatConversation = require("./src/models/ChatConversation");
const ChatMessage = require("./src/models/ChatMessage");
const Patient = require("./src/models/Patient");
const Doctor = require("./src/models/Doctor");

dns.setServers(["1.1.1.1", "8.8.8.8"]);

const PORT = process.env.PORT || 5000;

// Create HTTP server
const server = http.createServer(app);

// Create Socket.IO server
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"],
    },
});

// =====================================================
// SOCKET.IO AUTHENTICATION
// =====================================================

io.use((socket, next) => {
    try {
        const token = socket.handshake.auth?.token;

        if (!token) {
            return next(
                new Error("Authentication token required")
            );
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        socket.user = decoded;

        next();
    } catch (error) {
        console.error(
            "Socket authentication error:",
            error.message
        );

        next(new Error("Invalid or expired token"));
    }
});

// =====================================================
// SOCKET.IO CONNECTION
// =====================================================

io.on("connection", (socket) => {
    console.log(
        `Socket connected: ${socket.id} | User: ${socket.user.userId} | Role: ${socket.user.role}`
    );

    // =================================================
    // JOIN CONVERSATION
    // =================================================

    socket.on(
        "joinConversation",
        async (conversationId) => {
            try {
                const conversation =
                    await ChatConversation.findById(
                        conversationId
                    );

                if (!conversation) {
                    return socket.emit("chatError", {
                        message: "Conversation not found",
                    });
                }

                let authorized = false;

                // Patient authorization
                if (socket.user.role === "patient") {
                    const patient =
                        await Patient.findOne({
                            _id: conversation.patientId,
                            userId: socket.user.userId,
                        });

                    authorized = !!patient;
                }

                // Doctor authorization
                if (socket.user.role === "doctor") {
                    const doctor =
                        await Doctor.findOne({
                            _id: conversation.doctorId,
                            userId: socket.user.userId,
                        });

                    authorized = !!doctor;
                }

                if (!authorized) {
                    return socket.emit("chatError", {
                        message:
                            "You are not a member of this conversation",
                    });
                }

                socket.join(
                    `conversation:${conversationId}`
                );

                socket.emit("conversationJoined", {
                    conversationId,
                });

                console.log(
                    `${socket.user.role} joined conversation ${conversationId}`
                );
            } catch (error) {
                console.error(
                    "Join conversation error:",
                    error
                );

                socket.emit("chatError", {
                    message:
                        "Failed to join conversation",
                });
            }
        }
    );

    // =================================================
    // SEND MESSAGE
    // =================================================

    socket.on("sendMessage", async (data) => {
        try {
            const {
                conversationId,
                message = "",
                messageType = "text",
                fileName = null,
                fileUrl = null,
                fileType = null,
                fileSize = null,
            } = data;

            // -----------------------------------------
            // BASIC VALIDATION
            // -----------------------------------------

            if (!conversationId) {
                return socket.emit("chatError", {
                    message:
                        "conversationId is required",
                });
            }

            const conversation =
                await ChatConversation.findById(
                    conversationId
                );

            if (!conversation) {
                return socket.emit("chatError", {
                    message:
                        "Conversation not found",
                });
            }

            // -----------------------------------------
            // AUTHORIZATION
            // -----------------------------------------

            let authorized = false;

            if (socket.user.role === "patient") {
                const patient =
                    await Patient.findOne({
                        _id: conversation.patientId,
                        userId: socket.user.userId,
                    });

                authorized = !!patient;
            }

            if (socket.user.role === "doctor") {
                const doctor =
                    await Doctor.findOne({
                        _id: conversation.doctorId,
                        userId: socket.user.userId,
                    });

                authorized = !!doctor;
            }

            if (!authorized) {
                return socket.emit("chatError", {
                    message:
                        "You are not a member of this conversation",
                });
            }

            // -----------------------------------------
            // MESSAGE TYPE VALIDATION
            // -----------------------------------------

            const allowedTypes = [
                "text",
                "image",
                "document",
                "pdf",
            ];

            if (!allowedTypes.includes(messageType)) {
                return socket.emit("chatError", {
                    message:
                        "Invalid message type",
                });
            }

            // -----------------------------------------
            // TEXT VALIDATION
            // -----------------------------------------

            if (
                messageType === "text" &&
                !message.trim()
            ) {
                return socket.emit("chatError", {
                    message:
                        "Text message cannot be empty",
                });
            }

            // -----------------------------------------
            // FILE VALIDATION
            // -----------------------------------------

            if (messageType !== "text") {
                if (!fileUrl) {
                    return socket.emit("chatError", {
                        message:
                            "fileUrl is required for file messages",
                    });
                }

                if (!fileName) {
                    return socket.emit("chatError", {
                        message:
                            "fileName is required for file messages",
                    });
                }

                const MAX_FILE_SIZE =
                    10 * 1024 * 1024;

                if (
                    fileSize &&
                    fileSize > MAX_FILE_SIZE
                ) {
                    return socket.emit("chatError", {
                        message:
                            "File size must not exceed 10 MB",
                    });
                }
            }

            // -----------------------------------------
            // CREATE MESSAGE
            // -----------------------------------------

            const chatMessage =
                await ChatMessage.create({
                    conversationId,
                    senderId: socket.user.userId,
                    senderRole: socket.user.role,
                    messageType,
                    message,
                    fileName,
                    fileUrl,
                    fileType,
                    fileSize,
                });

            // -----------------------------------------
            // UPDATE CONVERSATION
            // -----------------------------------------

            conversation.lastMessage =
                messageType === "text"
                    ? message
                    : `Sent ${messageType}`;

            conversation.lastMessageAt =
                new Date();

            await conversation.save();

            // -----------------------------------------
            // POPULATE MESSAGE
            // -----------------------------------------

            const populatedMessage =
                await ChatMessage.findById(
                    chatMessage._id
                ).populate(
                    "senderId",
                    "email phone role"
                );

            // -----------------------------------------
            // SEND MESSAGE TO CONVERSATION
            // -----------------------------------------

            io.to(
                `conversation:${conversationId}`
            ).emit(
                "newMessage",
                populatedMessage
            );

            console.log(
                `Message sent in conversation ${conversationId}`
            );
        } catch (error) {
            console.error(
                "Send message error:",
                error
            );

            socket.emit("chatError", {
                message:
                    "Failed to send message",
            });
        }
    });

    // =================================================
    // LEAVE CONVERSATION
    // =================================================

    socket.on(
        "leaveConversation",
        (conversationId) => {
            socket.leave(
                `conversation:${conversationId}`
            );

            console.log(
                `${socket.user.role} left conversation ${conversationId}`
            );
        }
    );

    // =================================================
    // DISCONNECT
    // =================================================

    socket.on("disconnect", () => {
        console.log(
            `Socket disconnected: ${socket.id}`
        );
    });
});

// =====================================================
// START SERVER
// =====================================================

const startServer = async () => {
    try {
        await connectDB();

        server.listen(PORT, () => {
            console.log(
                `MedConnect server running on port ${PORT}`
            );

            startAppointmentReminderJob();
        });
    } catch (error) {
        console.error(
            "Failed to start server:",
            error.message
        );

        process.exit(1);
    }
};

startServer();