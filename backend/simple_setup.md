# SmartFruit AI - Simple Auth Setup Guide 🏮🚀✨

This guide will help you set up the simple Node.js + MongoDB + Flutter authentication system.

## 🟢 1. Backend Setup

1. **Install Dependencies:**
   Open your terminal in the `backend/` folder and run:
   ```bash
   npm install
   ```

2. **Configure Environment Variables:**
   Create a `.env` file in the `backend/` folder (it's already there) and ensure it has:
   ```env
   PORT=5000
   MONGO_URI=your_mongodb_atlas_connection_string
   JWT_SECRET=your_super_secret_key_123
   ```

3. **Start the Server:**
   ```bash
   node server.js
   ```

## 🔵 2. Flutter Setup

1. **API Configuration:**
   Open `lib/core/services/custom_auth_service.dart` and ensure `baseUrl` is correct:
   - For **Android Emulator**: `http://10.0.2.2:5000/api`
   - For **Physical Device**: Use your laptop's IP address (e.g., `http://192.168.1.5:5000/api`)

2. **Run the App:**
   ```bash
   flutter run
   ```

## 🛠️ Features Included
- **Register:** New user creation with password hashing.
- **Login:** Secure JWT-based authentication.
- **Auto-Login:** App remembers your session using SharedPreferences.
- **Logout:** Clears session and returns to login screen.

---
**Happy Coding! 🚀✨🏆**
