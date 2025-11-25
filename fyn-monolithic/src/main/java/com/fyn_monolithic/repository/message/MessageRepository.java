package com.fyn_monolithic.repository.message;

import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MessageRepository extends JpaRepository<Message, UUID> {
    Page<Message> findByConversation(Conversation conversation, Pageable pageable);
}
