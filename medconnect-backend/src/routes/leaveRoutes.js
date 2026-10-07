const express = require("express");

const {
    createLeave,
    getMyLeaves,
    updateLeave,
    deleteLeave,
} = require("../controllers/leaveController");

const {
    protect,
    authorize,
} = require("../middleware/authMiddleware");

const router = express.Router();


// All leave routes require doctor authentication
router.use(
    protect,
    authorize("doctor")
);


// Create leave
router.post(
    "/",
    createLeave
);


// Get my leaves
router.get(
    "/",
    getMyLeaves
);


// Update leave
router.put(
    "/:id",
    updateLeave
);


// Delete leave
router.delete(
    "/:id",
    deleteLeave
);


module.exports = router;