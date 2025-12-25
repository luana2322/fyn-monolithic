import '../../../post/data/models/post_model.dart';
import '../../../post/data/models/report_reason.dart';
import '../../../auth/data/models/user_response.dart';
import 'report_status.dart';

class PostReportModel {
  final String id;
  final PostModel post;
  final UserResponse reporter;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? moderationComment;
  final DateTime createdAt;

  PostReportModel({
    required this.id,
    required this.post,
    required this.reporter,
    required this.reason,
    this.description,
    required this.status,
    this.moderationComment,
    required this.createdAt,
  });

  factory PostReportModel.fromJson(Map<String, dynamic> json) {
    return PostReportModel(
      id: json['id'],
      post: PostModel.fromJson(json['post']),
      reporter: UserResponse.fromJson(json['reporter']),
      reason: ReportReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => ReportReason.OTHER,
      ),
      description: json['description'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.PENDING,
      ),
      moderationComment: json['moderationComment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
