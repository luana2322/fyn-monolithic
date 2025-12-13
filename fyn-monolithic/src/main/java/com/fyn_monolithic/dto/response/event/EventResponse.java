package com.fyn_monolithic.dto.response.event;

import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.model.event.ActivityType;
import com.fyn_monolithic.model.event.EventStatus;
import com.fyn_monolithic.model.event.EventVisibility;
import lombok.Builder;
import lombok.Value;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.AllArgsConstructor;

@Value
@Builder
@AllArgsConstructor
public class EventResponse {
    UUID id;
    String title;
    String slug;
    String description;
    String coverImageUrl;
    ActivityType activityType;
    EventVisibility visibility;
    EventStatus status;

    Boolean isOnline;
    String onlineMeetingUrl;
    Double locationLat;
    Double locationLng;
    String locationName;
    String locationAddress;

    LocalDateTime startTime;
    LocalDateTime endTime;
    String timezone;

    Integer maxParticipants;
    Integer currentParticipants;
    Integer waitlistCount;

    UserResponse createdBy;
    LocalDateTime createdAt;
}
