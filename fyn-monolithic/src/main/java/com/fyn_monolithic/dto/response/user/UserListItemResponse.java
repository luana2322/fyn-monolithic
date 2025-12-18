package com.fyn_monolithic.dto.response.user;

import com.fyn_monolithic.model.user.Gender;
import lombok.Builder;
import lombok.Value;

import java.util.UUID;

/**
 * Response DTO for user list items in search/discover
 */
@Value
@Builder
public class UserListItemResponse {
    UUID id;
    String username;
    String fullName;
    Integer age;
    Gender gender;
    String bio;
    String avatarUrl;
    String location;
    Double distanceKm; // Distance from current user (optional)
    Boolean isOnline; // Online status (can be implemented later)
    Double reputationScore;
}
