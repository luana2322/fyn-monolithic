package com.fyn_monolithic.dto.response.date;

import com.fyn_monolithic.dto.response.date.UserSummary;
import com.fyn_monolithic.model.date.MatchStatus;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * Response DTO for meetup match/application
 */
public record MeetupMatchResponse(
                UUID id,
                UUID meetupId,
                UserSummary user,
                String message,
                MatchStatus status,
                UUID conversationId,
                ZonedDateTime createdAt,
                ZonedDateTime respondedAt) {
}
