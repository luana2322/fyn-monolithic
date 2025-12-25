package com.fyn_monolithic.model.moderation;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

/**
 * Entity to log all moderation actions taken by admins
 */
@Getter
@Setter
@Entity
@Table(name = "admin_action_logs")
public class AdminActionLog extends AbstractAuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id", nullable = false)
    private User admin;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false)
    private AdminActionType actionType;

    @Column(name = "target_id", nullable = false)
    private UUID targetId;

    @Column(name = "note", length = 1024)
    private String note;
}
