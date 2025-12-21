package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.MeetupConfirmation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MeetupConfirmationRepository extends JpaRepository<MeetupConfirmation, UUID> {

    /**
     * Find confirmation by meetup match and user
     */
    Optional<MeetupConfirmation> findByMeetupMatchIdAndUserId(UUID meetupMatchId, UUID userId);

    /**
     * Find all confirmations for a meetup match
     */
    List<MeetupConfirmation> findByMeetupMatchId(UUID meetupMatchId);

    /**
     * Check if user has confirmed a meetup match
     */
    boolean existsByMeetupMatchIdAndUserId(UUID meetupMatchId, UUID userId);

    /**
     * Count NO_SHOW confirmations for a user (reputation)
     */
    long countByUserIdAndResult(UUID userId, MeetupConfirmation.ConfirmationResult result);
}
