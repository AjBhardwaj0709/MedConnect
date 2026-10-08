require("dotenv").config();
const { io } = require("socket.io-client");

// =====================================================
// CHANGE THESE VALUES
// =====================================================


const TOKEN = "YOUR_DOCTOR_JWT_TOKEN";
const CONVERSATION_ID = "YOUR_CONVERSATION_ID";

// =====================================================
// CONNECT
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
    console.log("Doctor connected to Socket.IO");
    console.log("Socket ID:", socket.id);

    socket.emit(
        "joinConversation",
        CONVERSATION_ID
    );
});

// =====================================================
// JOINED
// =====================================================

socket.on(
    "conversationJoined",
    (data) => {
        console.log(
            "Doctor joined conversation:",
            data
        );

        // Send reply to patient
        socket.emit("sendMessage", {
            conversationId:
                CONVERSATION_ID,

            messageType: "text",

            message:
                "Hello Patient, I received your message.",
        });
    }
);

// =====================================================
// RECEIVE MESSAGE
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
            "Doctor disconnected:",
            reason
        );
    }
);