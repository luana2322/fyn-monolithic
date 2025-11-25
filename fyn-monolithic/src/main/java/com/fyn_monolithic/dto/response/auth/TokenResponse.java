package com.fyn_monolithic.dto.response.auth;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class TokenResponse {
    String accessToken;
    String refreshToken;
    long expiresIn;
}
