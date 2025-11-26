package com.fyn_monolithic.service.message;

import com.fyn_monolithic.dto.request.message.SendMessageRequest;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.message.MessageResponse;
import com.fyn_monolithic.mapper.MessageMapper;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.Message;
import com.fyn_monolithic.model.message.MessageMedia;
import com.fyn_monolithic.model.storage.MediaType;
import com.fyn_monolithic.model.notification.NotificationType;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.message.MessageRepository;
import com.fyn_monolithic.repository.message.MessageMediaRepository;
import com.fyn_monolithic.service.notification.NotificationService;
import com.fyn_monolithic.service.storage.MinioService;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final ConversationService conversationService;
    private final MessageRepository messageRepository;
    private final MessageMediaRepository messageMediaRepository;
    private final UserService userService;
    private final MessageMapper messageMapper;
    private final MinioService minioService;
    private final NotificationService notificationService;

    @Transactional
    public MessageResponse sendMessage(UUID conversationId, SendMessageRequest request, MultipartFile media) {
        Conversation conversation = conversationService.getConversation(conversationId);
        User sender = userService.getCurrentUser();
        
        // Validate: at least one of content, media, or reaction must be present
        boolean hasContent = request.getContent() != null && !request.getContent().trim().isEmpty();
        boolean hasMedia = media != null && !media.isEmpty();
        boolean hasReaction = request.getReaction() != null && !request.getReaction().trim().isEmpty();
        
        if (!hasContent && !hasMedia && !hasReaction) {
            throw new IllegalArgumentException("Message must have at least content, media, or reaction");
        }
        
        Message message = new Message();
        message.setConversation(conversation);
        message.setSender(sender);
        message.setContent(request.getContent() != null ? request.getContent() : "");
        message.setReaction(request.getReaction());
        Message saved = messageRepository.save(message);

        MessageResponse response = messageMapper.toMessageResponse(saved);
        if (media != null && !media.isEmpty()) {
            // Upload media with proper content type and file name
            String objectKey = minioService.upload(media);
            // Detect media type from content type
            MediaType detectedType = minioService.detectMediaType(media);
            MessageMedia mediaEntity = new MessageMedia();
            mediaEntity.setMessage(saved);
            mediaEntity.setObjectKey(objectKey);
            mediaEntity.setMediaType(detectedType);
            messageMediaRepository.save(mediaEntity);
            response = response.toBuilder()
                    // Trả về objectKey để frontend tự build URL qua /api/files/{objectKey}
                    .mediaUrl(objectKey)
                    .build();
        }

        // Tạo thông báo cho các thành viên khác trong cuộc trò chuyện
        conversation.getMembers().forEach(member -> {
            User recipient = member.getMember();
            if (!recipient.getId().equals(sender.getId())) {
                String preview = hasContent ? request.getContent() : "Bạn có tin nhắn mới";
                notificationService.notifyNewMessage(
                        recipient,
                        conversation.getId(),
                        preview
                );
            }
        });

        return mapMediaUrl(response);
    }

    @Transactional(readOnly = true)
    public PageResponse<MessageResponse> getMessages(UUID conversationId, int page, int size) {
        Conversation conversation = conversationService.getConversation(conversationId);
        Page<Message> result = messageRepository.findByConversation(conversation, PageRequest.of(page, size));
        return PageResponse.<MessageResponse>builder()
                .content(result.getContent().stream()
                        .map(messageMapper::toMessageResponse)
                        .map(this::mapMediaUrl)
                        .toList())
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build();
    }

    private MessageResponse mapMediaUrl(MessageResponse response) {
        if (response.getMediaUrl() == null) {
            return response;
        }
        // Giữ nguyên mediaUrl (objectKey hoặc URL đầy đủ) để frontend tự xử lý.
        // Nếu là objectKey, FE sẽ build URL dạng `${baseUrl}/api/files/{objectKey}`.
        return response;
    }
}
