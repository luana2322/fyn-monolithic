enum MeetType {
  oneToOne('ONE_TO_ONE'),
  group('GROUP');

  final String value;
  const MeetType(this.value);

  static MeetType fromString(String value) {
    return MeetType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MeetType.group,
    );
  }
}

enum MeetupStatus {
  open('OPEN'),
  matched('MATCHED'),
  waitingConfirmation('WAITING_CONFIRMATION'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  expired('EXPIRED');

  final String value;
  const MeetupStatus(this.value);

  static MeetupStatus fromString(String value) {
    return MeetupStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MeetupStatus.open,
    );
  }
}

enum MatchStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  confirmed('CONFIRMED');

  final String value;
  const MatchStatus(this.value);

  static MatchStatus fromString(String value) {
    return MatchStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MatchStatus.pending,
    );
  }
}

enum ConfirmationStatus {
  none('NONE'),
  pending('PENDING'),
  confirmed('CONFIRMED'),
  disputed('DISPUTED'),
  noShow('NO_SHOW');

  final String value;
  const ConfirmationStatus(this.value);

  static ConfirmationStatus fromString(String value) {
    return ConfirmationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConfirmationStatus.none,
    );
  }
}
