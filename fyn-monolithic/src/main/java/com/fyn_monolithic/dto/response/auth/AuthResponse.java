package com.fyn_monolithic.dto.response.auth;

import com.fyn_monolithic.dto.response.user.UserResponse;
import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class AuthResponse {
    String accessToken;
    String refreshToken;
    long expiresIn;
    UserResponse user;
}
