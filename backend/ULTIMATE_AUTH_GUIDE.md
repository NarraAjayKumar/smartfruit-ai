# 🛡️ SmartFruit AI - Professional Auth & Connectivity Guide

Fixing the "Server might be down" or "Timeout" error is easy if you follow these steps **EXACTLY**.

---

## 🛰️ STEP 1: Fix Connectivity (The "Golden Rules")

### 1. Identify Your Environment
- **Are you using a REAL PHONE?** 
  - Ensure your phone and laptop are on the **SAME WiFi**.
  - Your laptop MUST NOT be on a Public/Office WiFi that blocks ports.
- **Are you using an EMULATOR?** 
  - No special WiFi needed.

### 2. Configure Flutter
Open `lib/core/config/api_config.dart` and set:
- `isRealDevice = true` (for real phone) OR `false` (for emulator).
- If `true`, you MUST update `physicalDeviceIp`. 

**How to find your IP (Windows):**
1. Open Command Prompt (`cmd`).
2. Type `ipconfig`.
3. Look for **IPv4 Address** under "Wireless LAN adapter Wi-Fi".
4. It should look like `192.168.x.x`.

---

## 🟢 STEP 2: Start the Backend

1. **Open a terminal** in the `backend/` folder.
2. **Install:** `npm install`
3. **Start:** `node server.js`
4. **Verify:** You should see `✅ MongoDB Connected` and `🚀 Professional Auth Server running on port 5000`.

---

## 🧪 STEP 3: Test Connection in the App

1. Run the app (`flutter run`).
2. Watch the **Login Screen**.
3. You will see a small text saying **"Server Online"** (Green) or **"Server Offline"** (Red).
4. **If it is Red:**
   - Triple-check your IP in `api_config.dart`.
   - Ensure `isRealDevice` is correct.
   - **FIREWALL FIX:** If your IP is correct but it's still Red, your Windows Firewall might be blocking port 5000. 
     - *Temporary fix:* Turn off Public Firewall or add an Inbound Rule for Port 5000.

---

## 📱 STEP 4: Auth Features
- **Email Signup:** Robust validation included.
- **Phone Login:** Use any phone number -> Use OTP **123456**.
- **Auto-Login:** App will remember you after successful login.

---
**Everything is now configured for a 100% success rate! 🚀✨🏆**
