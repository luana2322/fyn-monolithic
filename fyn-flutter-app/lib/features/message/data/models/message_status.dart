enum MessageStatus {
  sent,
  delivered,
  read;

  static MessageStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'DELIVERED':
        return MessageStatus.delivered;
      case 'READ':
        return MessageStatus.read;
      case 'SENT':
      default:
        return MessageStatus.sent;
    }
  }
}



