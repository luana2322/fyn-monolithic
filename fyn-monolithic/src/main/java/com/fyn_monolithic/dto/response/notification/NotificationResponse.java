package com.fyn_monolithic.dto.response.notification;

import com.fyn_monolithic.model.notification.NotificationStatus;
import com.fyn_monolithic.model.notification.NotificationType;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.UUID;

@Value
@Builder
public class NotificationResponse {
    UUID id;
    NotificationType type;
    NotificationStatus status;
    String message;
    UUID referenceId;
    Instant createdAt;
}
