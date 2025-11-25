package com.fyn_monolithic.model.user;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_settings")
public class UserSettings extends AbstractAuditableEntity {

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "is_private", nullable = false)
    private boolean isPrivate = false;

    @Column(name = "allow_messages", nullable = false)
    private boolean allowMessages = true;

    @Column(name = "push_notifications", nullable = false)
    private boolean pushNotifications = true;

    @Column(name = "email_notifications", nullable = false)
    private boolean emailNotifications = true;
}
