import 'package:intl/intl.dart';

class DateUtils {
  // Format: 2024-01-01T00:00:00Z
  static const String _iso8601Format = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  
  static DateFormat get _iso8601Formatter => DateFormat(_iso8601Format);

  /// Parse ISO 8601 date string to DateTime
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format DateTime to ISO 8601 string
  static String formatIso8601(DateTime dateTime) {
    return _iso8601Formatter.format(dateTime.toUtc());
  }

  /// Format DateTime to readable string
  static String formatReadable(DateTime dateTime, {String? locale}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  /// Format DateTime to date string (dd/MM/yyyy)
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Format DateTime to date time string (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Format DateTime to time string (HH:mm)
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}














