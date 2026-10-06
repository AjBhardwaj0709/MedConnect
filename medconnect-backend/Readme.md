# 🏥 MedConnect Backend

MedConnect is a full-stack healthcare and telemedicine platform designed to connect **patients and doctors** through a secure digital healthcare system.

The backend is built using **Node.js, Express.js, and MongoDB** and provides authentication, role-based authorization, doctor and patient profiles, and the foundation for appointment scheduling, medical records, prescriptions, communication, and telemedicine features.

> 🚧 **Project Status:** Under Active Development

---

## 📌 Project Overview

MedConnect is designed around two main applications:

### 📱 MedConnect Patient & Doctor App

A single Flutter application with role-based experiences for:

- 👤 Patients
- 👨‍⚕️ Doctors

### 🖥️ MedConnect Admin App

A separate application for:

- Doctor verification
- Patient management
- Doctor management
- Appointment management
- Platform administration

Both applications communicate with the same backend API.

```text
                    ┌─────────────────────┐
                    │    Flutter App      │
                    │ Patient + Doctor    │
                    └──────────┬──────────┘
                               │
                               │ REST API
                               ↓
                    ┌─────────────────────┐
                    │ Node.js + Express   │
                    │     Backend API     │
                    └──────────┬──────────┘
                               │
                               ↓
                    ┌─────────────────────┐
                    │      MongoDB        │
                    │      Database       │
                    └─────────────────────┘
                               ↑
                               │
                    ┌──────────┴──────────┐
                    │   Admin Application │
                    └─────────────────────┘
```

---

# 🚀 Main Features

## 🔐 Authentication

- Patient signup
- Doctor signup
- Login
- JWT authentication
- Password hashing using bcrypt
- Role-based authorization
- Current user/profile endpoint
- Duplicate email validation
- Duplicate phone validation
- Account active/inactive status

## 👤 Patient

Currently implemented:

- Patient registration
- Patient login
- Patient profile
- Patient profile update
- Emergency contact
- Blood group
- Date of birth
- Gender
- Address
- Profile image field

Planned:

- Doctor search
- Doctor filtering
- Appointment booking
- Appointment history
- Medical reports
- Prescriptions
- Chat
- Video consultation
- Notifications


## 👨‍⚕️ Doctor

Currently implemented:

- Doctor registration
- Doctor login
- JWT authentication
- Doctor profile
- Doctor profile update
- Specialization
- Qualification
- Experience
- Registration number
- Consultation fee
- Bio
- Languages
- Clinic information
- Doctor verification status

Planned:

- Admin verification
- Availability management
- Holidays/leave
- Blocked time slots
- Appointment management
- Patient information
- Prescriptions
- Chat
- Video consultation

## 🛠️ Admin

Planned:

- Admin authentication
- Doctor verification
- Approve/reject doctors
- Patient management
- Doctor management
- Appointment management
- Dashboard and analytics

---

# 🧰 Technology Stack

## Backend

- Node.js
- Express.js
- MongoDB
- Mongoose
- JWT
- bcryptjs
- Helmet
- CORS
- Express Rate Limit

## Planned Integrations

- Flutter
- Firebase Cloud Messaging (FCM)
- Razorpay
- Socket.IO
- Video consultation provider
- Cloud storage for medical documents
- Render for backend deployment
- MongoDB Atlas for production database

---

# 📂 Backend Project Structure

```text
medconnect-backend/
│
├── src/
│   │
│   ├── config/
│   │   └── db.js
│   │
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── doctorController.js
│   │   └── patientController.js
│   │
│   ├── middleware/
│   │   └── authMiddleware.js
│   │
│   ├── models/
│   │   ├── User.js
│   │   ├── Doctor.js
│   │   └── Patient.js
│   │
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── doctorRoutes.js
│   │   └── patientRoutes.js
│   │
│   └── app.js
│
├── .env
├── .gitignore
├── package.json
├── package-lock.json
└── server.js
```

---

# 🗄️ Database Design

The current backend uses three main collections.

## Users

The `users` collection contains authentication-related information.

```text
users
├── _id
├── email
├── phone
├── password
├── role
├── isActive
├── createdAt
└── updatedAt
```

Possible roles:

```text
patient
doctor
```

---

## Patients

The `patients` collection contains patient-specific information.

```text
patients
├── _id
├── userId
├── name
├── dateOfBirth
├── gender
├── address
├── bloodGroup
├── emergencyContact
├── profileImage
├── createdAt
└── updatedAt
```

The `userId` connects the patient profile with the authentication account.

---

## Doctors

The `doctors` collection contains doctor-specific information.

```text
doctors
├── _id
├── userId
├── name
├── specialization
├── qualification
├── experience
├── registrationNumber
├── consultationFee
├── bio
├── languages
├── clinicName
├── clinicAddress
├── profileImage
├── isVerified
├── createdAt
└── updatedAt
```

---

# 🔐 Authentication Architecture

MedConnect uses **JWT-based authentication**.

The authentication process is:

```text
User
  │
  ↓
Signup
  │
  ↓
Password hashed using bcrypt
  │
  ↓
User stored in MongoDB
  │
  ↓
Login
  │
  ↓
Password verification
  │
  ↓
JWT generated
  │
  ↓
Flutter stores token
  │
  ↓
Token sent with protected requests
```

Protected requests use:

```http
Authorization: Bearer <JWT_TOKEN>
```

---

# 🛡️ Role-Based Authorization

The backend uses role-based authorization.

For example:

```text
Patient
   ↓
Patient APIs

Doctor
   ↓
Doctor APIs

Admin
   ↓
Admin APIs
```

The role is included in the JWT payload.

Example:

```json
{
  "userId": "USER_ID",
  "role": "doctor"
}
```

The backend checks the role before allowing access to protected resources.

---

# 🌐 API Routes

Base URL during local development:

```text
http://localhost:5000
```

---

# 🔐 Authentication Routes

## Patient Signup

```http
POST /api/auth/patient/signup
```

### Request

```json
{
  "name": "Ajay Bhardwaj",
  "email": "ajay@example.com",
  "phone": "9876543210",
  "password": "Test@12345",
  "dateOfBirth": "2003-05-15",
  "gender": "male",
  "address": "Rohtak, Haryana"
}
```

### Response

```json
{
  "success": true,
  "message": "Patient registered successfully",
  "token": "JWT_TOKEN",
  "user": {
    "id": "USER_ID",
    "email": "ajay@example.com",
    "phone": "9876543210",
    "role": "patient"
  },
  "profile": {}
}
```

---

# 👨‍⚕️ Doctor Signup

```http
POST /api/auth/doctor/signup
```

### Request

```json
{
  "name": "Dr. Rahul Sharma",
  "email": "rahul@example.com",
  "phone": "9876543211",
  "password": "Doctor@12345",
  "specialization": "Cardiology",
  "qualification": "MBBS, MD",
  "experience": 8,
  "registrationNumber": "MED123456",
  "consultationFee": 800
}
```

A new doctor is initially created with:

```json
{
  "isVerified": false
}
```

Doctor verification will later be handled by the admin.

---

# 🔑 Login

```http
POST /api/auth/login
```

### Request

```json
{
  "email": "ajay@example.com",
  "password": "Test@12345"
}
```

### Response

```json
{
  "success": true,
  "message": "Login successful",
  "token": "JWT_TOKEN",
  "user": {
    "id": "USER_ID",
    "email": "ajay@example.com",
    "phone": "9876543210",
    "role": "patient"
  },
  "profile": {}
}
```

The same login endpoint is used for both patients and doctors.

---

# 👤 Current User

```http
GET /api/auth/me
```

### Authentication

```http
Authorization: Bearer JWT_TOKEN
```

Returns the currently authenticated user and their profile.

---

# 👨‍⚕️ Doctor Routes

## Get My Doctor Profile

```http
GET /api/doctors/profile
```

### Authorization

```text
Doctor only
```

### Header

```http
Authorization: Bearer JWT_TOKEN
```

---

## Update Doctor Profile

```http
PUT /api/doctors/profile
```

### Authorization

```text
Doctor only
```

### Request

```json
{
  "bio": "Experienced cardiologist providing personalized cardiac care.",
  "languages": [
    "English",
    "Hindi"
  ],
  "clinicName": "Heart Care Clinic",
  "clinicAddress": "Rohtak, Haryana",
  "consultationFee": 1000
}
```

---

## Get Verified Doctors

```http
GET /api/doctors
```

Returns doctors whose:

```text
isVerified = true
```

---

## Get Doctor By ID

```http
GET /api/doctors/:id
```

Returns a specific verified doctor.

Example:

```text
GET /api/doctors/64f123456789
```

---

# 👤 Patient Routes

## Get My Patient Profile

```http
GET /api/patients/profile
```

### Authorization

```text
Patient only
```

### Header

```http
Authorization: Bearer JWT_TOKEN
```

---

## Update Patient Profile

```http
PUT /api/patients/profile
```

### Authorization

```text
Patient only
```

### Request

```json
{
  "name": "Ajay Bhardwaj",
  "dateOfBirth": "2003-05-15",
  "gender": "male",
  "address": "Rohtak, Haryana",
  "bloodGroup": "B+",
  "emergencyContact": {
    "name": "Father",
    "phone": "9876543212",
    "relationship": "Father"
  }
}
```

---

# 🔒 Security

The backend currently includes:

### Password hashing

Passwords are never stored as plain text.

```text
Plain Password
      ↓
bcrypt
      ↓
Password Hash
      ↓
MongoDB
```

### JWT Authentication

Protected endpoints require a valid JWT.

### Role Authorization

Patients cannot access doctor-only APIs.

Doctors cannot access patient-only APIs.

### Helmet

HTTP security headers are configured using Helmet.

### Rate Limiting

Authentication routes are protected with request rate limiting.

### Environment Variables

Sensitive configuration such as:

```text
MONGO_URI
JWT_SECRET
```

is stored in `.env`.

`.env` is excluded from Git using `.gitignore`.

---

# 🧪 API Testing

The backend APIs can be tested using:

- Postman
- Insomnia
- Thunder Client
- Flutter application

Recommended testing order:

```text
1. Patient Signup
2. Doctor Signup
3. Patient Login
4. Doctor Login
5. Get Patient Profile
6. Update Patient Profile
7. Get Doctor Profile
8. Update Doctor Profile
9. Test JWT protection
10. Test role authorization
```

---

# 📊 Current Development Status

| Feature | Status |
|---|---|
| Authentication | ✅ |
| Patient Signup | ✅ |
| Doctor Signup | ✅ |
| Login | ✅ |
| JWT | ✅ |
| Role Authorization | ✅ |
| Doctor Profile | ✅ |
| Doctor Profile Update | ✅ |
| Patient Profile | ✅ |
| Patient Profile Update | ✅ |
| Doctor Verification | ⏳ |
| Doctor Availability | ⏳ |
| Doctor Holidays / Leave | ⏳ |
| Blocked Time Slots | ⏳ |
| Appointment System | ⏳ |
| Appointment Conflict Check | ⏳ |
| Appointment Cancellation | ⏳ |
| Appointment Rescheduling | ⏳ |
| Medical Reports | ⏳ |
| Prescriptions | ⏳ |
| Chat | ⏳ |
| Video Consultation | ⏳ |
| Notifications | ⏳ |

---

# 🗺️ Development Roadmap

The planned development order is:

```text
Authentication
      ↓
Doctor Profile
      ↓
Patient Profile
      ↓
Doctor Verification
      ↓
Doctor Availability
      ↓
Doctor Holidays / Leave
      ↓
Blocked Time Slots
      ↓
Appointment System
      ↓
Appointment Conflict Prevention
      ↓
Appointment Cancellation
      ↓
Appointment Rescheduling
      ↓
Medical Reports
      ↓
Prescriptions
      ↓
Chat
      ↓
Video Consultation
      ↓
Notifications
      ↓
Admin Dashboard
      ↓
Testing & Security
      ↓
Deployment
```

---

# ⚙️ Local Setup

## 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
```

## 2. Open the project

```bash
cd medconnect-backend
```

## 3. Install dependencies

```bash
npm install
```

## 4. Create `.env`

```env
PORT=5000

MONGO_URI=mongodb://127.0.0.1:27017/medconnect

JWT_SECRET=your_secret_key

JWT_EXPIRES_IN=7d

NODE_ENV=development
```

## 5. Start development server

```bash
npm run dev
```

## 6. Start production server

```bash
npm start
```

---

# 🧪 Health Check

After starting the server:

```http
GET /
```

Expected response:

```json
{
  "success": true,
  "message": "MedConnect API is running"
}
```

---

# 📱 Planned Flutter Integration

The Flutter application will communicate with this backend through REST APIs.

Example:

```text
Flutter
   │
   │ HTTP
   ↓
Express API
   │
   ↓
Controller
   │
   ↓
Mongoose
   │
   ↓
MongoDB
```

The Flutter application will send the JWT with protected requests:

```http
Authorization: Bearer JWT_TOKEN
```

---

# 🚀 Deployment Plan

The backend is currently developed and tested locally.

For the portfolio deployment, the planned infrastructure is:

```text
Flutter Application
        │
        ↓
Deployed Node.js API
        │
        ↓
MongoDB Atlas
```

Planned hosting:

- Backend → Render
- Database → MongoDB Atlas
- Source Code → GitHub

Additional services will be added as required for:

- File storage
- Push notifications
- Video consultation
- Real-time communication

---

# 🎯 Project Goal

The goal of MedConnect is to build a production-style healthcare platform demonstrating:

- Flutter development
- REST API development
- Backend architecture
- MongoDB database design
- JWT authentication
- Role-based authorization
- Appointment scheduling
- Real-time communication
- Healthcare document management
- Telemedicine
- Cloud deployment

This project is being developed as a **portfolio/full-stack project** to demonstrate practical software engineering skills.

---

# 👨‍💻 Author

**Ajay Bhardwaj**

Flutter Developer | Full-Stack Developer

---

## 📌 Note

MedConnect is currently a development/portfolio project and should not be used to process real patient medical information or real healthcare transactions until appropriate security, privacy, compliance, infrastructure, and operational requirements have been implemented.