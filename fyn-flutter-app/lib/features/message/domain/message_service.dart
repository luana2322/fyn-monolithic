import '../data/repositories/message_repository.dart';
import '../data/models/conversation_model.dart';
import '../data/models/message_model.dart';
import '../data/models/create_conversation_request.dart';
import '../data/models/send_message_request.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/page_response.dart';

class MessageService {
  final MessageRepository _repository;

  MessageService(this._repository);

  /// Lấy danh sách conversations
  Future<List<ConversationModel>> getConversations() async {
    return await _repository.getConversations();
  }

  /// Tạo conversation mới
  Future<ConversationModel> createConversation(
    CreateConversationRequest request,
  ) async {
    return await _repository.createConversation(request);
  }

  /// Lấy danh sách messages
  Future<PageResponse<MessageModel>> getMessages(
    String conversationId, {
    int page = 0,
    int size = 50,
  }) async {
    return await _repository.getMessages(conversationId, page: page, size: size);
  }

  /// Gửi tin nhắn
  Future<MessageModel> sendMessage(
    String conversationId,
    SendMessageRequest request, {
    XFile? mediaFile,
  }) async {
    return await _repository.sendMessage(
      conversationId,
      request,
      mediaFile: mediaFile,
    );
  }
}



