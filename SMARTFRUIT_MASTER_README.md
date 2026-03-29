# 🍎 SmartFruit AI: Full System Master Guide 🚀💎✨🏆

This document defines the architecture, setup, and deployment of the **SmartFruit AI Integrated Ecosystem**, consisting of the **Flutter Mobile App** and the **Node.js/MongoDB Backend**.

## 🏗️ System Architecture
- **Mobile Client**: Flutter / Dart
  - Real-time AI Vision (YOLOv8 + CUDA)
  - Agri-Advisor (NVIDIA NIM)
  - Location & Weather Services
- **Backend API**: Node.js / Express
  - MongoDB Database (Atlas)
  - Professional JWT Authentication
  - Image/Video Metadata Storage
- **Infrastructure**: Vercel/Render (Backend) + Play Store/App Store (App)

## 📦 Master Folder Structure
```text
SmartFruitAI_FullSystem/
├── app/          # Flutter Project (The Mobile Advisor)
└── backend/      # Node.js Project (The Intelligence Cloud)
```

## 🚀 Quick Start Guide
1. **Intelligence Cloud (Backend)**:
   - Navigate to `backend/`
   - Run `npm install`
   - Set `.env` (MongoDB URL, JWT Secret)
   - Run `node server.js`
2. **Mobile Advisor (App)**:
   - Navigate to `app/`
   - Update `lib/core/constants/api_endpoints.dart` with your server URL
   - Run `flutter pub get`
   - Build App: `flutter build apk`

---
Built by **Narra Ajay Kumar | AI Engineer** 🎙️🚀✨🏆_production_mastery_👸🏆🕺🏆_zero_error_🎙️🚀✨🏆
