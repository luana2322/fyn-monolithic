package com.fyn_monolithic.repository.event;

import com.fyn_monolithic.model.event.Event;
import com.fyn_monolithic.model.event.EventStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.UUID;

@Repository
public interface EventRepository extends JpaRepository<Event, UUID> {

    @Query(value = """
            SELECT * FROM events e
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(e.location_lng, e.location_lat), 4326),
                ST_SetSRID(ST_MakePoint(:lng, :lat), 4326),
                :radiusInMeters
            )
            AND e.status = 'OPEN'
            AND e.visibility = 'PUBLIC'
            AND e.start_time > :afterTime
            """, nativeQuery = true)
    Page<Event> findNearbyPublicEvents(
            @Param("lat") double lat,
            @Param("lng") double lng,
            @Param("radiusInMeters") double radiusInMeters,
            @Param("afterTime") LocalDateTime afterTime,
            Pageable pageable);

    Page<Event> findByStatusAndStartTimeAfter(EventStatus status, LocalDateTime startTime, Pageable pageable);

    @Query("SELECT e FROM Event e WHERE e.createdBy.id = :userId")
    Page<Event> findCreatedEvents(UUID userId, Pageable pageable);
}
