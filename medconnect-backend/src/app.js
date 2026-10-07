const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");

const authRoutes = require("./routes/authRoutes");
const doctorRoutes=require("./routes/doctorRoutes")
const patientRoutes=require("./routes/patientsRoutes");
const adminRoutes = require("./routes/adminRoutes");
const availabilityRoutes = require("./routes/availabilityRoutes");
const leaveRoutes = require("./routes/leaveRoutes");
const blockedTimeSlotRoutes = require("./routes/blockedTimeSlotRoutes");
const app = express();
app.use(express.json());


// Security
app.use(helmet());


// CORS
app.use(
  cors({
    origin: "*",
  })
);


// JSON
app.use(express.json());


// Rate limiting
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: {
    success: false,
    message: "Too many requests. Please try again later.",
  },
});


// Health check
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "MedConnect API is running",
  });
});


// Auth routes
app.use("/api/auth", authLimiter, authRoutes);
// doctor Avalibility routes 
app.use(
  "/api/doctors/availability",
  availabilityRoutes
);
// doctor Leave routes
app.use(
  "/api/doctors/leave",
  leaveRoutes
);
// doctor blocked time slots 
app.use(
  "/api/doctors/blocked-slots",
  blockedTimeSlotRoutes
);
// doctor routes 
app.use("/api/doctors", doctorRoutes);

//patient routes
app.use("/api/patients",patientRoutes)

// admin routes 
app.use("/api/admin", adminRoutes);




// 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  });
});


// Error handler
app.use((err, req, res, next) => {
  console.error(err);

  res.status(500).json({
    success: false,
    message: "Internal server error",
  });
});




module.exports = app;