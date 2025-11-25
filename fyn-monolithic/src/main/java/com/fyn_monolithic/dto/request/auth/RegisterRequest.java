package com.fyn_monolithic.dto.request.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @Email
    @NotBlank
    private String email;

    @Pattern(regexp = "^\\+?[0-9]{8,15}$", message = "Phone number must be valid E.164 format")
    private String phone;

    @NotBlank
    @Size(min = 3, max = 30)
    private String username;

    @NotBlank
    @Size(min = 8, max = 128)
    private String password;

    @Size(max = 120)
    private String fullName;
}
