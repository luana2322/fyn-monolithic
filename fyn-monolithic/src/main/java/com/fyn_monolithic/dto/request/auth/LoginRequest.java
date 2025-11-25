package com.fyn_monolithic.dto.request.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank
    private String identifier;

    @NotBlank
    private String password;
}
