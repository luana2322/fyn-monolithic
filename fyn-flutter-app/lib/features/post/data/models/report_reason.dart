enum ReportReason {
  SPAM,
  INAPPROPRIATE,
  HATE_SPEECH,
  SCAM,
  OTHER;

  String get displayName {
    switch (this) {
      case ReportReason.SPAM:
        return 'Spam';
      case ReportReason.INAPPROPRIATE:
        return 'Inappropriate Content';
      case ReportReason.HATE_SPEECH:
        return 'Hate Speech';
      case ReportReason.SCAM:
        return 'Scam/Fraud';
      case ReportReason.OTHER:
        return 'Other';
    }
  }
}
