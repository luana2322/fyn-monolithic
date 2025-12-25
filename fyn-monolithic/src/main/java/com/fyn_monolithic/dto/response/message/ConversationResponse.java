package com.fyn_monolithic.dto.response.message;

import com.fyn_monolithic.model.message.ConversationType;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

@Value
@Builder(toBuilder = true)
public class ConversationResponse {
    UUID id;
    ConversationType type;
    String title;
    Set<String> memberIds;
    Instant createdAt;
    Instant updatedAt;
    // Additional fields for chat list display
    String otherUserId; // For direct messages - the other user's ID
    String otherUserAvatar; // For direct messages - the other user's avatar URL
    String otherUserName; // For direct messages - the other user's display name
    String lastMessage; // Preview of last message
    Instant lastMessageAt; // Timestamp of last message
    int memberCount; // Number of members in conversation
}
