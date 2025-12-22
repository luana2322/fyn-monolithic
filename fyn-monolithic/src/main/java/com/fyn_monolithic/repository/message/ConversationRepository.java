package com.fyn_monolithic.repository.message;

import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {
    List<Conversation> findDistinctByMembers_Member(User member);

    boolean existsByMembersIn(List<ConversationMember> members);

    @EntityGraph(attributePaths = { "members", "members.member", "members.member.profile" })
    Optional<Conversation> findWithMembersById(UUID id);
}
