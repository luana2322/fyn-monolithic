package com.fyn_monolithic.dto.request.post;

import com.fyn_monolithic.model.post.PostVisibility;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Set;

@Data
public class CreatePostRequest {

    @NotBlank
    @Size(max = 2048)
    private String content;

    private Set<String> hashtags;

    private Set<String> mentionUsernames;

    private PostVisibility visibility = PostVisibility.PUBLIC;
}
