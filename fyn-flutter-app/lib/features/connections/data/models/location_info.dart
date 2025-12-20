import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Location information for a date with map integration
class LocationInfo {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  LocationInfo({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Generate OpenStreetMap URL for navigation
  String get openStreetMapUrl =>
      'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude';

  /// Generate Google Maps URL (fallback for mobile native apps)
  String get googleMapsUrl =>
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

  /// Open map for navigation (platform-aware)
  Future<void> openInMaps() async {
    try {
      Uri url;
      
      if (kIsWeb) {
        // Web: Open OpenStreetMap in new tab
        url = Uri.parse(openStreetMapUrl);
        await launchUrl(url, webOnlyWindowName: '_blank');
      } else {
        // Mobile: Try Google Maps app first, fallback to OpenStreetMap
        url = Uri.parse(googleMapsUrl);
        final canLaunch = await canLaunchUrl(url);
        
        if (canLaunch) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to OpenStreetMap browser
          url = Uri.parse(openStreetMapUrl);
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      throw Exception('Could not launch maps for this location: $e');
    }
  }
}
