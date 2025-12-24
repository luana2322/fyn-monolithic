package com.fyn_monolithic.dto.response.date;

import com.fyn_monolithic.dto.response.date.UserSummary;
import com.fyn_monolithic.model.date.ConfirmationStatus;
import com.fyn_monolithic.model.date.MeetType;
import com.fyn_monolithic.model.date.MeetupStatus;
import com.fyn_monolithic.model.date.MatchStatus;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * Response DTO for meetup entities
 */
public record MeetupResponse(
        UUID id,
        UserSummary organizer,
        String title,
        String description,
        MeetType meetType,
        String category,
        String location,
        Double latitude,
        Double longitude,
        ZonedDateTime scheduledAt,
        ZonedDateTime expiresAt,
        Integer durationMinutes,
        Integer maxParticipants,
        int acceptedCount,
        int pendingMatchCount,
        MeetupStatus status,
        ConfirmationStatus confirmationStatus,
        Double distanceKm, // Distance from user (calculated)
        boolean userHasApplied,
        MatchStatus userMatchStatus,
        boolean isPast,
        boolean isExpired,
        ZonedDateTime createdAt) {
}
