package com.fyn_monolithic.service.match;

import com.fyn_monolithic.dto.request.match.DateFeedbackRequest;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.connection.Connection;
import com.fyn_monolithic.model.match.DateFeedback;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.connection.ConnectionRepository;
import com.fyn_monolithic.repository.match.DateFeedbackRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Service for handling post-date feedback
 * Feedback is requested 12-24h after scheduled date time
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DateFeedbackService {

    private final DateFeedbackRepository feedbackRepository;
    private final ConnectionRepository connectionRepository;
    private final UserRepository userRepository;
    private final ReputationService reputationService;

    /**
     * Submit feedback for a date (idempotent)
     * If user already submitted, updates existing feedback
     */
    @Transactional
    public void submitFeedback(UUID userId, UUID connectionId, DateFeedbackRequest request) {
        // Validate inputs
        validateFeedbackRequest(request);

        // Find connection
        Connection connection = connectionRepository.findById(connectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Connection not found"));

        // Verify user is part of this connection
        if (!isUserInConnection(userId, connection)) {
            throw new BadRequestException("User is not part of this connection");
        }

        // Check if date has happened
        if (connection.getDateScheduledAt() == null) {
            throw new BadRequestException("No date scheduled for this match");
        }

        ZonedDateTime now = ZonedDateTime.now();
        if (connection.getDateScheduledAt().isAfter(now)) {
            throw new BadRequestException("Cannot submit feedback before the date has happened");
        }

        // Find user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Upsert feedback (idempotent)
        DateFeedback feedback = feedbackRepository
                .findByConnectionIdAndUserId(connectionId, userId)
                .orElse(new DateFeedback());

        feedback.setConnection(connection);
        feedback.setUser(user);
        feedback.setDidMeet(request.getDidMeet());
        feedback.setNoShowReason(request.getNoShowReason());
        feedback.setRating(request.getRating());
        feedback.setFeedbackText(request.getFeedbackText());

        feedbackRepository.save(feedback);

        log.info("Feedback submitted for connection {} by user {}: met={}",
                connectionId, userId, request.getDidMeet());

        // Check if both users have submitted feedback
        processCompletedFeedback(connection);
    }

    /**
     * Check if both users submitted feedback and update connection status
     */
    private void processCompletedFeedback(Connection connection) {
        List<DateFeedback> feedbacks = feedbackRepository.findByConnectionId(connection.getId());

        if (feedbacks.size() == 2) {
            // Both users submitted feedback
            boolean bothMet = feedbacks.stream()
                    .allMatch(DateFeedback::getDidMeet);

            if (bothMet) {
                // Success! Both confirmed they met
                connection.setDateStatus("COMPLETED");
                connection.setFeedbackStatus("COMPLETED");

                // Apply bonus to both users
                reputationService.applySuccessBonus(connection.getRequester().getId());
                reputationService.applySuccessBonus(connection.getReceiver().getId());

                log.info("Date COMPLETED successfully for connection {}", connection.getId());
            } else {
                // At least one didn't show
                connection.setDateStatus("NO_SHOW");
                connection.setFeedbackStatus("COMPLETED");

                // Apply penalties
                for (DateFeedback feedback : feedbacks) {
                    if (!feedback.getDidMeet() &&
                            "partner_no_show".equals(feedback.getNoShowReason())) {
                        // User reported partner didn't show
                        UUID reportedUserId = getPartnerUserId(connection, feedback.getUser().getId());
                        reputationService.applyNoShowPenalty(reportedUserId);

                        log.warn("User {} reported no-show for connection {}",
                                reportedUserId, connection.getId());
                    }
                }
            }

            connectionRepository.save(connection);
        }
    }

    /**
     * Get the partner's user ID in a connection
     */
    private UUID getPartnerUserId(Connection connection, UUID userId) {
        if (connection.getRequester().getId().equals(userId)) {
            return connection.getReceiver().getId();
        } else {
            return connection.getRequester().getId();
        }
    }

    /**
     * Check if user is part of the connection
     */
    private boolean isUserInConnection(UUID userId, Connection connection) {
        return connection.getRequester().getId().equals(userId) ||
                connection.getReceiver().getId().equals(userId);
    }

    /**
     * Validate feedback request
     */
    private void validateFeedbackRequest(DateFeedbackRequest request) {
        if (request.getDidMeet() == null) {
            throw new BadRequestException("didMeet field is required");
        }

        if (request.getDidMeet() && request.getRating() == null) {
            throw new BadRequestException("Rating is required when didMeet is true");
        }

        if (!request.getDidMeet() && request.getNoShowReason() == null) {
            throw new BadRequestException("noShowReason is required when didMeet is false");
        }
    }

    /**
     * Check if user has submitted feedback for a connection
     */
    public boolean hasSubmittedFeedback(UUID userId, UUID connectionId) {
        return feedbackRepository.existsByConnectionIdAndUserId(connectionId, userId);
    }
}
