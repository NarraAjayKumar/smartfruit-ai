import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_storage_service.dart';
import '../core/utils/debug_logger.dart';

class ApiService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;

  // ─── PHONE AUTH (OTP) ─────────────────────────────

  /// Sends OTP via Firebase Phone Auth
  static Future<Map<String, dynamic>> sendOtp({
    required String contact,
    required String type,
  }) async {
    logger.log("Firebase: Sending OTP to $contact ($type)");

    final Completer<Map<String, dynamic>> completer = Completer();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: contact,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification handling
          await _auth.signInWithCredential(credential);
          completer.complete({"autoVerified": true});
        },
        verificationFailed: (FirebaseAuthException e) {
          logger.log("Firebase: Verification Failed - ${e.code}");
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          completer.complete({"verificationId": verificationId});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return await completer.future;
    } catch (e) {
      logger.log("Firebase: sendOtp error - $e");
      rethrow;
    }
  }

  /// Verifies OTP with Firebase (Includes 123456 Bypass)
  static Future<Map<String, dynamic>> verifyOtp({
    required String contact,
    required String otp,
  }) async {
    logger.log("Firebase: Verifying code $otp");

    // Real verification logic follows

    if (_verificationId == null) {
      throw Exception("Verification ID is missing. Please resend OTP.");
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return {
        "message": "OTP verified successfully",
        "token": userCredential.user?.uid ?? "firebase_token",
      };
    } catch (e) {
      logger.log("Firebase: verifyOtp error - $e");
      throw Exception("Invalid OTP code. Please try again.");
    }
  }

  // ─── EMAIL AUTH ────────────────────────────

  static Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {
        "message": "Logged in successfully",
        "token": userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  static Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      return {
        "message": "Account created successfully",
        "token": userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'invalid-email': return 'Invalid email format.';
      case 'weak-password': return 'Password is too weak.';
      default: return e.message ?? 'Authentication failed.';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── PROFILE MANAGEMENT ───────────────────

  static Future<Map<String, dynamic>> getProfile() async {
    final user = _auth.currentUser;
    final localProfile = await LocalStorageService.getProfile();
    final localSettings = await LocalStorageService.getSettings();
    
    return {
      "name": user?.displayName ?? localProfile["name"] ?? "Farmer Raghav",
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
    if (name != null) await _auth.currentUser?.updateDisplayName(name);
    
    final currentProfile = await LocalStorageService.getProfile();
    final currentSettings = await LocalStorageService.getSettings();

    await LocalStorageService.saveProfile(
      name ?? currentProfile["name"]!,
      avatar ?? currentProfile["avatar"]!,
    );

    await LocalStorageService.saveSettings(
      locationMode: locationMode ?? currentSettings["locationMode"]!,
      manualLocation: manualLocation ?? currentSettings["manualLocation"],
      notificationsEnabled:
          notificationsEnabled ?? currentSettings["notificationsEnabled"]!,
    );
  }
}
