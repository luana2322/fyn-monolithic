package com.fyn_monolithic.dto.request.user;

import com.fyn_monolithic.model.user.EducationLevel;
import com.fyn_monolithic.model.user.Gender;
import lombok.Data;

import java.time.LocalDate;

@Data
public class SearchUserRequest {
    private Gender gender;
    private Integer minAge;
    private Integer maxAge;
    private String location;
    private Integer maxDistanceKm; // For future proximity search
}
