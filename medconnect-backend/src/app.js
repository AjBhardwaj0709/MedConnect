const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");

const authRoutes = require("./routes/authRoutes");

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