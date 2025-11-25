package com.fyn_monolithic.dto.request.message;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SendMessageRequest {

    @NotBlank
    private String content;

    private String mediaObjectKey;
}
