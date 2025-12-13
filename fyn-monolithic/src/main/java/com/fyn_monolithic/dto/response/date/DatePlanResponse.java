package com.fyn_monolithic.dto.response.date;

import com.fyn_monolithic.model.date.ConnectionTypeEnum;
import com.fyn_monolithic.model.date.DatePlan;
import com.fyn_monolithic.model.date.DateStatus;
import com.fyn_monolithic.model.date.PlaceType;
import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * Response DTO for date plan details
 */
@Data
@Builder
public class DatePlanResponse {
    private UUID id;
    private String title;
    private String description;
    private UserSummary owner;
    private UserSummary partner;
    private PlaceType placeType;
    private String placeName;
    private String placeAddress;
    private Double latitude;
    private Double longitude;
    private ZonedDateTime scheduledAt;
    private Integer durationMinutes;
    private Boolean isPublic;
    private DateStatus status;
    private ConnectionTypeEnum connectionType;
    private Integer proposalCount;
    private ZonedDateTime createdAt;

    /**
     * Convert entity to response DTO
     */
    public static DatePlanResponse fromEntity(DatePlan entity) {
        return DatePlanResponse.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .description(entity.getDescription())
                .owner(UserSummary.fromUser(entity.getOwner()))
                .partner(entity.getPartner() != null ? UserSummary.fromUser(entity.getPartner()) : null)
                .placeType(entity.getPlaceType())
                .placeName(entity.getPlaceName())
                .placeAddress(entity.getPlaceAddress())
                .latitude(entity.getLatitude())
                .longitude(entity.getLongitude())
                .scheduledAt(entity.getScheduledAt())
                .durationMinutes(entity.getDurationMinutes())
                .isPublic(entity.getIsPublic())
                .status(entity.getStatus())
                .connectionType(entity.getConnectionType())
                .proposalCount(entity.getProposalCount())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
