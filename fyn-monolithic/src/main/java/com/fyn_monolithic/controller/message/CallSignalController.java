package com.fyn_monolithic.controller.message;

import com.fyn_monolithic.dto.message.CallSignalMessage;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;

/**
 * Controller dùng cho signaling WebRTC qua STOMP/WebSocket.
 *
 * Client:
 *  - Kết nối:  ws://<host>:8080/ws
 *  - Gửi:     /app/call/{conversationId}
 *  - Nhận:    /topic/call/{conversationId}
 *
 * Mỗi message chứa type (offer/answer/candidate/hangup) + thông tin SDP/ICE.
 * Controller chỉ đóng vai trò "relay" (chuyển tiếp) mà không xử lý logic WebRTC.
 */
@Controller
@RequiredArgsConstructor
public class CallSignalController {

    private static final Logger log = LoggerFactory.getLogger(CallSignalController.class);

    @MessageMapping("/call/{conversationId}")
    @SendTo("/topic/call/{conversationId}")
    public CallSignalMessage relay(
            @DestinationVariable String conversationId,
            @Payload CallSignalMessage message
    ) {
        // Gắn conversationId phòng khi client không set
        message.setConversationId(conversationId);

        if (log.isDebugEnabled()) {
            log.debug("Relaying call signal: type={}, conv={}, from={}, to={}",
                    message.getType(), conversationId,
                    message.getFromUserId(), message.getToUserId());
        }

        // Có thể bổ sung validate quyền tại đây (user có thuộc conversation không)
        return message;
    }
}


