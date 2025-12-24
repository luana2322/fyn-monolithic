package com.fyn_monolithic.dto.request.message;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;
import java.util.UUID;

/**
 * Request to create a friends group chat
 */
@Data
public class CreateGroupRequest {

    @NotBlank(message = "Group name is required")
    private String name;

    @NotEmpty(message = "At least one member is required")
    private List<UUID> memberIds;
}
