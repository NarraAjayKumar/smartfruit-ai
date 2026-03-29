import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;
  final String district;
  final String state;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.district,
    required this.state,
  });
}

class LocationService {
  static const String _keyDistrict = "user_district";
  static const String _keyState = "user_state";
  static const String _keyCity = "user_city";

  static Future<LocationData> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await _getCachedLocationData(0, 0);
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return await _getCachedLocationData(0, 0);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return await _getCachedLocationData(0, 0);
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subAdministrativeArea ?? "Mylavaram";
        String district = place.subAdministrativeArea ?? place.locality ?? "Anantapur";
        String state = place.administrativeArea ?? "Andhra Pradesh";

        await _cacheLocation(city, district, state);
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: "$city, ${state == 'Andhra Pradesh' ? 'AP' : state.substring(0,2).toUpperCase()}",
          district: district,
          state: state,
        );
      }
    } catch (e) {
      dev.log("Location Error: $e");
    }
    return await _getCachedLocationData(16.7491, 80.6468);
  }

  static Future<void> _cacheLocation(String city, String district, String state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCity, city);
    await prefs.setString(_keyDistrict, district);
    await prefs.setString(_keyState, state);
  }

  static Future<LocationData> _getCachedLocationData(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    String city = prefs.getString(_keyCity) ?? "Mylavaram";
    String state = prefs.getString(_keyState) ?? "Andhra Pradesh";
    return LocationData(
      latitude: lat,
      longitude: lon,
      cityName: "$city, ${state == 'Andhra Pradesh' ? 'AP' : state}",
      district: prefs.getString(_keyDistrict) ?? "Anantapur",
      state: state,
    );
  }
}
