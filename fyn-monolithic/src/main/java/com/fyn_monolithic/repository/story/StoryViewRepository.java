package com.fyn_monolithic.repository.story;

import com.fyn_monolithic.model.story.StoryView;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StoryViewRepository extends JpaRepository<StoryView, UUID> {

    /**
     * Check if user has viewed a story
     */
    boolean existsByStoryIdAndViewerId(UUID storyId, UUID viewerId);

    /**
     * Find view record for a story by viewer
     */
    Optional<StoryView> findByStoryIdAndViewerId(UUID storyId, UUID viewerId);

    /**
     * Get all views for a story
     */
    List<StoryView> findByStoryIdOrderByViewedAtDesc(UUID storyId);

    /**
     * Get stories viewed by a user
     */
    List<StoryView> findByViewerIdOrderByViewedAtDesc(UUID viewerId);

    /**
     * Count unique viewers for a story
     */
    long countByStoryId(UUID storyId);
}
