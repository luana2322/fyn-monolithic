package com.fyn_monolithic.model.date;

import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * MeetupMatch entity represents a user's application/match to join a meetup
 */
@Entity
@Table(name = "meetup_matches", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "meetup_id", "user_id" })
})
@Data
@NoArgsConstructor
public class MeetupMatch {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meetup_id", nullable = false)
    private Meetup meetup;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(columnDefinition = "TEXT")
    private String message; // Message to organizer

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MatchStatus status = MatchStatus.PENDING;

    @Column(name = "conversation_id")
    private UUID conversationId; // Created when approved

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @Column(name = "responded_at")
    private ZonedDateTime respondedAt;
}
