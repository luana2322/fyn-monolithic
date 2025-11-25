package com.fyn_monolithic.dto.response.post;

import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.model.post.PostVisibility;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Value
@Builder
public class PostResponse {
    UUID id;
    UserResponse author;
    String content;
    PostVisibility visibility;
    long likeCount;
    long commentCount;
    Instant createdAt;
    List<PostMediaResponse> media;
}
