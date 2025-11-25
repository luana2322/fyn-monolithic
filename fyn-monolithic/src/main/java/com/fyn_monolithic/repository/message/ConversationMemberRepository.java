package com.fyn_monolithic.repository.message;

import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ConversationMemberRepository extends JpaRepository<ConversationMember, UUID> {
    List<ConversationMember> findByMember(User member);
}
