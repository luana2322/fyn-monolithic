package com.fyn_monolithic.repository.message;

import com.fyn_monolithic.model.message.MessageMedia;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MessageMediaRepository extends JpaRepository<MessageMedia, UUID> {
}
