package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.AttendanceStatus;
import com.fyn_monolithic.model.date.MeetupAttendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MeetupAttendanceRepository extends JpaRepository<MeetupAttendance, UUID> {

    List<MeetupAttendance> findByMeetupId(UUID meetupId);

    Optional<MeetupAttendance> findByMeetupIdAndUserId(UUID meetupId, UUID userId);

    long countByMeetupIdAndStatus(UUID meetupId, AttendanceStatus status);

    boolean existsByMeetupIdAndUserId(UUID meetupId, UUID userId);

    List<MeetupAttendance> findByMeetupIdAndStatus(UUID meetupId, AttendanceStatus status);
}
