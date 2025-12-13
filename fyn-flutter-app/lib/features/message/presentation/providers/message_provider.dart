import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/message_service.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/create_conversation_request.dart';
import '../../data/models/send_message_request.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

// Repository Provider
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.user?.id ?? '';
  return MessageRepository(apiClient, userId);
});

// Service Provider
final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService(ref.watch(messageRepositoryProvider));
});

// Conversation List State
class ConversationListState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Conversation List Notifier
class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final MessageService _service;
  Timer? _pollingTimer;

  ConversationListNotifier(this._service) : super(const ConversationListState()) {
    loadConversations();
    _startPolling();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversations = await _service.getConversations();
      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _startPolling() {
    // Polling mỗi 3 giây để cập nhật realtime
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!state.isLoading) {
        loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
        (ref) {
  final service = ref.watch(messageServiceProvider);
  return ConversationListNotifier(service);
});

// Message State
class MessageState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool isSending;

  const MessageState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.isSending = false,
  });

  MessageState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool? isSending,
    bool clearError = false,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      isSending: isSending ?? this.isSending,
    );
  }
}

// Message Notifier
class MessageNotifier extends StateNotifier<MessageState> {
  final MessageService _service;
  final String _conversationId;
  Timer? _pollingTimer;
  int _currentPage = 0;
  static const int _pageSize = 50;

  MessageNotifier(this._service, this._conversationId)
      : super(const MessageState()) {
    loadMessages();
    _startPolling();
  }

  Future<void> loadMessages({bool reset = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (reset) {
      state = state.copyWith(isLoading: true, clearError: true);
      _currentPage = 0;
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    try {
      final page = await _service.getMessages(
        _conversationId,
        page: _currentPage,
        size: _pageSize,
      );

      // Sắp xếp messages theo createdAt (cũ nhất trước)
      final sortedMessages = List<MessageModel>.from(page.content);
      sortedMessages.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });

      final newMessages = reset
          ? sortedMessages
          : [...state.messages, ...sortedMessages];

      // Sắp xếp lại toàn bộ danh sách để đảm bảo thứ tự đúng
      newMessages.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(
        messages: newMessages,
        isLoading: false,
        isLoadingMore: false,
        hasMore: page.hasNextPage,
        clearError: true,
      );

      _currentPage++;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(
    String content, {
    XFile? mediaFile,
    String? reaction,
  }) async {
    if (content.trim().isEmpty && mediaFile == null && reaction == null) return;

    state = state.copyWith(isSending: true, clearError: true);
    try {
      final request = SendMessageRequest(
        content: content.trim(),
        reaction: reaction,
      );
      final message = await _service.sendMessage(
        _conversationId,
        request,
        mediaFile: mediaFile,
      );

      // Thêm message mới và sắp xếp lại theo createdAt
      final newMessages = [message, ...state.messages];
      newMessages.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(
        messages: newMessages,
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void _startPolling() {
    // Polling mỗi 2 giây để cập nhật tin nhắn mới
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!state.isLoading && !state.isLoadingMore) {
        _pollNewMessages();
      }
    });
  }

  Future<void> _pollNewMessages() async {
    try {
      final page = await _service.getMessages(
        _conversationId,
        page: 0,
        size: 10,
      );

      if (page.content.isNotEmpty) {
        final existingIds = state.messages.map((m) => m.id).toSet();
        final newMessages = page.content
            .where((m) => !existingIds.contains(m.id))
            .toList();

        if (newMessages.isNotEmpty) {
          // Sắp xếp lại toàn bộ danh sách sau khi thêm tin nhắn mới
          final allMessages = [...newMessages, ...state.messages];
          allMessages.sort((a, b) {
            final aTime = a.createdAt ?? DateTime(1970);
            final bTime = b.createdAt ?? DateTime(1970);
            return aTime.compareTo(bTime);
          });
          state = state.copyWith(
            messages: allMessages,
          );
        }
      }
    } catch (e) {
      // Silent fail for polling
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final messageProvider = StateNotifierProvider.family<MessageNotifier,
    MessageState, String>((ref, conversationId) {
  final service = ref.watch(messageServiceProvider);
  return MessageNotifier(service, conversationId);
});



