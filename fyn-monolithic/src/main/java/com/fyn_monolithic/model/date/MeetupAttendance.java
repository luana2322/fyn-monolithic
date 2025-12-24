package com.fyn_monolithic.model.date;

import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * MeetupAttendance entity for tracking user attendance confirmation after
 * meetup ends
 */
@Entity
@Table(name = "meetup_attendance", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "meetup_id", "user_id" })
})
@Data
@NoArgsConstructor
public class MeetupAttendance {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "meetup_id", nullable = false)
    private UUID meetupId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meetup_id", insertable = false, updatable = false)
    private Meetup meetup;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AttendanceStatus status = AttendanceStatus.PENDING;

    @Column(name = "confirmed_at")
    private ZonedDateTime confirmedAt;

    @Column(columnDefinition = "TEXT")
    private String feedback;

    @Column(precision = 2)
    private Double rating;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;
}
