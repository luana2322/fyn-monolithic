enum ConversationType {
  direct,
  group,
  groupMeetup,
  friendsGroup;

  static ConversationType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'GROUP_MEETUP':
        return ConversationType.groupMeetup;
      case 'FRIENDS_GROUP':
        return ConversationType.friendsGroup;
      case 'GROUP':
        return ConversationType.group;
      case 'DIRECT':
      default:
        return ConversationType.direct;
    }
  }

  String get serverValue {
    switch (this) {
      case ConversationType.groupMeetup:
        return 'GROUP_MEETUP';
      case ConversationType.friendsGroup:
        return 'FRIENDS_GROUP';
      case ConversationType.group:
        return 'GROUP';
      case ConversationType.direct:
      default:
        return 'DIRECT';
    }
  }

  bool get isGroup => this != ConversationType.direct;
}
