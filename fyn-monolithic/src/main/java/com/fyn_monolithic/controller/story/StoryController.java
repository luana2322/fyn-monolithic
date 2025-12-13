package com.fyn_monolithic.controller.story;

import com.fyn_monolithic.dto.request.story.CreateStoryRequest;
import com.fyn_monolithic.dto.response.story.*;
import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.story.StoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/stories")
@RequiredArgsConstructor
public class StoryController {

    private final StoryService storyService;

    /**
     * Create a new story
     */
    @PostMapping
    public ResponseEntity<StoryResponse> createStory(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateStoryRequest request) {
        StoryResponse story = storyService.createStory(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(story);
    }

    /**
     * Get story feed (stories from followed users)
     */
    @GetMapping
    public ResponseEntity<StoryFeedResponse> getStoryFeed(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        StoryFeedResponse feed = storyService.getStoryFeed(userDetails.getUser().getId());
        return ResponseEntity.ok(feed);
    }

    /**
     * Get a single story
     */
    @GetMapping("/{storyId}")
    public ResponseEntity<StoryResponse> getStory(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID storyId) {
        StoryResponse story = storyService.getStory(storyId, userDetails.getUser().getId());
        return ResponseEntity.ok(story);
    }

    /**
     * Mark story as viewed
     */
    @PostMapping("/{storyId}/view")
    public ResponseEntity<Map<String, Boolean>> viewStory(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID storyId) {
        storyService.viewStory(storyId, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * Delete own story
     */
    @DeleteMapping("/{storyId}")
    public ResponseEntity<Map<String, Boolean>> deleteStory(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID storyId) {
        storyService.deleteStory(storyId, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("deleted", true));
    }

    /**
     * Get viewers of a story (owner only)
     */
    @GetMapping("/{storyId}/viewers")
    public ResponseEntity<List<StoryUserResponse>> getStoryViewers(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID storyId) {
        List<StoryUserResponse> viewers = storyService.getStoryViewers(storyId, userDetails.getUser().getId());
        return ResponseEntity.ok(viewers);
    }
}
