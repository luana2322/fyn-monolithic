package com.fyn_monolithic.dto.response.story;

import com.fyn_monolithic.model.user.User;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class StoryUserResponse {
    private UUID id;
    private String username;
    private String fullName;
    private String avatarUrl;
    private boolean hasActiveStories;
    private int storyCount;

    public static StoryUserResponse fromUser(User user, String mediaBaseUrl) {
        String avatarUrl = null;
        if (user.getProfile() != null && user.getProfile().getAvatarObjectKey() != null) {
            avatarUrl = mediaBaseUrl + "/" + user.getProfile().getAvatarObjectKey();
        }

        return StoryUserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getProfile() != null ? user.getProfile().getBio() : null)
                .avatarUrl(avatarUrl)
                .hasActiveStories(true)
                .storyCount(0)
                .build();
    }
}
