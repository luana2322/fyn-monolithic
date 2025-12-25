enum ReportStatus {
  PENDING,
  VALID,
  INVALID,
}

extension ReportStatusExtension on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.PENDING:
        return 'Đang chờ';
      case ReportStatus.VALID:
        return 'Hợp lệ';
      case ReportStatus.INVALID:
        return 'Không hợp lệ';
    }
  }
}
