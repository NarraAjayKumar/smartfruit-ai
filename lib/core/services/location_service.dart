import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as dev;

class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });
}

class LocationService {
  static Future<LocationData> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    } 

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    dev.log('GPS Location: Lat: ${position.latitude}, Lon: ${position.longitude}');

    String cityName = "Unknown Location";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        cityName = "${p.locality}, ${p.administrativeArea}";
        dev.log('City Name: $cityName');
      }
    } catch (e) {
      dev.log('Error reverse geocoding: $e');
    }

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
    );
  }
}
