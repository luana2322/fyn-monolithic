package com.fyn_monolithic.dto.request.match;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.ZonedDateTime;

/**
 * Request DTO for creating/updating a date for a match
 * Part of the simplified dating flow where dates are mandatory after matching
 */
@Data
public class CreateDateForMatchRequest {

    @NotNull(message = "Scheduled time is required")
    @Future(message = "Date must be in the future")
    private ZonedDateTime scheduledAt;

    @NotBlank(message = "Description is required")
    private String description;

    @NotNull(message = "Location is required")
    @Valid
    private LocationDto location;

    @Data
    public static class LocationDto {
        @NotBlank(message = "Location name is required")
        private String name;

        @NotBlank(message = "Address is required")
        private String address;

        @NotNull(message = "Latitude is required")
        private Double latitude;

        @NotNull(message = "Longitude is required")
        private Double longitude;
    }
}
