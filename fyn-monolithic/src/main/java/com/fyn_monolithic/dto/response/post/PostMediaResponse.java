package com.fyn_monolithic.dto.response.post;

import com.fyn_monolithic.model.storage.MediaType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Value;

@Value
@AllArgsConstructor
@Builder
public class PostMediaResponse {
    String objectKey;
    String mediaUrl;
    MediaType mediaType;
    Integer orderIndex;
    String description;
}
