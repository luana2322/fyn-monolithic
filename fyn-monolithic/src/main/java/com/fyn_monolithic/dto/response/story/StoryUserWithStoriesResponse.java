package com.fyn_monolithic.dto.response.story;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

/**
 * User with their stories for story feed
 */
@Data
@Builder
public class StoryUserWithStoriesResponse {
    private UUID userId;
    private String username;
    private String fullName;
    private String avatarUrl;
    private int storyCount;
    private boolean allViewed;
    private List<StoryResponse> stories;
}
