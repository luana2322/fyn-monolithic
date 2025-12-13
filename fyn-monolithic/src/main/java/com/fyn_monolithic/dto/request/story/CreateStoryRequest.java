package com.fyn_monolithic.dto.request.story;

import com.fyn_monolithic.model.story.MediaType;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateStoryRequest {

    @NotBlank(message = "Media URL is required")
    private String mediaUrl;

    private MediaType mediaType = MediaType.IMAGE;

    private String textContent;

    private String backgroundColor;
}
