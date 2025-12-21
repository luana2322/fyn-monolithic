package com.fyn_monolithic.dto.request.date;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fyn_monolithic.model.date.MeetType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.ZonedDateTime;

/**
 * Request DTO for creating a new meetup
 */
public record CreateMeetupRequest(
        @NotBlank(message = "Title is required") String title,
        String description,
        @NotNull(message = "Meet type is required") MeetType meetType,
        String category,
        @NotBlank(message = "Location is required") String location,
        @NotNull(message = "Latitude is required") Double latitude,
        @NotNull(message = "Longitude is required") Double longitude,
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS", timezone = "UTC") @NotNull(message = "Scheduled time is required") ZonedDateTime scheduledAt,
        Integer durationMinutes,
        @NotNull(message = "Max participants is required") Integer maxParticipants,
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS", timezone = "UTC") ZonedDateTime expiresAt // Optional: when
                                                                                                     // applications
                                                                                                     // close
) {
    public CreateMeetupRequest {
        if (meetType == MeetType.ONE_TO_ONE && (maxParticipants == null || maxParticipants != 1)) {
            throw new IllegalArgumentException("1-1 meets must have maxParticipants = 1");
        }
        if (maxParticipants != null && maxParticipants < 1) {
            throw new IllegalArgumentException("Max participants must be at least 1");
        }
    }
}
