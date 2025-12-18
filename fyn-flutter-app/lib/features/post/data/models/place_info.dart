/// Tagged place information
class PlaceInfo {
  final String code;
  final String name;

  PlaceInfo({
    required this.code,
    required this.name,
  });

  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    return PlaceInfo(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
      };
}
