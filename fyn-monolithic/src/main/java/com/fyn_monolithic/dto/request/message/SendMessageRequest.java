package com.fyn_monolithic.dto.request.message;

import lombok.Data;

@Data
public class SendMessageRequest {

    private String content;

    private String mediaObjectKey;

    private String reaction;
}
