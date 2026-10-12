
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

const User = require("../models/User");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");
const { sendEmail } = require("../utils/emailService");

const hashToken = (token) =>
    crypto.createHash("sha256").update(token).digest("hex");

const createToken = () => crypto.randomBytes(32).toString("hex");

const generateToken = (user) => {
    return jwt.sign(
        {
            userId: user._id.toString(),
            role: user.role,
        },
        process.env.JWT_SECRET,
        {
            expiresIn: process.env.JWT_EXPIRES_IN || "7d",
        }
    );
};

const sendVerificationEmail = async (user) => {
    const token = createToken();

    user.emailVerificationTokenHash = hashToken(token);
    user.emailVerificationExpires = new Date(Date.now() + 30 * 60 * 1000);
    await user.save();

    const baseUrl = process.env.API_BASE_URL;
    if (!baseUrl) throw new Error("API_BASE_URL is not configured");

    const verificationUrl =
        `${baseUrl}/api/auth/verify-email?token=${token}`;

    await sendEmail({
        to: user.email,
        subject: "Verify your MedConnect email",
        html: `
      <h2>Welcome to MedConnect</h2>
      <p>Please verify your email address to activate your account.</p>
      <p>
        <a href="${verificationUrl}">Verify my email</a>
      </p>
      <p>This link expires in 30 minutes and can only be used once.</p>
      <p>If you did not create this account, you can ignore this email.</p>
    `,
    });
};

const createAccount = async (req, res, role) => {
    let user;

    try {
        const {
            name,
            email,
            password,
            dateOfBirth,
            gender,
            address,
            specialization,
            qualification,
            experience,
            registrationNumber,
            consultationFee,
        } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: "Name, email and password are required",
            });
        }

        if (typeof email !== "string" || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
            return res.status(400).json({
                success: false,
                message: "Please provide a valid email address",
            });
        }

        if (typeof password !== "string" || password.length < 8) {
            return res.status(400).json({
                success: false,
                message: "Password must contain at least 8 characters",
            });
        }

        if (
            role === "doctor" &&
            (!specialization || !qualification || !registrationNumber)
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Specialization, qualification and registration number are required",
            });
        }

        const normalizedEmail = email.trim().toLowerCase();

        const existingUser = await User.findOne({ email: normalizedEmail });

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: "Email is already registered",
            });
        }

        if (role === "doctor") {
            const existingRegistration = await Doctor.findOne({
                registrationNumber: registrationNumber.trim(),
            });

            if (existingRegistration) {
                return res.status(409).json({
                    success: false,
                    message: "Doctor registration number already exists",
                });
            }
        }

        const hashedPassword = await bcrypt.hash(password, 12);

        user = await User.create({
            email: normalizedEmail,
            password: hashedPassword,
            role,
            isEmailVerified: false,
        });

        let profile;

        if (role === "patient") {
            profile = await Patient.create({
                userId: user._id,
                name,
                dateOfBirth,
                gender,
                address,
            });
        } else {
            profile = await Doctor.create({
                userId: user._id,
                name,
                specialization,
                qualification,
                experience: experience || 0,
                registrationNumber: registrationNumber.trim(),
                consultationFee: consultationFee || 0,
                isVerified: false,
                verificationStatus: "pending",
            });
        }

        let emailSent = true;

        try {
            await sendVerificationEmail(user);
        } catch (emailError) {
            emailSent = false;
            console.error("Verification email failed:", emailError.message);
        }

        return res.status(201).json({
            success: true,
            emailSent,
            message: emailSent
                ? "Account created. Please check your email to verify your account."
                : "Account created, but the verification email could not be sent. Request a new verification email.",
            user: {
                id: user._id,
                email: user.email,
                role: user.role,
                isEmailVerified: user.isEmailVerified,
            },
            profile,
        });
    } catch (error) {
        console.error(`${role} signup error:`, error);

        // Avoid leaving an orphaned user if profile creation failed.
        // Do not delete a successfully created account just because email
        // delivery failed; the user can request another verification email.
        if (user) {
            const profileExists =
                role === "patient"
                    ? await Patient.exists({ userId: user._id }).catch(() => true)
                    : await Doctor.exists({ userId: user._id }).catch(() => true);

            if (!profileExists) {
                await User.deleteOne({ _id: user._id }).catch(() => { });
            }
        }

        if (error.code === 11000) {
            return res.status(409).json({
                success: false,
                message: "Email or registration number is already registered",
            });
        }

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};

const patientSignup = (req, res) => createAccount(req, res, "patient");
const doctorSignup = (req, res) => createAccount(req, res, "doctor");

// Verify the email link
const verifyEmail = async (req, res) => {
    try {
        const { token } = req.query;

        if (typeof token !== "string" || !token) {
            return res.status(400).json({
                success: false,
                message: "Verification token is required",
            });
        }

        const user = await User.findOne({
            emailVerificationTokenHash: hashToken(token),
            emailVerificationExpires: { $gt: new Date() },
        }).select("+emailVerificationTokenHash +emailVerificationExpires");

        if (!user) {
            return res.status(400).json({
                success: false,
                message: "Verification link is invalid or has expired",
            });
        }

        user.isEmailVerified = true;
        user.emailVerificationTokenHash = undefined;
        user.emailVerificationExpires = undefined;
        await user.save();

        return res.status(200).json({
            success: true,
            message: "Email verified successfully. You can now log in.",
        });
    } catch (error) {
        console.error("Email verification error:", error);
        return res.status(500).json({
            success: false,
            message: "Unable to verify email",
        });
    }
};

// Resend verification email
const resendVerificationEmail = async (req, res) => {
    try {
        const email =
            typeof req.body.email === "string"
                ? req.body.email.trim().toLowerCase()
                : "";

        if (!email) {
            return res.status(400).json({
                success: false,
                message: "Email is required",
            });
        }

        const user = await User.findOne({ email });

        // Use the same public response for unknown, verified and known
        // accounts to reduce email-account enumeration.
        const genericMessage =
            "If the account exists and needs verification, an email will be sent.";

        if (!user || user.isEmailVerified) {
            return res.status(200).json({
                success: true,
                message: genericMessage,
            });
        }

        try {
            await sendVerificationEmail(user);
        } catch (error) {
            console.error("Resend verification failed:", error.message);
        }

        return res.status(200).json({
            success: true,
            message: genericMessage,
        });
    } catch (error) {
        console.error("Resend verification error:", error);
        return res.status(500).json({
            success: false,
            message: "Unable to process the request",
        });
    }
};

// Forgot password: email a one-time reset link
const forgotPassword = async (req, res) => {
    try {
        const email =
            typeof req.body.email === "string"
                ? req.body.email.trim().toLowerCase()
                : "";

        if (!email) {
            return res.status(400).json({
                success: false,
                message: "Email is required",
            });
        }

        const genericMessage =
            "If an eligible account exists, password reset instructions will be sent.";

        const user = await User.findOne({
            email,
            isActive: true,
        });

        if (!user) {
            return res.status(200).json({
                success: true,
                message: genericMessage,
            });
        }

        const token = createToken();

        user.passwordResetTokenHash = hashToken(token);
        user.passwordResetExpires = new Date(Date.now() + 15 * 60 * 1000);
        await user.save();

        const resetBaseUrl = process.env.FRONTEND_RESET_URL;

        if (!resetBaseUrl) {
            throw new Error("FRONTEND_RESET_URL is not configured");
        }

        const separator = resetBaseUrl.includes("?") ? "&" : "?";
        const resetUrl =
            `${resetBaseUrl}${separator}token=${encodeURIComponent(token)}`;

        try {
            await sendEmail({
                to: user.email,
                subject: "Reset your MedConnect password",
                html: `
          <h2>Password reset</h2>
          <p>We received a request to reset your MedConnect password.</p>
          <p><a href="${resetUrl}">Reset my password</a></p>
          <p>This link expires in 15 minutes and can only be used once.</p>
          <p>If you did not request this, you can ignore this email.</p>
        `,
            });
        } catch (emailError) {
            user.passwordResetTokenHash = undefined;
            user.passwordResetExpires = undefined;
            await user.save();
            throw emailError;
        }

        return res.status(200).json({
            success: true,
            message: genericMessage,
        });
    } catch (error) {
        console.error("Forgot password error:", error);
        return res.status(500).json({
            success: false,
            message: "Unable to process password reset request",
        });
    }
};

// Reset password using the emailed token
const resetPassword = async (req, res) => {
    try {
        const { token, newPassword } = req.body;

        if (
            typeof token !== "string" ||
            !token ||
            typeof newPassword !== "string" ||
            newPassword.length < 8
        ) {
            return res.status(400).json({
                success: false,
                message: "A valid token and password of at least 8 characters are required",
            });
        }

        const user = await User.findOne({
            passwordResetTokenHash: hashToken(token),
            passwordResetExpires: { $gt: new Date() },
            isActive: true,
        }).select("+passwordResetTokenHash +passwordResetExpires +password");

        if (!user) {
            return res.status(400).json({
                success: false,
                message: "Password reset link is invalid or has expired",
            });
        }

        user.password = await bcrypt.hash(newPassword, 12);
        user.passwordResetTokenHash = undefined;
        user.passwordResetExpires = undefined;
        await user.save();

        return res.status(200).json({
            success: true,
            message: "Password reset successfully. Please log in with your new password.",
        });
    } catch (error) {
        console.error("Reset password error:", error);
        return res.status(500).json({
            success: false,
            message: "Unable to reset password",
        });
    }
};

// Login
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (typeof email !== "string" || !password) {
            return res.status(400).json({
                success: false,
                message: "Email and password are required",
            });
        }

        const user = await User.findOne({
            email: email.trim().toLowerCase(),
        }).select("+password");

        if (!user) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password",
            });
        }

        if (!user.isActive) {
            return res.status(403).json({
                success: false,
                message: "Your account has been disabled",
            });
        }

        const passwordMatch = await bcrypt.compare(password, user.password);

        if (!passwordMatch) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password",
            });
        }

        // Public patient/doctor signup requires email verification.
        // Existing admin accounts are not blocked by this new field.
        if (user.role !== "admin" && !user.isEmailVerified) {
            return res.status(403).json({
                success: false,
                code: "EMAIL_NOT_VERIFIED",
                message: "Please verify your email before logging in.",
            });
        }

        let profile = null;

        if (user.role === "patient") {
            profile = await Patient.findOne({ userId: user._id });
        } else if (user.role === "doctor") {
            profile = await Doctor.findOne({ userId: user._id });
        }

        const token = generateToken(user);

        return res.status(200).json({
            success: true,
            message: "Login successful",
            token,
            user: {
                id: user._id,
                email: user.email,
                role: user.role,
                isEmailVerified: user.isEmailVerified,
            },
            profile,
        });
    } catch (error) {
        console.error("Login error:", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};

// Get current user
const getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found",
            });
        }

        let profile = null;

        if (user.role === "patient") {
            profile = await Patient.findOne({ userId: user._id });
        } else if (user.role === "doctor") {
            profile = await Doctor.findOne({ userId: user._id });
        }

        return res.status(200).json({
            success: true,
            user: {
                id: user._id,
                email: user.email,
                role: user.role,
                isActive: user.isActive,
                isEmailVerified: user.isEmailVerified,
            },
            profile,
        });
    } catch (error) {
        console.error("Get me error:", error);
        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};

module.exports = {
    patientSignup,
    doctorSignup,
    login,
    getMe,
    verifyEmail,
    resendVerificationEmail,
    forgotPassword,
    resetPassword,
};
