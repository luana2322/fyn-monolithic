import 'package:freezed_annotation/freezed_annotation.dart';
import 'meetup_enums.dart';

part 'meetup_model.freezed.dart';
part 'meetup_model.g.dart';

@freezed
class MeetupModel with _$MeetupModel {
  const factory MeetupModel({
    required String id,
    required UserSummary organizer,
    required String title,
    String? description,
    required MeetType meetType,
    String? category,
    required String location,
    required double latitude,
    required double longitude,
    required DateTime scheduledAt,
    DateTime? expiresAt,
    int? durationMinutes,
    required int maxParticipants,
    required int acceptedCount,
    required int pendingMatchCount,
    required MeetupStatus status,
    required ConfirmationStatus confirmationStatus,
    double? distanceKm,
    required bool userHasApplied,
    MatchStatus? userMatchStatus,
    required DateTime createdAt,
  }) = _MeetupModel;

  factory MeetupModel.fromJson(Map<String, dynamic> json) =>
      _$MeetupModelFromJson(json);
}

@freezed
class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String id,
    required String username,
    String? fullName,
    String? avatarUrl,
  }) = _UserSummary;

  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryFromJson(json);
}

@freezed
class MeetupMatchModel with _$MeetupMatchModel {
  const factory MeetupMatchModel({
    required String id,
    required String meetupId,
    required UserSummary user,
    String? message,
    required MatchStatus status,
    String? conversationId,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _MeetupMatchModel;

  factory MeetupMatchModel.fromJson(Map<String, dynamic> json) =>
      _$MeetupMatchModelFromJson(json);
}
