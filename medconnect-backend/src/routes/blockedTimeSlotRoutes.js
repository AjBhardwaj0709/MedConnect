const express = require("express");

const {
    createBlockedTimeSlot,
    getBlockedTimeSlots,
    updateBlockedTimeSlot,
    deleteBlockedTimeSlot,
} = require("../controllers/blockedTimeSlotController");

const { protect, authorize } = require("../middleware/authMiddleware");

const router = express.Router();

router.use(protect, authorize("doctor"));

router.post("/", createBlockedTimeSlot);

router.get("/", getBlockedTimeSlots);

router.put("/:id", updateBlockedTimeSlot);

router.delete("/:id", deleteBlockedTimeSlot);

module.exports = router;