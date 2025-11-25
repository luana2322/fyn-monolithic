package com.fyn_monolithic.model.message;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "conversations")
public class Conversation extends AbstractAuditableEntity {

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private ConversationType type = ConversationType.DIRECT;

    @Column(name = "title")
    private String title;

    @OneToMany(mappedBy = "conversation")
    private Set<ConversationMember> members = new LinkedHashSet<>();

    @OneToMany(mappedBy = "conversation")
    private Set<Message> messages = new LinkedHashSet<>();
}
