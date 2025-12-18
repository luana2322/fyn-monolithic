/// GPS location information
class LocationInfo {
  final double latitude;
  final double longitude;

  LocationInfo({
    required this.latitude,
    required this.longitude,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
