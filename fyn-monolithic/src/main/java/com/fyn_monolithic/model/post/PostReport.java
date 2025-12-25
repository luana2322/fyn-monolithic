package com.fyn_monolithic.model.post;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

/**
 * Entity to store reports made by users on posts
 */
@Getter
@Setter
@Entity
@Table(name = "post_reports")
public class PostReport extends AbstractAuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reporter_id", nullable = false)
    private User reporter;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason", nullable = false)
    private ReportReason reason;

    @Column(name = "description", length = 1024)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ReportStatus status = ReportStatus.PENDING;

    @Column(name = "moderation_comment", length = 1024)
    private String moderationComment;
}
