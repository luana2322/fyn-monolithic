package com.fyn_monolithic.dto.request.post;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.UUID;

@Data
public class CreateCommentRequest {

    private UUID parentCommentId;

    @NotBlank
    @Size(max = 1024)
    private String content;
}
