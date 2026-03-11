# 🍎 SmartFruit AI

**A High-Performance, Fully Offline Fruit Detection System for Modern Agriculture.**

SmartFruit AI is a production-ready mobile application that empowers farmers with real-time, on-device artificial intelligence. It detects fruits, analyzes ripeness, and manages scan history—all without an internet connection.

---

## 🚀 Key Features

- **📶 100% Offline AI**: No internet? No problem. Edge-based inference ensures privacy and speed.
- **🎯 Multi-Scale Detection**: Advanced YOLOv8 implementation that processes both full frames and high-resolution crops for maximum accuracy.
- **📦 Smart Filtering**: Custom NMS and logic filters to eliminate false positives like leaves and stems.
- **🕒 Scan History**: Locally persisted database of all your farm scans for easy tracking.
- **👤 Profile Management**: Personalized account with custom avatar support.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **AI Core**: [TensorFlow Lite](https://www.tensorflow.org/lite)
- **Models**: Optimized YOLOv8 (exported as Float16 for mobile performance)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Location**: [Geocoding](https://pub.dev/packages/geocoding) for farm coordinates

---

## 🧠 AI Pipeline

The system performs a proprietary 7-step inference chain:
1. **Frame Capture**: Real-time camera feed acquisition.
2. **Dual-Path Pre-processing**: Parallel resizing and normalization (640x640).
3. **Inference**: Execution via highly optimized TFLite interpreter.
4. **NMS Filtering**: Overlap removal using a 0.45 IoU threshold.
5. **Logic Validation**: Cross-referencing detected fruit classes against user-selected categories.
6. **Confidence Thresholding**: 0.55+ confidence required for valid results.
7. **Spatial Mapping**: Bounding box projection onto the live UI.

---

## 📂 Project Structure

```bash
lib/
├── core/            # Infrastructure, Providers, Constant Services
├── data/            # Local Storage and Service Layer
└── features/        # Feature-driven UI and Business Logic
    ├── auth/        # Login and Authentication
    ├── dashboard/   # Account, Profile, and Farm Settings
    ├── history/     # Scanned Results Database
    ├── scan/        # Real-time AI Camera Interface
    └── settings/    # App Configuration
```

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- A physical Android device (recommended for AI camera testing)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/smartfruit_ai.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run --release
   ```

---

## 📝 Recent Updates

- ✅ **Fixed**: Profile picture saving and persistence across app restarts.
- ✅ **Fixed**: Scan History now correctly records every verified result.
- ✅ **Improved**: UI visibility for "SAVE" buttons across the application.
- ✅ **Optimized**: Project cleanup, removing obsolete backend models and temporary files.

---

## 🛡️ License

Built for the Farmers of Mylavaram. All rights reserved.
