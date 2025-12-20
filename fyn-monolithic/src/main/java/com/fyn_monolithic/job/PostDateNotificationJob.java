package com.fyn_monolithic.job;

import com.fyn_monolithic.model.connection.Connection;
import com.fyn_monolithic.repository.connection.ConnectionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.ZonedDateTime;
import java.util.List;

/**
 * Scheduled job to send post-date feedback requests
 * Runs every hour to check for dates that happened 12-24h ago
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PostDateNotificationJob {

    private final ConnectionRepository connectionRepository;
    // private final PushNotificationService pushNotificationService; // TODO:
    // Implement

    /**
     * Send feedback requests for dates that happened 12-24 hours ago
     * Runs every hour
     */
    @Scheduled(fixedRate = 3600000) // Every hour (3600000 ms)
    public void sendPostDateFeedbackRequests() {
        log.info("Running post-date notification job");

        ZonedDateTime now = ZonedDateTime.now();
        ZonedDateTime windowStart = now.minusHours(24);
        ZonedDateTime windowEnd = now.minusHours(12);

        try {
            // Find dates that happened in the 12-24h window and haven't been processed
            List<Connection> pendingFeedback = connectionRepository
                    .findAll()
                    .stream()
                    .filter(c -> c.getDateScheduledAt() != null)
                    .filter(c -> "PENDING".equals(c.getFeedbackStatus()))
                    .filter(c -> c.getDateScheduledAt().isAfter(windowStart) &&
                            c.getDateScheduledAt().isBefore(windowEnd))
                    .toList();

            log.info("Found {} dates requiring feedback requests", pendingFeedback.size());

            for (Connection connection : pendingFeedback) {
                try {
                    // Send push notifications to both users
                    sendFeedbackRequest(connection.getRequester().getId(), connection.getId());
                    sendFeedbackRequest(connection.getReceiver().getId(), connection.getId());

                    // Mark as requested
                    connection.setFeedbackStatus("REQUESTED");
                    connectionRepository.save(connection);

                    log.info("Sent feedback requests for connection {}", connection.getId());
                } catch (Exception e) {
                    log.error("Failed to send feedback request for connection {}",
                            connection.getId(), e);
                }
            }

            log.info("Post-date notification job completed successfully");
        } catch (Exception e) {
            log.error("Error in post-date notification job", e);
        }
    }

    /**
     * Send push notification to user requesting feedback
     * TODO: Implement actual push notification service
     */
    private void sendFeedbackRequest(java.util.UUID userId, java.util.UUID connectionId) {
        log.info("Sending feedback request to user {} for connection {}", userId, connectionId);

        // TODO: Implement push notification
        // pushNotificationService.send(userId, PushNotification.builder()
        // .title("How was your date?")
        // .body("Let us know if you met!")
        // .data(Map.of(
        // "type", "DATE_FEEDBACK",
        // "connectionId", connectionId.toString()
        // ))
        // .build());
    }
}
