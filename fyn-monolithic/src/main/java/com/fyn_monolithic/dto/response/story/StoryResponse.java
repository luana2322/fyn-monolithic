package com.fyn_monolithic.dto.response.story;

import com.fyn_monolithic.model.story.MediaType;
import com.fyn_monolithic.model.story.Story;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class StoryResponse {
    private UUID id;
    private StoryUserResponse user;
    private MediaType mediaType;
    private String mediaUrl;
    private String textContent;
    private String backgroundColor;
    private Integer viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private boolean viewedByCurrentUser;

    public static StoryResponse fromEntity(Story story, String mediaBaseUrl, boolean viewed) {
        return StoryResponse.builder()
                .id(story.getId())
                .user(StoryUserResponse.fromUser(story.getUser(), mediaBaseUrl))
                .mediaType(story.getMediaType())
                .mediaUrl(mediaBaseUrl + "/" + story.getMediaUrl())
                .textContent(story.getTextContent())
                .backgroundColor(story.getBackgroundColor())
                .viewCount(story.getViewCount())
                .createdAt(story.getCreatedAt())
                .expiresAt(story.getExpiresAt())
                .viewedByCurrentUser(viewed)
                .build();
    }
}
