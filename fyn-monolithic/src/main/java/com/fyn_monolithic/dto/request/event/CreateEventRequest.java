package com.fyn_monolithic.dto.request.event;

import com.fyn_monolithic.model.event.ActivityType;
import com.fyn_monolithic.model.event.EventVisibility;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Value;

import java.time.LocalDateTime;

@Value
@Builder
public class CreateEventRequest {
    @NotBlank(message = "Title is required")
    String title;

    String description;
    String coverImageUrl;

    @NotNull(message = "Activity type is required")
    ActivityType activityType;

    EventVisibility visibility; // Default PUBLIC handled in service/mapper if null

    Boolean isOnline;
    String onlineMeetingUrl;

    Double locationLat;
    Double locationLng;
    String locationName;
    String locationAddress;
    String locationPlaceId;

    @NotNull(message = "Start time is required")
    @Future(message = "Start time must be in the future")
    LocalDateTime startTime;

    @Future
    LocalDateTime endTime;

    String timezone;
    Integer durationMinutes;

    @Min(2)
    Integer maxParticipants;

    Boolean requiresApproval;
    Boolean allowWaitlist;

    Integer ageMin;
    Integer ageMax;
}
