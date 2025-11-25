package com.fyn_monolithic.dto.response.message;

import com.fyn_monolithic.model.message.MessageStatus;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.UUID;

@Value
@Builder(toBuilder = true)
public class MessageResponse {
    UUID id;
    UUID conversationId;
    String senderId;
    String content;
    String reaction;
    MessageStatus status;
    Instant createdAt;
    String mediaUrl;
}
