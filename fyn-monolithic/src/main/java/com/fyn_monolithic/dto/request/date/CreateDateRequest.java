package com.fyn_monolithic.dto.request.date;

import com.fyn_monolithic.model.date.ConnectionTypeEnum;
import com.fyn_monolithic.model.date.PlaceType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.ZonedDateTime;

/**
 * Request DTO for creating a new date plan
 */
@Data
public class CreateDateRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotNull(message = "Place type is required")
    private PlaceType placeType;

    private String placeName;
    private String placeAddress;
    private Double latitude;
    private Double longitude;

    @NotNull(message = "Scheduled time is required")
    private ZonedDateTime scheduledAt;

    private Integer durationMinutes = 120;
    private Boolean isPublic = true;
    private ConnectionTypeEnum connectionType = ConnectionTypeEnum.DATING;
    private Integer maxProposals = 10;
}
