package com.fyn_monolithic.model.event;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "events")
public class Event extends AbstractAuditableEntity {

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "slug")
    private String slug;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "cover_image_url")
    private String coverImageUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "activity_type", nullable = false)
    private ActivityType activityType;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility")
    private EventVisibility visibility = EventVisibility.PUBLIC;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private EventStatus status = EventStatus.DRAFT;

    @Column(name = "is_online")
    private Boolean isOnline = false;

    @Column(name = "online_meeting_url")
    private String onlineMeetingUrl;

    @Column(name = "location_lat")
    private Double locationLat;

    @Column(name = "location_lng")
    private Double locationLng;

    @Column(name = "location_name")
    private String locationName;

    @Column(name = "location_address", columnDefinition = "TEXT")
    private String locationAddress;

    @Column(name = "location_place_id")
    private String locationPlaceId;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "timezone")
    private String timezone;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;

    @Column(name = "min_participants")
    private Integer minParticipants = 2;

    @Column(name = "max_participants", nullable = false)
    private Integer maxParticipants;

    @Column(name = "current_participants")
    private Integer currentParticipants = 0;

    @Column(name = "waitlist_count")
    private Integer waitlistCount = 0;

    @Column(name = "requires_approval")
    private Boolean requiresApproval = true;

    @Column(name = "allow_waitlist")
    private Boolean allowWaitlist = true;

    @Column(name = "auto_approve_verified")
    private Boolean autoApproveVerified = false;

    @Column(name = "join_deadline_hours")
    private Integer joinDeadlineHours;

    @Column(name = "age_min")
    private Integer ageMin;

    @Column(name = "age_max")
    private Integer ageMax;

    @Column(name = "gender_preference")
    private String genderPreference;

    @Column(name = "min_reputation_score")
    private Double minReputationScore;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "required_verifications", columnDefinition = "text[]")
    private List<String> requiredVerifications;

    @Column(name = "is_recurring")
    private Boolean isRecurring = false;

    @Column(name = "recurrence_rule")
    private String recurrenceRule;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    // Additional fields omitted for brevity (groupId, chat, price, etc.)
    // Can be added later.
}
