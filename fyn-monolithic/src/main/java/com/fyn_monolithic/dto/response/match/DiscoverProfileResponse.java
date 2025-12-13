package com.fyn_monolithic.dto.response.match;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

/**
 * Response DTO for discover/matching profiles
 */
@Data
@Builder
public class DiscoverProfileResponse {
    private UUID userId;
    private String username;
    private String fullName;
    private Integer age;
    private String bio;
    private String gender;
    private List<String> photos;
    private List<String> interests;
    private Double matchScore;
    private List<String> commonInterests;
    private Double distanceKm;
}
