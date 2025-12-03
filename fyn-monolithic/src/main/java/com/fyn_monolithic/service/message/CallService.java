package com.fyn_monolithic.service.message;

import com.fyn_monolithic.dto.request.message.StartCallRequest;
import com.fyn_monolithic.dto.response.message.CallResponse;
import com.fyn_monolithic.model.message.CallStatus;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Đơn giản hoá: lưu CallSession trong bộ nhớ, đủ để FE demo video call.
 * Nếu cần persistence thật sự, có thể chuyển sang entity + repository sau.
 */
@Service
@RequiredArgsConstructor
public class CallService {

    private final ConversationService conversationService;
    private final UserService userService;

    // In-memory call store
    private final Map<UUID, CallResponse> calls = new ConcurrentHashMap<>();

    @Transactional
    public CallResponse startCall(StartCallRequest request) {
        User caller = userService.getCurrentUser();
        Conversation conversation =
                conversationService.getConversation(request.getConversationId());

        UUID callId = UUID.randomUUID();
        String roomId = "call-" + conversation.getId();

        CallResponse call = CallResponse.builder()
                .id(callId)
                .conversationId(conversation.getId())
                .callerId(caller.getId().toString())
                .calleeId(request.getCalleeId())
                .roomId(roomId)
                .status(CallStatus.RINGING)
                .createdAt(Instant.now())
                .build();

        calls.put(callId, call);
        return call;
    }

    @Transactional
    public CallResponse acceptCall(UUID callId) {
        CallResponse existing = calls.get(callId);
        if (existing == null) {
            // Trả về trạng thái ENDED nếu không tìm thấy
            return CallResponse.builder()
                    .id(callId)
                    .status(CallStatus.ENDED)
                    .build();
        }
        CallResponse updated = CallResponse.builder()
                .id(existing.getId())
                .conversationId(existing.getConversationId())
                .callerId(existing.getCallerId())
                .calleeId(existing.getCalleeId())
                .roomId(existing.getRoomId())
                .status(CallStatus.ACCEPTED)
                .createdAt(existing.getCreatedAt())
                .acceptedAt(Instant.now())
                .endedAt(existing.getEndedAt())
                .build();
        calls.put(callId, updated);
        return updated;
    }

    @Transactional
    public CallResponse endCall(UUID callId) {
        CallResponse existing = calls.get(callId);
        if (existing == null) {
            return CallResponse.builder()
                    .id(callId)
                    .status(CallStatus.ENDED)
                    .endedAt(Instant.now())
                    .build();
        }
        CallResponse updated = CallResponse.builder()
                .id(existing.getId())
                .conversationId(existing.getConversationId())
                .callerId(existing.getCallerId())
                .calleeId(existing.getCalleeId())
                .roomId(existing.getRoomId())
                .status(CallStatus.ENDED)
                .createdAt(existing.getCreatedAt())
                .acceptedAt(existing.getAcceptedAt())
                .endedAt(Instant.now())
                .build();
        calls.put(callId, updated);
        return updated;
    }
}


