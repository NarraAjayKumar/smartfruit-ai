enum ApiEnv { local, production }

class ApiConfig {
  // ==========================================
  // 🛰️ GLOBAL CONNECTIVITY SETTINGS
  // ==========================================
  
  // 1. LOCAL SETUP (Emulator / Same WiFi)
  static const String emulatorIp = "10.0.2.2";
  static const String physicalDeviceIp = "192.168.0.116"; 
  static const String localPort = "5000";

  // 2. PRODUCTION SETUP (Global Access)
  // ✅ FIXED: Synchronized with your Render URL
  static const String productionUrl = "https://smartfruit-backend.onrender.com"; 

  // 3. ENVIRONMENT TOGGLE
  // Switch to ApiEnv.production for global access from ANY network.
  static const ApiEnv currentEnv = ApiEnv.production;

  // Set this to true ONLY if you are on 'local' environment and using a real phone.
  static const bool isLocalRealDevice = true;

  // ==========================================
  // 🚀 BASE URL GENERATOR
  // ==========================================
  static String get baseUrl {
    if (currentEnv == ApiEnv.production) {
      return "$productionUrl/api";
    }
    
    final String host = isLocalRealDevice ? physicalDeviceIp : emulatorIp;
    return "http://$host:$localPort/api";
  }
}
