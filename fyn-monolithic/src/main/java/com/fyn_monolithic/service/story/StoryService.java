package com.fyn_monolithic.service.story;

import com.fyn_monolithic.dto.request.story.CreateStoryRequest;
import com.fyn_monolithic.dto.response.story.*;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.story.Story;
import com.fyn_monolithic.model.story.StoryView;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.story.StoryRepository;
import com.fyn_monolithic.repository.story.StoryViewRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StoryService {

    private final StoryRepository storyRepository;
    private final StoryViewRepository storyViewRepository;
    private final UserRepository userRepository;

    @Value("${minio.url:http://localhost:9000}")
    private String minioUrl;

    @Value("${minio.bucket:fyn-uploads}")
    private String bucket;

    private String getMediaBaseUrl() {
        return minioUrl + "/" + bucket;
    }

    /**
     * Create a new story
     */
    @Transactional
    public StoryResponse createStory(UUID userId, CreateStoryRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Story story = Story.builder()
                .user(user)
                .mediaType(request.getMediaType())
                .mediaUrl(request.getMediaUrl())
                .textContent(request.getTextContent())
                .backgroundColor(request.getBackgroundColor())
                .expiresAt(LocalDateTime.now().plusHours(24))
                .build();

        story = storyRepository.save(story);

        return StoryResponse.fromEntity(story, getMediaBaseUrl(), false);
    }

    /**
     * Get story feed for a user (stories from followed users)
     */
    @Transactional(readOnly = true)
    public StoryFeedResponse getStoryFeed(UUID userId) {
        LocalDateTime now = LocalDateTime.now();

        // Get current user's stories
        List<Story> myStories = storyRepository
                .findByUserIdAndExpiresAtAfterOrderByCreatedAtDesc(userId, now);

        // Get stories from followed users
        List<Story> followingStories = storyRepository
                .findActiveStoriesFromFollowing(userId, now);

        // Group stories by user
        Map<UUID, List<Story>> storiesByUser = followingStories.stream()
                .collect(Collectors.groupingBy(s -> s.getUser().getId()));

        // Get viewed story IDs for current user
        Set<UUID> viewedStoryIds = storyViewRepository.findByViewerIdOrderByViewedAtDesc(userId)
                .stream()
                .map(v -> v.getStory().getId())
                .collect(Collectors.toSet());

        // Build response for each user
        List<StoryUserWithStoriesResponse> userResponses = new ArrayList<>();
        for (Map.Entry<UUID, List<Story>> entry : storiesByUser.entrySet()) {
            List<Story> stories = entry.getValue();
            if (stories.isEmpty())
                continue;

            User storyUser = stories.get(0).getUser();
            List<StoryResponse> storyResponses = stories.stream()
                    .map(s -> StoryResponse.fromEntity(s, getMediaBaseUrl(), viewedStoryIds.contains(s.getId())))
                    .collect(Collectors.toList());

            boolean allViewed = storyResponses.stream().allMatch(StoryResponse::isViewedByCurrentUser);

            String avatarUrl = null;
            if (storyUser.getProfile() != null && storyUser.getProfile().getAvatarObjectKey() != null) {
                avatarUrl = getMediaBaseUrl() + "/" + storyUser.getProfile().getAvatarObjectKey();
            }

            userResponses.add(StoryUserWithStoriesResponse.builder()
                    .userId(storyUser.getId())
                    .username(storyUser.getUsername())
                    .fullName(storyUser.getFullName())
                    .avatarUrl(avatarUrl)
                    .storyCount(stories.size())
                    .allViewed(allViewed)
                    .stories(storyResponses)
                    .build());
        }

        // Sort: unviewed first, then by most recent story
        userResponses.sort((a, b) -> {
            if (a.isAllViewed() != b.isAllViewed()) {
                return a.isAllViewed() ? 1 : -1;
            }
            return 0;
        });

        // Build current user response
        StoryUserWithStoriesResponse currentUserResponse = null;
        if (!myStories.isEmpty() || true) { // Always show current user
            User currentUser = userRepository.findById(userId).orElse(null);
            if (currentUser != null) {
                List<StoryResponse> myStoryResponses = myStories.stream()
                        .map(s -> StoryResponse.fromEntity(s, getMediaBaseUrl(), true))
                        .collect(Collectors.toList());

                String avatarUrl = null;
                if (currentUser.getProfile() != null && currentUser.getProfile().getAvatarObjectKey() != null) {
                    avatarUrl = getMediaBaseUrl() + "/" + currentUser.getProfile().getAvatarObjectKey();
                }

                currentUserResponse = StoryUserWithStoriesResponse.builder()
                        .userId(currentUser.getId())
                        .username(currentUser.getUsername())
                        .fullName(currentUser.getFullName())
                        .avatarUrl(avatarUrl)
                        .storyCount(myStories.size())
                        .allViewed(true)
                        .stories(myStoryResponses)
                        .build();
            }
        }

        return StoryFeedResponse.builder()
                .users(userResponses)
                .currentUser(currentUserResponse)
                .build();
    }

    /**
     * Get a single story
     */
    @Transactional(readOnly = true)
    public StoryResponse getStory(UUID storyId, UUID viewerId) {
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> new ResourceNotFoundException("Story not found"));

        boolean viewed = storyViewRepository.existsByStoryIdAndViewerId(storyId, viewerId);
        return StoryResponse.fromEntity(story, getMediaBaseUrl(), viewed);
    }

    /**
     * Mark story as viewed
     */
    @Transactional
    public void viewStory(UUID storyId, UUID viewerId) {
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> new ResourceNotFoundException("Story not found"));

        // Don't count self views
        if (story.getUser().getId().equals(viewerId)) {
            return;
        }

        // Check if already viewed
        if (!storyViewRepository.existsByStoryIdAndViewerId(storyId, viewerId)) {
            User viewer = userRepository.findById(viewerId)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));

            StoryView view = StoryView.builder()
                    .story(story)
                    .viewer(viewer)
                    .build();

            storyViewRepository.save(view);
            story.incrementViewCount();
            storyRepository.save(story);
        }
    }

    /**
     * Delete a story
     */
    @Transactional
    public void deleteStory(UUID storyId, UUID userId) {
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> new ResourceNotFoundException("Story not found"));

        if (!story.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Cannot delete another user's story");
        }

        storyRepository.delete(story);
    }

    /**
     * Get viewers of a story
     */
    @Transactional(readOnly = true)
    public List<StoryUserResponse> getStoryViewers(UUID storyId, UUID ownerId) {
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> new ResourceNotFoundException("Story not found"));

        if (!story.getUser().getId().equals(ownerId)) {
            throw new IllegalArgumentException("Only story owner can view viewers");
        }

        return storyViewRepository.findByStoryIdOrderByViewedAtDesc(storyId)
                .stream()
                .map(v -> StoryUserResponse.fromUser(v.getViewer(), getMediaBaseUrl()))
                .collect(Collectors.toList());
    }
}
