import 'package:geolocator/geolocator.dart';

/// Service for handling location permissions and retrieval
/// Works on both Android and Web platforms
class LocationService {
  /// Request location permission
  /// Returns true if permission granted, false otherwise
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return false
      return false;
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return false;
    }

    return true;
  }

  /// Get current location
  /// Returns null if permission denied or location unavailable
  /// Timeout after 10 seconds to avoid hanging
  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // Handle errors gracefully (timeout, GPS unavailable, etc.)
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}

/// Simple location data model
class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude)';
}
