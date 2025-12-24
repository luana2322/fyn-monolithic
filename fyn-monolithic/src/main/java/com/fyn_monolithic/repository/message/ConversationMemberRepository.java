package com.fyn_monolithic.repository.message;

import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConversationMemberRepository extends JpaRepository<ConversationMember, UUID> {
    List<ConversationMember> findByMember(User member);

    // Find member in a conversation
    Optional<ConversationMember> findByConversationAndMember(Conversation conversation, User member);

    // Find all active members in a conversation (not left)
    List<ConversationMember> findByConversationAndLeftAtIsNull(Conversation conversation);

    // Check if user is a member
    boolean existsByConversationAndMemberAndLeftAtIsNull(Conversation conversation, User member);

    // Count active members
    long countByConversationAndLeftAtIsNull(Conversation conversation);

    // Find admins in a conversation
    List<ConversationMember> findByConversationAndAdminTrue(Conversation conversation);
}
