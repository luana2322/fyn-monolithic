package com.fyn_monolithic.dto.response.message;

import com.fyn_monolithic.model.message.CallStatus;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.UUID;

@Value
@Builder
public class CallResponse {
    UUID id;
    UUID conversationId;
    String callerId;
    String calleeId;
    String roomId;
    CallStatus status;
    Instant createdAt;
    Instant acceptedAt;
    Instant endedAt;
}


