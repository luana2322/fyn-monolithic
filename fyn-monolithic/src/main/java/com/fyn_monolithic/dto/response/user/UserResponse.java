package com.fyn_monolithic.dto.response.user;

import com.fyn_monolithic.model.user.UserStatus;
import lombok.Builder;
import lombok.Value;

import java.util.UUID;

@Value
@Builder
@lombok.AllArgsConstructor(access = lombok.AccessLevel.PUBLIC)
public class UserResponse {
    UUID id;
    String username;
    String email;
    String phone;
    String fullName;
    UserStatus status;
    String role;
    ProfileResponse profile;
}
