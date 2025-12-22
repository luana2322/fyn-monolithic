package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.MatchStatus;
import com.fyn_monolithic.model.date.MeetupMatch;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository for MeetupMatch entity
 */
@Repository
public interface MeetupMatchRepository extends JpaRepository<MeetupMatch, UUID> {

        Optional<MeetupMatch> findByMeetupIdAndUserId(UUID meetupId, UUID userId);

        @EntityGraph(attributePaths = { "user", "user.profile" })
        Page<MeetupMatch> findByMeetupIdAndStatus(
                        UUID meetupId,
                        MatchStatus status,
                        Pageable pageable);

        @EntityGraph(attributePaths = { "user", "user.profile" })
        Page<MeetupMatch> findByMeetupId(UUID meetupId, Pageable pageable);

        int countByMeetupIdAndStatus(UUID meetupId, MatchStatus status);

        boolean existsByMeetupIdAndUserId(UUID meetupId, UUID userId);

        // Find user's applied meetups - with eager loading of meetup and user data
        @EntityGraph(attributePaths = { "meetup", "meetup.organizer", "user", "user.profile" })
        Page<MeetupMatch> findByUserIdAndStatus(
                        UUID userId,
                        MatchStatus status,
                        Pageable pageable);

        @EntityGraph(attributePaths = { "meetup", "meetup.organizer", "user", "user.profile" })
        Page<MeetupMatch> findByUserId(UUID userId, Pageable pageable);
}
