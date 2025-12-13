package com.fyn_monolithic.dto.response.story;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

/**
 * Response for story feed - groups stories by user
 */
@Data
@Builder
public class StoryFeedResponse {
    private List<StoryUserWithStoriesResponse> users;
    private StoryUserWithStoriesResponse currentUser;
}
