package com.fyn_monolithic.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * Cấu hình WebSocket/STOMP dùng cho signaling WebRTC (video call, chat realtime...).
 *
 * - Client kết nối tới endpoint: ws://<host>:8080/ws
 * - Gửi tín hiệu lên:      /app/call/{conversationId}
 * - Lắng nghe tín hiệu từ: /topic/call/{conversationId}
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Các destination phía client subscribe, ví dụ: /topic/call/{conversationId}
        registry.enableSimpleBroker("/topic");

        // Prefix cho các message client gửi lên controller: /app/...
        registry.setApplicationDestinationPrefixes("/app");
    }
}


