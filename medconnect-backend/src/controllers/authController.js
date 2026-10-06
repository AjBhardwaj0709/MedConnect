const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")
const User = require("../models/User")
const Patient = require("../models/Patient")
const Doctor = require("../models/Doctor")

// Generate JWT Token 
const generateToken = (user) => {
    return jwt.sign({
        userId: user._id.toString(),
        role: user.role,

    },
        process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN || "7d"
    }
    );
};

// Patient Sign up

const patientSignup= async (req, res)=>{
    try{
        const {
            name,
            email,
            password,
            dateOfBirth,
            gender,
            address,
        }= req.body;


        // validations 

        if(!name|| !email|| !password){
            return res.status(400).json({
                success: false,
                message: "Name, email and password are required",
            })
        }
        if (password.length < 8) {
            return res.status(400).json({
                success: false,
                message: "Password must contain at least 8 characters",
            });
        }

        // check mail 

        const existingEmail=await User.findOne({
            email:email.toLowerCase()

        });
        if(existingEmail){
            return res.status(409).json({
                success: false,
                message: "Email is already registered",
            })
        }
        // Hash password
        const hashedPassword = await bcrypt.hash(password, 12);

        // Create user
        const user = await User.create({
            email: email.toLowerCase(),
            
            password: hashedPassword,
            role: "patient",
        });
        const patient = await Patient.create({
            userId: user._id,
            name,
            dateOfBirth,
            gender,
            address,
        });

        // Generate token    
        const token = generateToken(user);

        return res.status(201).json({
            success: true,
            message: "Patient registered successfully",
            token,
            user: {
                id: user._id,
                email: user.email,
          
                role: user.role,
            },
            profile: patient,
        });
    } catch (error) {
        console.error("Patient signup error:", error);

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// =========================
// DOCTOR SIGNUP
// =========================

const doctorSignup = async (req, res) => {
    try {
        const {
            name,
            email,
        
            password,
            specialization,
            qualification,
            experience,
            registrationNumber,
            consultationFee,
        } = req.body;

        // Required fields
        if (
            !name ||
            !email ||
           
            !password ||
            !specialization ||
            !qualification ||
            !registrationNumber
        ) {
            return res.status(400).json({
                success: false,
                message: "Please provide all required fields",
            });
        }

        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: "Password must contain at least 6 characters",
            });
        }

        // Email check
        const existingEmail = await User.findOne({
            email: email.toLowerCase(),
        });

        if (existingEmail) {
            return res.status(409).json({
                success: false,
                message: "Email is already registered",
            });
        }

      

      

        // Registration number check
        const existingRegistration = await Doctor.findOne({
            registrationNumber,
        });

        if (existingRegistration) {
            return res.status(409).json({
                success: false,
                message: "Doctor registration number already exists",
            });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 12);

        // Create user
        const user = await User.create({
            email: email.toLowerCase(),
           
            password: hashedPassword,
            role: "doctor",
        });

        // Create doctor profile
        const doctor = await Doctor.create({
            userId: user._id,
            name,
            specialization,
            qualification,
            experience: experience || 0,
            registrationNumber,
            consultationFee: consultationFee || 0,
            isVerified: false,
            verificationStatus: "pending",
        });

        // Generate token
        const token = generateToken(user);

        return res.status(201).json({
            success: true,
            message:
                "Doctor registered successfully. Waiting for admin verification.",
            token,
            user: {
                id: user._id,
                email: user.email,
               
                role: user.role,
            },
            profile: doctor,
        });
    } catch (error) {
        console.error("Doctor signup error:", error);

        return res.status(500).json({
            success: false,
            message: "Something went wrong",
        });
    }
};


// =========================
// LOGIN
// =========================

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: "Email and password are required",
            });
        }

        // Explicitly select password because select:false
        const user = await User.findOne({
            email: email.toLowerCase(),
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

        // Compare password
        const passwordMatch = await bcrypt.compare(
            password,
            user.password
        );

        if (!passwordMatch) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password",
            });
        }

        // Doctor verification check
        let profile = null;

        if (user.role === "patient") {
            profile = await Patient.findOne({
                userId: user._id,
            });
        }

        if (user.role === "doctor") {
            profile = await Doctor.findOne({
                userId: user._id,
            });
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


// =========================
// GET CURRENT USER
// =========================

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
            profile = await Patient.findOne({
                userId: user._id,
            });
        }

        if (user.role === "doctor") {
            profile = await Doctor.findOne({
                userId: user._id,
            });
        }

        return res.status(200).json({
            success: true,
            user: {
                id: user._id,
                email: user.email,
             
                role: user.role,
                isActive: user.isActive,
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
};
