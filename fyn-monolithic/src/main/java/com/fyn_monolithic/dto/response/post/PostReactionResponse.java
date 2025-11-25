package com.fyn_monolithic.dto.response.post;

import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
public class PostReactionResponse {
    UUID postId;
    long likeCount;
    boolean likedByCurrentUser;
}





