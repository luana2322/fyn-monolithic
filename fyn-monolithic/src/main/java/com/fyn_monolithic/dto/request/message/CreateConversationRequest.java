package com.fyn_monolithic.dto.request.message;

import com.fyn_monolithic.model.message.ConversationType;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.Set;

@Data
public class CreateConversationRequest {

    @NotEmpty
    private Set<String> participantIds;

    private String title;

    private ConversationType type = ConversationType.DIRECT;
}
