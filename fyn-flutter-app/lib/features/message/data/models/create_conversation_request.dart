import 'conversation_type.dart';

class CreateConversationRequest {
  final Set<String> participantIds;
  final String? title;
  final ConversationType type;

  CreateConversationRequest({
    required this.participantIds,
    this.title,
    this.type = ConversationType.direct,
  });

  Map<String, dynamic> toJson() {
    return {
      'participantIds': participantIds.toList(),
      if (title != null) 'title': title,
      'type': type.serverValue,
    };
  }
}



