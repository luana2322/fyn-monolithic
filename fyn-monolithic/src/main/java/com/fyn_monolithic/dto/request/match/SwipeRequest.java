package com.fyn_monolithic.dto.request.match;

import com.fyn_monolithic.model.match.SwipeType;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class SwipeRequest {
    @NotNull
    private UUID targetUserId;
    @NotNull
    private SwipeType swipeType;
}
