package com.fyn_monolithic.dto.response.date;

import com.fyn_monolithic.model.user.User;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

/**
 * Simplified user info for embedding in responses
 */
@Data
@Builder
public class UserSummary {
    private UUID id;
    private String username;
    private String fullName;
    private String avatarUrl;
    private Integer age;

    public static UserSummary fromUser(User user) {
        if (user == null)
            return null;

        String avatarUrl = null;
        if (user.getProfile() != null && user.getProfile().getAvatarObjectKey() != null) {
            avatarUrl = "/api/v1/files/" + user.getProfile().getAvatarObjectKey();
        }

        return UserSummary.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .avatarUrl(avatarUrl)
                .build();
    }
}
