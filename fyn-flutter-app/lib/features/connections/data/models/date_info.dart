import 'package:intl/intl.dart';
import 'location_info.dart';

/// Date information embedded in a match (simplified dating flow)
class DateInfo {
  final DateTime scheduledAt;
  final String description;
  final LocationInfo location;
  final String status; // PENDING, COMPLETED, NO_SHOW, CANCELLED

  DateInfo({
    required this.scheduledAt,
    required this.description,
    required this.location,
    this.status = 'PENDING',
  });

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      description: json['description'] as String,
      location: LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() => {
        'scheduledAt': scheduledAt.toIso8601String(),
        'description': description,
        'location': location.toJson(),
        'status': status,
      };

  /// Format date and time for display
  String get formattedDateTime {
    return DateFormat('HH:mm – dd/MM').format(scheduledAt);
  }

  /// Full formatted date
  String get fullFormattedDate {
    return DateFormat('EEEE, MMM d \'at\' HH:mm').format(scheduledAt);
  }

  /// Check if date is in the past
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  /// Check if date is upcoming
  bool get isUpcoming => !isPast && status == 'PENDING';

  /// Get status color
  String get statusEmoji {
    switch (status) {
      case 'PENDING':
        return '⏰';
      case 'COMPLETED':
        return '✅';
      case 'NO_SHOW':
        return '❌';
      case 'CANCELLED':
        return '🚫';
      default:
        return '📍';
    }
  }
}
