package com.fyn_monolithic.dto.response.message;

import com.fyn_monolithic.model.message.ConversationType;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

@Value
@Builder
public class ConversationResponse {
    UUID id;
    ConversationType type;
    String title;
    Set<String> memberIds;
    Instant createdAt;
    Instant updatedAt;
}
