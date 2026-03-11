import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyUserName = "user_name";
  static const String _keyUserAvatar = "user_avatar";
  static const String _keyLastLogin = "last_login";
  static const String _keyLastLogout = "last_logout";
  static const String _keyLocationMode = "location_mode"; // 'auto' or 'manual'
  static const String _keyManualLocation = "manual_location";
  static const String _keyNotificationsEnabled = "notifications_enabled";
  static const String _keyScanHistory = "scan_history_v2";

  static const String _keyCustomAvatarPath = "custom_avatar_path";

  // Profile Methods
  static Future<void> saveProfile(String name, String avatar, {String? customPath}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserAvatar, avatar);
    if (customPath != null) {
      await prefs.setString(_keyCustomAvatarPath, customPath);
    }
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName) ?? "Farmer Raghav",
      'avatar': prefs.getString(_keyUserAvatar) ?? "person",
      'customPath': prefs.getString(_keyCustomAvatarPath) ?? "",
    };
  }

  // Session Methods
  static Future<void> saveLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLogin, DateTime.now().toIso8601String());
  }

  static Future<void> saveLogoutTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLogout, DateTime.now().toIso8601String());
  }

  static Future<String?> getLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastLogin);
  }

  // Settings Methods
  static Future<void> saveSettings({
    required String locationMode,
    String? manualLocation,
    required bool notificationsEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocationMode, locationMode);
    if (manualLocation != null) await prefs.setString(_keyManualLocation, manualLocation);
    await prefs.setBool(_keyNotificationsEnabled, notificationsEnabled);
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'locationMode': prefs.getString(_keyLocationMode) ?? 'auto',
      'manualLocation': prefs.getString(_keyManualLocation) ?? 'Mylavaram, AP',
      'notificationsEnabled': prefs.getBool(_keyNotificationsEnabled) ?? true,
    };
  }

  // Scan History Methods
  static Future<void> saveScan(Map<String, dynamic> scan) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_keyScanHistory) ?? [];
    
    // Add date to scan
    scan['date'] = DateTime.now().toIso8601String();
    history.insert(0, jsonEncode(scan));
    
    // Keep last 50 scans
    if (history.length > 50) history.removeLast();
    
    await prefs.setStringList(_keyScanHistory, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_keyScanHistory) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScanHistory);
  }

  static Future<void> resetUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
