package com.fyn_monolithic.model.message;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.date.MeetupMatch;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;

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

    // Link to meetup match (for match-based conversations)
    @Column(name = "meet_match_id")
    private UUID meetMatchId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meet_match_id", insertable = false, updatable = false)
    private MeetupMatch meetMatch;

    @OneToMany(mappedBy = "conversation")
    private Set<ConversationMember> members = new LinkedHashSet<>();

    @OneToMany(mappedBy = "conversation")
    private Set<Message> messages = new LinkedHashSet<>();
}
