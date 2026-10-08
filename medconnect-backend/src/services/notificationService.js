const Notification = require("../models/Notification");

const createNotification = async ({
    userId,
    type,
    title,
    message,
    data = {},
}) => {
    try {
        const notification = await Notification.create({
            userId,
            type,
            title,
            message,
            data,
        });

        return notification;
    } catch (error) {
        console.error("Create notification error:", error);
        return null;
    }
};

module.exports = {
    createNotification,
};