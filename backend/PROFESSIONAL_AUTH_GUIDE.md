# Professional Auth Setup Guide 🛡️🚀✨

This guide covers the setup for the premium **Email + Phone/OTP** authentication system.

## 🟢 1. Backend Setup

1. **Install Dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Environment Variables (.env):**
   Ensure your `.env` contains:
   ```env
   PORT=5000
   MONGO_URI=your_mongodb_atlas_uri
   JWT_SECRET=your_jwt_secret_key
   ```

3. **Start the Server:**
   ```bash
   node server.js
   ```

## 🔵 2. Flutter Configuration (CRITICAL for Timeout Fix)

1. Open `lib/core/config/api_config.dart`.
2. **For Android Emulator:** 
   - Set `isRealDevice = false`. 
   - Uses `10.0.2.2`.
3. **For Physical Device:**
   - Set `isRealDevice = true`.
   - Update `physicalDeviceIp` to your laptop's Local IP (e.g., `192.168.1.XX`).
   - Run: `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find it.

## 🧪 3. Authentication Flow
- **Email Login:** Standard email/password.
- **Phone Login:** Enter phone -> Receive **123456** (Mock) -> Enter in OTP screen.
- **Signup:** Full validation with Confirm Password and Visibility Toggles.

---
**Build Success! 🚀✨🏆**
