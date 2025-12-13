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
 * DatePlan entity for scheduling dates and meetups
 */
@Entity
@Table(name = "date_plans")
@Data
@NoArgsConstructor
public class DatePlan {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "partner_id")
    private User partner; // NULL if public/open for proposals

    @Column(nullable = false, length = 255)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "place_type", nullable = false)
    private PlaceType placeType = PlaceType.OTHER;

    @Column(name = "place_name", length = 255)
    private String placeName;

    @Column(name = "place_address", columnDefinition = "TEXT")
    private String placeAddress;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(name = "scheduled_at", nullable = false)
    private ZonedDateTime scheduledAt;

    @Column(name = "duration_minutes")
    private Integer durationMinutes = 120;

    @Column(name = "is_public")
    private Boolean isPublic = false;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DateStatus status = DateStatus.OPEN;

    @Enumerated(EnumType.STRING)
    @Column(name = "connection_type", nullable = false)
    private ConnectionTypeEnum connectionType = ConnectionTypeEnum.DATING;

    @Column(name = "max_proposals")
    private Integer maxProposals = 10;

    @Column(name = "proposal_count")
    private Integer proposalCount = 0;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    // Helper methods
    public boolean isOpen() {
        return status == DateStatus.OPEN;
    }

    public boolean canReceiveProposals() {
        return isOpen() && (proposalCount < maxProposals);
    }
}
