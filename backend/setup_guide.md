# Custom Auth Setup Guide 🛡️🚀✨🏆🇮🇳🏆🕺🤴

This guide explains how to set up and run your custom Node.js + JWT authentication system for SmartFruit AI.

## 🟢 1. Backend Setup

### Prerequisites
- Node.js installed
- MongoDB installed (Local or Atlas)

### Steps
1. Open a terminal in the `backend/` directory.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure your `.env` file (already created):
   - `PORT=5000`
   - `MONGO_URI=mongodb://localhost:27017/smartfruit_ai`
   - `JWT_SECRET=your_jwt_secret_key`
4. Start the server:
   ```bash
   npm run start (if configured) OR node server.js
   ```

## 📱 2. Flutter App Setup

### Dependencies
- The app uses `http` and `shared_preferences`.
- Run:
  ```bash
  flutter pub get
  ```

### Configuration
- Base URL is set in `lib/core/constants/api_constants.dart`.
- Default for emulator: `http://10.0.2.2:5000/api/auth`.
- If using a physical device, update `10.0.2.2` to your machine's local IP address.

## 🧪 3. API Test Examples (Postman/Curl)

### Register
- **Endpoint:** `POST /api/auth/register`
- **Body:**
  ```json
  {
    "name": "Ajay Kumar",
    "email": "ajay@example.com",
    "password": "password123"
  }
  ```
- **Response (201):** Returns User ID, Name, Email, and JWT Token.

### Login
- **Endpoint:** `POST /api/auth/login`
- **Body:**
  ```json
  {
    "email": "ajay@example.com",
    "password": "password123"
  }
  ```
- **Response (200):** Returns JWT Token for session storage.

### Profile (Protected)
- **Endpoint:** `GET /api/auth/profile`
- **Headers:** `Authorization: Bearer <YOUR_JWT_TOKEN>`
- **Response (200):** Returns logged-in user details.

---

## 🏆 Summary of Changes
- ✅ **Firebase Auth Removed:** No more dependency on Google services for login.
- ✅ **Custom Backend:** Fully owned industry-standard Node.js system.
- ✅ **Secure Hashing:** Password protection via `bcryptjs`.
- ✅ **JWT persistence:** Auto-login handles session management perfectly.
