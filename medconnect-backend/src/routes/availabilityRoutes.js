const express = require("express");

const {
    createAvailability,
    getAvailability,
    updateAvailability,
    deleteAvailability,
} = require("../controllers/availabilityController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();

router.use(protect, authorize("doctor"));

router.post("/", createAvailability);
router.get("/", getAvailability);
router.put("/:id", updateAvailability);
router.delete("/:id", deleteAvailability);

module.exports = router;