package com.fyn_monolithic.dto.message;

import lombok.Data;

/**
 * Payload dùng cho signaling WebRTC qua WebSocket/STOMP.
 *
 * type:
 *  - "offer"    : SDP offer từ caller
 *  - "answer"   : SDP answer từ callee
 *  - "candidate": ICE candidate
 *  - "hangup"   : kết thúc cuộc gọi
 */
@Data
public class CallSignalMessage {

    private String type;

    private String fromUserId;

    private String toUserId;

    private String conversationId;

    // Dùng cho offer/answer
    private String sdp;

    // Dùng cho ICE candidate
    private String candidate;
    private String sdpMid;
    private Integer sdpMLineIndex;
}


