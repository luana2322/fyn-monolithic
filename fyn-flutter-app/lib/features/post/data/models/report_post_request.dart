import 'report_reason.dart';

class ReportPostRequest {
  final ReportReason reason;
  final String? description;

  ReportPostRequest({
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason.name,
      'description': description,
    };
  }
}
