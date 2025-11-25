package com.fyn_monolithic.model.system;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "audit_logs")
public class AuditLog extends AbstractAuditableEntity {

    @Column(name = "actor_id")
    private String actorId;

    @Column(name = "action", nullable = false)
    private String action;

    @Column(name = "resource", nullable = false)
    private String resource;

    @Column(name = "payload", columnDefinition = "jsonb")
    private String payload;
}
