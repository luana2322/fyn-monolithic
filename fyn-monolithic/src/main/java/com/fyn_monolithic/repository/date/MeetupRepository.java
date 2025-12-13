package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.Meetup;
import com.fyn_monolithic.model.date.MeetupStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface MeetupRepository extends JpaRepository<Meetup, UUID> {

    // Find open meetups
    Page<Meetup> findByStatusOrderByScheduledAtAsc(MeetupStatus status, Pageable pageable);

    // Find meetups by category
    Page<Meetup> findByCategoryAndStatusOrderByScheduledAtAsc(
            String category,
            MeetupStatus status,
            Pageable pageable);

    // Find meetups organized by a user
    Page<Meetup> findByOrganizerIdOrderByScheduledAtDesc(UUID organizerId, Pageable pageable);

    // Find meetups user is participating in
    @Query("SELECT m FROM Meetup m JOIN m.participants p WHERE p.id = :userId ORDER BY m.scheduledAt ASC")
    Page<Meetup> findByParticipantId(@Param("userId") UUID userId, Pageable pageable);

    // Count open meetups by category
    long countByCategoryAndStatus(String category, MeetupStatus status);
}
