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

    @Column(length = 100)
    private String category; // sports, gaming, music, art, etc.

    @Enumerated(EnumType.STRING)
    @Column(name = "meet_type", nullable = false)
    private MeetType meetType = MeetType.GROUP;

    @Column(length = 255)
    private String location;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(name = "scheduled_at", nullable = false)
    private ZonedDateTime scheduledAt;

    @Column(name = "expires_at")
    private ZonedDateTime expiresAt; // When applications close

    @Column(name = "duration_minutes")
    private Integer durationMinutes = 120;

    @Column(name = "max_participants")
    private Integer maxParticipants = 10;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MeetupStatus status = MeetupStatus.OPEN;

    @Enumerated(EnumType.STRING)
    @Column(name = "confirmation_status")
    private ConfirmationStatus confirmationStatus = ConfirmationStatus.NONE;

    @Column(name = "organizer_confirmed")
    private Boolean organizerConfirmed = false;

    @Column(name = "participant_confirmed")
    private Boolean participantConfirmed = false;

    @Column(name = "confirmation_sent_at")
    private ZonedDateTime confirmationSentAt;

    // Accepted participants (approved matches)
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "meetup_participants", joinColumns = @JoinColumn(name = "meetup_id"), inverseJoinColumns = @JoinColumn(name = "user_id"))
    private List<User> acceptedParticipants = new ArrayList<>();

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    // Helper methods
    public int getParticipantCount() {
        return acceptedParticipants.size();
    }

    public int getSpotsLeft() {
        return maxParticipants - getParticipantCount();
    }

    public boolean isFull() {
        return acceptedParticipants.size() >= maxParticipants;
    }

    public boolean isOpen() {
        return status == MeetupStatus.OPEN && !isFull();
    }

    public boolean isOneToOne() {
        return meetType == MeetType.ONE_TO_ONE;
    }

    public boolean needsConfirmation() {
        return scheduledAt.plusHours(12).isBefore(ZonedDateTime.now())
                && status == MeetupStatus.MATCHED
                && (!Boolean.TRUE.equals(organizerConfirmed) || !Boolean.TRUE.equals(participantConfirmed));
    }
}
