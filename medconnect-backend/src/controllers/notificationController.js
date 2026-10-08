const Notification = require("../models/Notification");

// Get logged-in user's notifications
const getMyNotifications = async (req, res) => {
    try {
        const notifications = await Notification.find({
            userId: req.user.userId,
        }).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: notifications.length,
            notifications,
        });
    } catch (error) {
        console.error("Get notifications error:", error);

        res.status(500).json({
            success: false,
            message: "Failed to fetch notifications",
        });
    }
};

// Get unread notification count
const getUnreadCount = async (req, res) => {
    try {
        const count = await Notification.countDocuments({
            userId: req.user.userId,
            isRead: false,
        });

        res.status(200).json({
            success: true,
            count,
        });
    } catch (error) {
        console.error("Get unread count error:", error);

        res.status(500).json({
            success: false,
            message: "Failed to fetch unread notification count",
        });
    }
};

// Mark one notification as read
const markAsRead = async (req, res) => {
    try {
        const { id } = req.params;

        const notification = await Notification.findOne({
            _id: id,
            userId: req.user.userId,
        });

        if (!notification) {
            return res.status(404).json({
                success: false,
                message: "Notification not found",
            });
        }

        notification.isRead = true;

        await notification.save();

        res.status(200).json({
            success: true,
            message: "Notification marked as read",
            notification,
        });
    } catch (error) {
        console.error("Mark notification as read error:", error);

        res.status(500).json({
            success: false,
            message: "Failed to mark notification as read",
        });
    }
};

// Mark all notifications as read
const markAllAsRead = async (req, res) => {
    try {
        await Notification.updateMany(
            {
                userId: req.user.userId,
                isRead: false,
            },
            {
                $set: {
                    isRead: true,
                },
            }
        );

        res.status(200).json({
            success: true,
            message: "All notifications marked as read",
        });
    } catch (error) {
        console.error("Mark all notifications as read error:", error);

        res.status(500).json({
            success: false,
            message: "Failed to mark all notifications as read",
        });
    }
};

module.exports = {
    getMyNotifications,
    getUnreadCount,
    markAsRead,
    markAllAsRead,
};