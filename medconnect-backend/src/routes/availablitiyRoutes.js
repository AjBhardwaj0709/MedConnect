const express = require("express");

const {
    createAvailability,
    getMyAvailability,
    updateAvailability,
    deleteAvailability,
} = require("../controllers/availabilityController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();


// All routes require doctor authentication
router.use(
    protect,
    authorize("doctor")
);


// Create availability
router.post(
    "/",
    createAvailability
);


// Get my availability
router.get(
    "/",
    getMyAvailability
);


// Update availability
router.put(
    "/:id",
    updateAvailability
);


// Delete availability
router.delete(
    "/:id",
    deleteAvailability
);


module.exports = router;