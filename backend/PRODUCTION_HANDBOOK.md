# 🏆 FINAL PRODUCTION HANDBOOK: SmartFruit AI

Follow these exact steps to launch your app globally on **Render.com**.

---

## 🟢 1. Render.com Settings
1. **GitHub:** Connect your repository.
2. **Root Directory:** `backend`
3. **Build Command:** `npm install`
4. **Start Command:** `node server.js`
5. **Environment Variables:**
   - `MONGO_URI`: (Your MongoDB Atlas connection string)
   - `JWT_SECRET`: `smartfruit_secret_2026` (or your own)
   - `PORT`: `5000`

## 🛰️ 2. Get Your Public URL
Once Render finishes building, you will see a URL like:
`https://smartfruit-backend.onrender.com`

## 📱 3. Update Flutter
1. Open `lib/core/config/api_config.dart`.
2. Paste your URL into `productionUrl`.
3. Set `currentEnv = ApiEnv.production`.

## 🧪 4. The "Data Test"
1. **Turn OFF WiFi** on your phone.
2. Open the app.
3. If the dot on the Login screen is **GREEN**, you are globally connected!

---
**Congratulations! You have built a production-ready global application! 🚀✨🏆**
