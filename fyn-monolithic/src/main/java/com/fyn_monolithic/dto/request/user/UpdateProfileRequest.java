package com.fyn_monolithic.dto.request.user;

import jakarta.validation.constraints.Size;
import lombok.Data;

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
}
