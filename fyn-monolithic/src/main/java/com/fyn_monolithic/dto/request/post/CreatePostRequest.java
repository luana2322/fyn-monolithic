package com.fyn_monolithic.dto.request.post;

import com.fyn_monolithic.model.post.PostVisibility;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Set;

@Data
public class CreatePostRequest {

    @Size(max = 2048)
    private String content; // Optional - can be null or empty

    private Set<String> hashtags;

    private Set<String> mentionUsernames;

    private PostVisibility visibility = PostVisibility.PUBLIC;
}
