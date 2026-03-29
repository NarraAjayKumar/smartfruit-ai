# 🚀 RENDER DEPLOYMENT HANDBOOK: SmartFruit AI

Follow these **EXACT** settings on Render.com to make your app work globally.

---

## 🟢 1. Create New Web Service
1. Go to [Render Dashboard](https://dashboard.render.com).
2. Click **"New +"** -> **"Web Service"**.
3. Connect your **GitHub Repository**.

## ⚙️ 2. Deployment Settings
| Setting | Value |
| :--- | :--- |
| **Name** | `smartfruit-backend` |
| **Root Directory** | `backend` |
| **Runtime** | `Node` |
| **Build Command** | `npm install` |
| **Start Command** | `npm start` |

## 🔐 3. Environment Variables (CRITICAL)
Click **"Advanced"** and add these:
- `MONGO_URI`: (Your MongoDB Atlas connection string)
- `JWT_SECRET`: `smartfruit_secret_2026`
- `PORT`: `5000`

## 🛰️ 4. Your Public URL
Once deployed, copy the URL at the top (e.g., `https://smartfruit-backend.onrender.com`).
**Make sure it matches exactly in `ApiConfig.dart`!**

---
**Your app is now 100% production-ready! 🚀✨🏆**
