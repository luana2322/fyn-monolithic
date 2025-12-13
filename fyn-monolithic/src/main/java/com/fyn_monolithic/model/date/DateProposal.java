package com.fyn_monolithic.model.date;

import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * DateProposal entity for users proposing to join a date
 */
@Entity
@Table(name = "date_proposals", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "date_id", "proposer_id" })
})
@Data
@NoArgsConstructor
public class DateProposal {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "date_id", nullable = false)
    private DatePlan datePlan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "proposer_id", nullable = false)
    private User proposer;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(name = "proposed_time")
    private ZonedDateTime proposedTime; // For counter-proposals

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProposalStatus status = ProposalStatus.PENDING;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    // Helper methods
    public boolean isPending() {
        return status == ProposalStatus.PENDING;
    }

    public boolean isAccepted() {
        return status == ProposalStatus.ACCEPTED;
    }
}
