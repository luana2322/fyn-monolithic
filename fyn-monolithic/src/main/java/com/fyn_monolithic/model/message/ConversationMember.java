package com.fyn_monolithic.model.message;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.ZonedDateTime;

@Getter
@Setter
@Entity
@Table(name = "conversation_members")
public class ConversationMember extends AbstractAuditableEntity {

    @ManyToOne
    @JoinColumn(name = "conversation_id", nullable = false)
    private Conversation conversation;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false)
    private User member;

    @Column(name = "is_admin", nullable = false)
    private boolean admin = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private MemberRole role = MemberRole.MEMBER;

    @Column(name = "joined_at")
    private ZonedDateTime joinedAt;

    @Column(name = "left_at")
    private ZonedDateTime leftAt; // Null if still in group
}
