package com.fyn_monolithic.model.date;

import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * Tracks individual user confirmations for meetup outcomes
 * Used for reputation calculation and analytics
 */
@Entity
@Table(name = "meetup_confirmations", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "meetup_match_id", "user_id" })
})
@Data
@NoArgsConstructor
public class MeetupConfirmation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meetup_match_id", nullable = false)
    private MeetupMatch meetupMatch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ConfirmationResult result; // SUCCESS, NO_SHOW

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "confirmed_at", updatable = false)
    private ZonedDateTime confirmedAt;

    public enum ConfirmationResult {
        SUCCESS, // Meetup was successful
        NO_SHOW // Other party didn't show up
    }
}
