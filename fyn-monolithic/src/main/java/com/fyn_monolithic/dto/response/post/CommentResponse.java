package com.fyn_monolithic.dto.response.post;

import com.fyn_monolithic.dto.response.user.UserResponse;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.UUID;

@Value
@Builder
public class CommentResponse {
    UUID id;
    UUID parentId;
    UserResponse author;
    String content;
    Instant createdAt;
}
