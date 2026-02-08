import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeolocationService {
  Future<bool> _handlePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<LocationInfo?> getCurrentLocation() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );

    String cityName = 'Unknown';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        cityName = place.locality
            ?? place.subAdministrativeArea
            ?? place.administrativeArea
            ?? place.name
            ?? place.country
            ?? 'Unknown';
      }
    } catch (e) {
      debugPrint('Geocoding failed: $e');
    }

    return LocationInfo(
      latitude: position.latitude,
      longitude: position.longitude,
      city: cityName,
    );
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String city;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.city,
  });

  String get coordinatesString =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
