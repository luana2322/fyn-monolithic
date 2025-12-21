package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.Meetup;
import com.fyn_monolithic.model.date.MeetupStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
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

        // Find meetups organized by a user (with eager fetch to prevent lazy loading
        // issues)
        @EntityGraph(attributePaths = { "organizer", "organizer.profile", "acceptedParticipants" })
        Page<Meetup> findByOrganizerIdOrderByScheduledAtDesc(UUID organizerId, Pageable pageable);

        // Find meetups user is participating in (through accepted matches)
        @Query("SELECT DISTINCT m FROM Meetup m " +
                        "JOIN MeetupMatch match ON match.meetup.id = m.id " +
                        "WHERE match.user.id = :userId " +
                        "AND match.status = 'ACCEPTED' " +
                        "ORDER BY m.scheduledAt ASC")
        Page<Meetup> findByParticipantId(@Param("userId") UUID userId, Pageable pageable);

        // Count open meetups by category
        long countByCategoryAndStatus(String category, MeetupStatus status);

        // NEW: Find nearby meets with smart filters
        // Excludes: expired, user's own meets, already applied
        // Note: Sorting is handled by Pageable due to PostgreSQL DISTINCT + ORDER BY
        // restrictions
        @EntityGraph(attributePaths = { "organizer", "organizer.profile", "acceptedParticipants" })
        @Query("""
                            SELECT m FROM Meetup m
                            WHERE m.id NOT IN (
                                SELECT mm.meetup.id FROM MeetupMatch mm
                                WHERE mm.user.id = :userId AND mm.status IN ('PENDING', 'ACCEPTED')
                            )
                            AND m.status IN ('OPEN', 'MATCHED')
                            AND m.organizer.id != :userId
                            AND (:meetType IS NULL OR m.meetType = :meetType)
                            AND (:category IS NULL OR m.category = :category)
                            AND m.scheduledAt > :afterDate
                            AND (6371 * acos(
                                cos(radians(:latitude)) * cos(radians(m.latitude)) *
                                cos(radians(m.longitude) - radians(:longitude)) +
                                sin(radians(:latitude)) * sin(radians(m.latitude))
                            )) <= :radiusKm
                            ORDER BY m.scheduledAt ASC
                        """)
        Page<Meetup> findNearbyMeetups(
                        @Param("userId") UUID userId,
                        @Param("latitude") Double latitude,
                        @Param("longitude") Double longitude,
                        @Param("radiusKm") Double radiusKm,
                        @Param("meetType") com.fyn_monolithic.model.date.MeetType meetType,
                        @Param("category") String category,
                        @Param("afterDate") java.time.ZonedDateTime afterDate,
                        @Param("sortBy") String sortBy,
                        Pageable pageable);

        // Find meets needing confirmation (12h+ after scheduled time)
        @Query("""
                            SELECT m FROM Meetup m
                            WHERE m.status = 'MATCHED'
                            AND m.scheduledAt <= :beforeDate
                            AND (m.organizerConfirmed = false OR m.participantConfirmed = false)
                            AND m.confirmationSentAt IS NULL
                        """)
        java.util.List<Meetup> findMeetupsNeedingConfirmation(@Param("beforeDate") java.time.ZonedDateTime beforeDate);

        // Find meetups by status and scheduled between dates (for reminder/confirmation
        // jobs)
        java.util.List<Meetup> findByStatusAndScheduledAtBetween(
                        MeetupStatus status,
                        java.time.ZonedDateTime startDate,
                        java.time.ZonedDateTime endDate);

        // Find meetups by status scheduled before a date (for auto NO_SHOW)
        java.util.List<Meetup> findByStatusAndScheduledAtBefore(
                        MeetupStatus status,
                        java.time.ZonedDateTime beforeDate);
}
