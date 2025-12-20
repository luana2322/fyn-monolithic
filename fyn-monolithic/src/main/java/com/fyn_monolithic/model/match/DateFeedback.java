package com.fyn_monolithic.model.match;

import com.fyn_monolithic.model.connection.Connection;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * Entity for post-date feedback
 * Submitted by users 12-24h after their scheduled date
 */
@Entity
@Table(name = "date_feedback", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "connection_id", "user_id" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DateFeedback {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "connection_id", nullable = false)
    private Connection connection;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private Boolean didMeet;

    @Column(length = 50)
    private String noShowReason; // partner_no_show, cancelled, other

    @Column(length = 20)
    private String rating; // good, neutral, bad

    @Column(columnDefinition = "TEXT")
    private String feedbackText;

    @CreationTimestamp
    @Column(name = "submitted_at", nullable = false, updatable = false)
    private ZonedDateTime submittedAt;
}
