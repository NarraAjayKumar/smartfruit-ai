import 'package:flutter/material.dart';
import '../../data/local_storage_service.dart';
import '../../data/api_service.dart';
import '../services/location_service.dart';

class UserProvider with ChangeNotifier {
  String _name = "Farmer Raghav";
  String _avatar = "person";
  String _locationMode = "auto";
  String _currentLocation = "Detecting...";
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _manualLocation = "Mylavaram, AP";
  bool _notificationsEnabled = true;
  String? _lastLogin;

  String get name => _name;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get avatar => _avatar;
  String get locationMode => _locationMode;
  String get currentLocation => _locationMode == "auto" ? _currentLocation : _manualLocation;
  String get manualLocation => _manualLocation;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get lastLogin => _lastLogin;

  UserProvider() {
    _loadData();
  }

  String? _customAvatarPath;
  String? get customAvatarPath => _customAvatarPath;

  Future<void> fetchRealLocation() async {
    try {
      final data = await LocationService.getCurrentLocation();
      _latitude = data.latitude;
      _longitude = data.longitude;
      _currentLocation = data.cityName;
      notifyListeners();
    } catch (e) {
      print("Location Error in Provider: $e");
      _currentLocation = "GPS Unavailable";
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    try {
      // Prefer backend data if online
      final profileData = await ApiService.getProfile();
      _name = profileData['name'] ?? "Farmer Raghav";
      _avatar = profileData['avatar'] ?? "person";
    } catch (_) {
      final localProfile = await LocalStorageService.getProfile();
      _name = localProfile['name'] ?? "Farmer Raghav";
      _avatar = localProfile['avatar'] ?? "person";
      _customAvatarPath = localProfile['customPath'];
    }
    
    // Always check for local custom path even if API succeeds
    final localProfile = await LocalStorageService.getProfile();
    if (localProfile['customPath'] != null && localProfile['customPath']!.isNotEmpty) {
      _customAvatarPath = localProfile['customPath'];
    }
    
    final settings = await LocalStorageService.getSettings();
    _locationMode = settings['locationMode'];
    _manualLocation = settings['manualLocation'];
    _notificationsEnabled = settings['notificationsEnabled'];
    _lastLogin = await LocalStorageService.getLastLogin();
    notifyListeners();
  }

  Future<void> updateProfile(String name, String avatar, {String? customAvatarPath}) async {
    _name = name;
    _avatar = avatar;
    if (customAvatarPath != null) {
      _avatar = 'custom';
      _customAvatarPath = customAvatarPath;
      await LocalStorageService.saveProfile(name, 'custom', customPath: customAvatarPath);
    } else {
      await LocalStorageService.saveProfile(name, avatar);
    }
    
    try {
      await ApiService.updateProfile(name: name, avatar: avatar);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> updateLocationMode(String mode) async {
    _locationMode = mode;
    try {
      await ApiService.updateProfile(locationMode: mode);
    } catch (_) {}
    await _persistSettings();
    notifyListeners();
  }

  Future<void> updateManualLocation(String location) async {
    _manualLocation = location;
    try {
      await ApiService.updateProfile(manualLocation: location);
    } catch (_) {}
    await _persistSettings();
    notifyListeners();
  }

  Future<void> updateCurrentLocation(String location) async {
    _currentLocation = location;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    try {
      await ApiService.updateProfile(notificationsEnabled: value);
    } catch (_) {}
    await _persistSettings();
    notifyListeners();
  }

  void simulateHarvestAlert(BuildContext context, String crop) {
    if (!_notificationsEnabled) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[800],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Harvest Alert: $crop", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text("Optimal ripeness detected. Schedule harvest soon!", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _persistSettings() async {
    await LocalStorageService.saveSettings(
      locationMode: _locationMode,
      manualLocation: _manualLocation,
      notificationsEnabled: _notificationsEnabled,
    );
  }

  Future<void> refreshLastLogin() async {
    _lastLogin = await LocalStorageService.getLastLogin();
    notifyListeners();
  }

  Future<void> logout() async {
    await LocalStorageService.saveLogoutTimestamp();
    // In a real app, we might clear temporary state here
  }

  Future<void> resetAll() async {
    await LocalStorageService.resetUserData();
    await _loadData();
  }
}
