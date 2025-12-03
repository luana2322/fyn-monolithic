package com.fyn_monolithic.dto.request.message;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class StartCallRequest {

    @NotNull
    private UUID conversationId;

    @NotBlank
    private String calleeId;
}


