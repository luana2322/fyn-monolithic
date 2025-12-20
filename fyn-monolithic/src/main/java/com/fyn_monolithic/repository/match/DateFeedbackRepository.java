package com.fyn_monolithic.repository.match;

import com.fyn_monolithic.model.match.DateFeedback;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for DateFeedback entities
 */
@Repository
public interface DateFeedbackRepository extends JpaRepository<DateFeedback, UUID> {

    /**
     * Find feedback by connection and user (for idempot ency check)
     */
    Optional<DateFeedback> findByConnectionIdAndUserId(UUID connectionId, UUID userId);

    /**
     * Find all feedback for a connection (to check if both users submitted)
     */
    List<DateFeedback> findByConnectionId(UUID connectionId);

    /**
     * Check if user submitted feedback for a connection
     */
    boolean existsByConnectionIdAndUserId(UUID connectionId, UUID userId);
}
