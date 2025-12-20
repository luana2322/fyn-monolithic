package com.fyn_monolithic.model.connection;

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
import java.time.ZonedDateTime;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "connections")
public class Connection extends AbstractAuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_id", nullable = false)
    private User receiver;

    @Enumerated(EnumType.STRING)
    @Column(name = "connection_type", nullable = false)
    private ConnectionType connectionType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private ConnectionStatus status = ConnectionStatus.PENDING;

    @Column(name = "match_score")
    private Double matchScore;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "matched_interests", columnDefinition = "text[]")
    private List<String> matchedInterests;

    @Column(name = "match_source")
    private String matchSource;

    @Column(name = "intro_message")
    private String introMessage;

    @Column(name = "response_message")
    private String responseMessage;

    @Column(name = "requested_at")
    private LocalDateTime requestedAt = LocalDateTime.now();

    @Column(name = "responded_at")
    private LocalDateTime respondedAt;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    // Embedded date information (simplified dating flow)
    @Column(name = "date_scheduled_at")
    private ZonedDateTime dateScheduledAt;

    @Column(name = "date_description", columnDefinition = "TEXT")
    private String dateDescription;

    @Column(name = "date_location_name")
    private String dateLocationName;

    @Column(name = "date_location_address", columnDefinition = "TEXT")
    private String dateLocationAddress;

    @Column(name = "date_latitude")
    private Double dateLatitude;

    @Column(name = "date_longitude")
    private Double dateLongitude;

    @Column(name = "date_created_at")
    private ZonedDateTime dateCreatedAt;

    @Column(name = "date_status", length = 20)
    private String dateStatus = "PENDING"; // PENDING, COMPLETED, NO_SHOW, CANCELLED

    @Column(name = "feedback_status", length = 20)
    private String feedbackStatus = "PENDING"; // PENDING, REQUESTED, COMPLETED

    @Column(name = "requester_follows_receiver")
    private Boolean requesterFollowsReceiver = true;

    @Column(name = "receiver_follows_requester")
    private Boolean receiverFollowsRequester = false;
}
