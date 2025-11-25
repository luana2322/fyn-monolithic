enum ConversationType {
  direct,
  group;

  static ConversationType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'GROUP':
        return ConversationType.group;
      case 'DIRECT':
      default:
        return ConversationType.direct;
    }
  }

  String get serverValue {
    switch (this) {
      case ConversationType.group:
        return 'GROUP';
      case ConversationType.direct:
      default:
        return 'DIRECT';
    }
  }
}



