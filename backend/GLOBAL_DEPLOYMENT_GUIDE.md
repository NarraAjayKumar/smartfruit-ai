# 🌎 SmartFruit AI - Global Deployment Guide

To make your app work from **ANYWHERE** (mobile data, different WiFi), follow this professional deployment guide to put your backend in the cloud.

---

## 🚀 STEP 1: Push Backend to GitHub

1. **Wait!** I have already updated your `package.json` with a `start` script.
2. Ensure you have a `.gitignore` in your root or `backend/` folder that excludes `node_modules`.
3. **Commit** and **Push** your code to your GitHub repository.

---

## 🟢 STEP 2: Deploy to Render (Recommended)

Render is the easiest "Always-On" free cloud for Node.js.

1. Go to [Render.com](https://render.com) and create a free account.
2. Click **"New"** -> **"Web Service"**.
3. Connect your **GitHub Repo**.
4. Configure these settings:
   - **Name:** `smartfruit-backend`
   - **Root Directory:** `backend` (CRITICAL!)
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
5. **Environment Variables:**
   - Click "Advanced" -> "Add Environment Variable".
   - `MONGO_URI`: (Your MongoDB Atlas Connection String)
   - `JWT_SECRET`: (Your secret key)
   - `PORT`: 5000
6. Click **"Create Web Service"**.

---

## 🛰️ STEP 3: Update Flutter

1. Once deployed, Render will give you a URL (e.g., `https://smartfruit-backend.onrender.com`).
2. Open `lib/core/config/api_config.dart`.
3. Update `productionUrl` with your new Render URL.
4. Set `currentEnv = ApiEnv.production`.

---

## 🧪 STEP 4: Global Verification

1. **Rebuild your app** (or use the APK I will provide).
2. **Turn OFF WiFi** on your phone (use mobile data).
3. Try to log in. It will now connect globally! 🌍

---
**Your app is now a real-world, global application! 🚀✨🏆**
