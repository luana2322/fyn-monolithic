package com.fyn_monolithic.model.date;

import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Meetup entity for group activities with multiple participants
 */
@Entity
@Table(name = "meetups")
@Data
@NoArgsConstructor
public class Meetup {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizer_id", nullable = false)
    private User organizer;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 100)
    private String category; // sports, gaming, music, art, etc.

    @Column(length = 255)
    private String location;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(name = "scheduled_at", nullable = false)
    private ZonedDateTime scheduledAt;

    @Column(name = "duration_minutes")
    private Integer durationMinutes = 120;

    @Column(name = "max_participants")
    private Integer maxParticipants = 10;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MeetupStatus status = MeetupStatus.OPEN;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "meetup_participants", joinColumns = @JoinColumn(name = "meetup_id"), inverseJoinColumns = @JoinColumn(name = "user_id"))
    private List<User> participants = new ArrayList<>();

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    // Helper methods
    public int getParticipantCount() {
        return participants.size();
    }

    public int getSpotsLeft() {
        return maxParticipants - getParticipantCount();
    }

    public boolean isFull() {
        return getSpotsLeft() <= 0;
    }

    public boolean isOpen() {
        return status == MeetupStatus.OPEN && !isFull();
    }

    public boolean canJoin(User user) {
        return isOpen() &&
                !user.getId().equals(organizer.getId()) &&
                !participants.contains(user);
    }
}
