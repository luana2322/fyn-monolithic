package com.fyn_monolithic.dto.request.user;

import com.fyn_monolithic.model.user.EducationLevel;
import com.fyn_monolithic.model.user.Gender;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UpdateProfileRequest {

    @Size(max = 120)
    private String fullName;

    @Size(max = 512)
    private String bio;

    @Size(max = 120)
    private String website;

    @Size(max = 120)
    private String location;

    private Gender gender;

    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;

    private EducationLevel educationLevel;
}
