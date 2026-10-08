require("dotenv").config();
const { io } = require("socket.io-client");

// =====================================================
// CHANGE THESE VALUES
// =====================================================



const TOKEN = "YOUR_PATIENT_JWT_TOKEN";
const CONVERSATION_ID = "YOUR_CONVERSATION_ID";

// =====================================================
// CONNECT TO SOCKET.IO
// =====================================================

const socket = io(process.env.SOCKET_SERVER_URL, {
    transports: ["websocket"],
    auth: {
        token: TOKEN,
    },
});

// =====================================================
// CONNECTED
// =====================================================

socket.on("connect", () => {
    console.log("Connected to Socket.IO");
    console.log("Socket ID:", socket.id);

    // Join conversation
    socket.emit(
        "joinConversation",
        CONVERSATION_ID
    );
});

// =====================================================
// CONVERSATION JOINED
// =====================================================

socket.on(
    "conversationJoined",
    (data) => {
        console.log(
            "Conversation joined:",
            data
        );

        // Send test message
        socket.emit("sendMessage", {
            conversationId: CONVERSATION_ID,

            messageType: "pdf",

            message:
                "Doctor, please check my resume/report.",

            fileName:
                "Ajay_flutter_developer_resume.pdf",

            fileUrl:
                "https://res.cloudinary.com/davo1ciyd/raw/upload/v1791470616/medconnect/chat/file_tqe2tk",

            fileType:
                "application/pdf",

            fileSize: 210401,
        });
    }
);

// =====================================================
// NEW MESSAGE
// =====================================================

socket.on(
    "newMessage",
    (message) => {
        console.log(
            "\n===== NEW MESSAGE ====="
        );

        console.log(
            JSON.stringify(
                message,
                null,
                2
            )
        );

        console.log(
            "=======================\n"
        );
    }
);

// =====================================================
// CHAT ERROR
// =====================================================

socket.on(
    "chatError",
    (error) => {
        console.error(
            "Chat error:",
            error
        );
    }
);

// =====================================================
// CONNECTION ERROR
// =====================================================

socket.on(
    "connect_error",
    (error) => {
        console.error(
            "Socket connection error:",
            error.message
        );
    }
);

// =====================================================
// DISCONNECT
// =====================================================

socket.on(
    "disconnect",
    (reason) => {
        console.log(
            "Disconnected:",
            reason
        );
    }
);