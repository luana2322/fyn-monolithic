package com.fyn_monolithic.repository.story;

import com.fyn_monolithic.model.story.Story;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface StoryRepository extends JpaRepository<Story, UUID> {

    /**
     * Find active (non-expired) stories by user
     */
    List<Story> findByUserIdAndExpiresAtAfterOrderByCreatedAtDesc(UUID userId, LocalDateTime now);

    /**
     * Find all active stories from connected users (using Connection entity)
     */
    @Query("""
                SELECT s FROM Story s
                WHERE s.user.id IN (
                    SELECT CASE
                        WHEN c.requester.id = :userId THEN c.receiver.id
                        ELSE c.requester.id
                    END
                    FROM Connection c
                    WHERE (c.requester.id = :userId OR c.receiver.id = :userId)
                    AND c.status = 'ACCEPTED'
                )
                AND s.expiresAt > :now
                ORDER BY s.createdAt DESC
            """)
    List<Story> findActiveStoriesFromFollowing(@Param("userId") UUID userId, @Param("now") LocalDateTime now);

    /**
     * Find all active stories from a list of user IDs
     */
    @Query("SELECT s FROM Story s WHERE s.user.id IN :userIds AND s.expiresAt > :now ORDER BY s.createdAt DESC")
    List<Story> findActiveStoriesByUserIds(@Param("userIds") List<UUID> userIds, @Param("now") LocalDateTime now);

    /**
     * Find users who have active stories (using Connection entity)
     */
    @Query("""
                SELECT DISTINCT s.user.id FROM Story s
                WHERE s.user.id IN (
                    SELECT CASE
                        WHEN c.requester.id = :userId THEN c.receiver.id
                        ELSE c.requester.id
                    END
                    FROM Connection c
                    WHERE (c.requester.id = :userId OR c.receiver.id = :userId)
                    AND c.status = 'ACCEPTED'
                )
                AND s.expiresAt > :now
            """)
    List<UUID> findUsersWithActiveStories(@Param("userId") UUID userId, @Param("now") LocalDateTime now);

    /**
     * Delete expired stories (for cleanup job)
     */
    void deleteByExpiresAtBefore(LocalDateTime now);

    /**
     * Count active stories by user
     */
    long countByUserIdAndExpiresAtAfter(UUID userId, LocalDateTime now);
}
