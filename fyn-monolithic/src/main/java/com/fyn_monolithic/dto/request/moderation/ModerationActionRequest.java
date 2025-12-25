package com.fyn_monolithic.dto.request.moderation;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ModerationActionRequest {
    private String reason;
    private String adminComment;
}
