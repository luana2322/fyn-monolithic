package com.fyn_monolithic.dto.response.user;

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
}
