package com.fyn_monolithic.service.message;

import com.fyn_monolithic.dto.request.message.SendMessageRequest;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.message.MessageResponse;
import com.fyn_monolithic.mapper.MessageMapper;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.Message;
import com.fyn_monolithic.model.message.MessageMedia;
import com.fyn_monolithic.model.storage.MediaType;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.message.MessageRepository;
import com.fyn_monolithic.repository.message.MessageMediaRepository;
import com.fyn_monolithic.service.storage.MinioService;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    public MessageResponse sendMessage(UUID conversationId, SendMessageRequest request, byte[] media) {
        Conversation conversation = conversationService.getConversation(conversationId);
        User sender = userService.getCurrentUser();
        Message message = new Message();
        message.setConversation(conversation);
        message.setSender(sender);
        message.setContent(request.getContent());
        Message saved = messageRepository.save(message);

        MessageResponse response = messageMapper.toMessageResponse(saved);
        if (media != null) {
            String objectKey = minioService.upload(media, "message-" + saved.getId());
            MessageMedia mediaEntity = new MessageMedia();
            mediaEntity.setMessage(saved);
            mediaEntity.setObjectKey(objectKey);
            mediaEntity.setMediaType(MediaType.FILE);
            messageMediaRepository.save(mediaEntity);
            response = response.toBuilder()
                    .mediaUrl(minioService.getPresignedUrl(objectKey))
                    .build();
        }
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
        if (response.getMediaUrl().startsWith("http")) {
            return response;
        }
        return response.toBuilder()
                .mediaUrl(minioService.getPresignedUrl(response.getMediaUrl()))
                .build();
    }
}
