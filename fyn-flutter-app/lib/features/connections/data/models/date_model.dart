import 'match_model.dart';

/// Date plan model for scheduling meetups
class DateModel {
  final String id;
  final String title;
  final String? description;
  final UserPreview owner;
  final UserPreview? partner;
  final String placeType; // restaurant, cafe, bar, park, cinema, etc.
  final String? placeName;
  final String? placeAddress;
  final double? latitude;
  final double? longitude;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool isPublic;
  final String status; // open, proposal_pending, accepted, completed, cancelled
  final int proposalCount;
  final String connectionType;
  final DateTime createdAt;

  DateModel({
    required this.id,
    required this.title,
    this.description,
    required this.owner,
    this.partner,
    required this.placeType,
    this.placeName,
    this.placeAddress,
    this.latitude,
    this.longitude,
    required this.scheduledAt,
    this.durationMinutes = 120,
    this.isPublic = false,
    this.status = 'open',
    this.proposalCount = 0,
    this.connectionType = 'dating',
    required this.createdAt,
  });

  factory DateModel.fromJson(Map<String, dynamic> json) {
    return DateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      owner: UserPreview.fromJson(json['owner']),
      partner: json['partner'] != null ? UserPreview.fromJson(json['partner']) : null,
      placeType: json['placeType'] ?? json['place_type'] ?? 'other',
      placeName: json['placeName'] ?? json['place_name'],
      placeAddress: json['placeAddress'] ?? json['place_address'],
      latitude: (json['latitude'] ?? json['lat'])?.toDouble(),
      longitude: (json['longitude'] ?? json['lng'])?.toDouble(),
      scheduledAt: DateTime.parse(json['scheduledAt'] ?? json['scheduled_at']),
      durationMinutes: json['durationMinutes'] ?? json['duration_minutes'] ?? 120,
      isPublic: json['isPublic'] ?? json['is_public'] ?? false,
      status: json['status'] ?? 'open',
      proposalCount: json['proposalCount'] ?? json['proposal_count'] ?? 0,
      connectionType: json['connectionType'] ?? json['connection_type'] ?? 'dating',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'placeType': placeType,
    'placeName': placeName,
    'placeAddress': placeAddress,
    'latitude': latitude,
    'longitude': longitude,
    'scheduledAt': scheduledAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'isPublic': isPublic,
    'connectionType': connectionType,
  };

  /// Formatted date string
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}, ${scheduledAt.hour}:${scheduledAt.minute.toString().padLeft(2, '0')}';
  }

  /// Status display color
  bool get isOpen => status == 'open';
  bool get isAccepted => status == 'accepted';
  bool get isCompleted => status == 'completed';
}

/// Proposal for joining a date
class ProposalModel {
  final String id;
  final String dateId;
  final UserPreview proposer;
  final String? message;
  final DateTime? proposedTime;
  final String status; // pending, accepted, rejected, counter_proposed
  final DateTime createdAt;

  ProposalModel({
    required this.id,
    required this.dateId,
    required this.proposer,
    this.message,
    this.proposedTime,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['id'] as String,
      dateId: json['dateId'] ?? json['date_id'] ?? '',
      proposer: UserPreview.fromJson(json['proposer']),
      message: json['message'] as String?,
      proposedTime: json['proposedTime'] != null ? DateTime.parse(json['proposedTime']) : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
}
