import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import '../core/utils/debug_logger.dart';

class ApiService {
  // Authentication - OTP (Mocked for Demo)
  static Future<Map<String, dynamic>> sendOtp({
    required String contact,
    required String type, // 'email' or 'phone'
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    logger.log("MOCK API Request: POST /send-otp");
    return {
      "message": "OTP sent successfully",
      "otp": "123456" // Mock OTP
    };
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String contact,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (otp == "123456") {
      return {"message": "OTP verified successfully", "token": "mock_session_token_123"};
    } else {
      throw Exception("Invalid OTP");
    }
  }

  // Profile Management (Delegated to LocalStorageService)
  static Future<Map<String, dynamic>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Provide a default static profile as mock API response
    // We try to merge whatever is in LocalStorage or just return defaults
    final localProfile = await LocalStorageService.getProfile();
    final localSettings = await LocalStorageService.getSettings();
    return {
      "name": localProfile["name"] ?? "Farmer Raghav",
      "avatar": localProfile["avatar"] ?? "person",
      "notificationsEnabled": localSettings["notificationsEnabled"] ?? true,
      "locationMode": localSettings["locationMode"] ?? "auto",
      "manualLocation": localSettings["manualLocation"] ?? "Mylavaram, AP",
    };
  }

  static Future<void> updateProfile({
    String? name,
    String? avatar,
    bool? notificationsEnabled,
    String? locationMode,
    String? manualLocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final currentProfile = await LocalStorageService.getProfile();
    final currentSettings = await LocalStorageService.getSettings();
    
    await LocalStorageService.saveProfile(
      name ?? currentProfile["name"]!, 
      avatar ?? currentProfile["avatar"]!,
    );
    
    await LocalStorageService.saveSettings(
      locationMode: locationMode ?? currentSettings["locationMode"]!,
      manualLocation: manualLocation ?? currentSettings["manualLocation"],
      notificationsEnabled: notificationsEnabled ?? currentSettings["notificationsEnabled"]!,
    );
  }

  // Health Check - Always Online in Offline Mode
  static Future<bool> isBackendOnline() async {
    return true; // Fake online status so features are unlocked
  }
}

