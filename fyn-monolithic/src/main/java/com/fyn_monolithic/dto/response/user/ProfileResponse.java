package com.fyn_monolithic.dto.response.user;

import com.fyn_monolithic.model.user.EducationLevel;
import com.fyn_monolithic.model.user.Gender;
import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class ProfileResponse {
    String bio;
    String website;
    String location;
    String avatarUrl;
    boolean isPrivate;
    Gender gender;
    Integer age; // Calculated from dateOfBirth
    EducationLevel educationLevel;
    Double reputationScore;
}
