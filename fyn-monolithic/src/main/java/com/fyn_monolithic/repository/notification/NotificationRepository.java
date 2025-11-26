package com.fyn_monolithic.repository.notification;

import com.fyn_monolithic.model.notification.Notification;
import com.fyn_monolithic.model.notification.NotificationStatus;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    Page<Notification> findByRecipient(User recipient, Pageable pageable);

    long countByRecipientAndStatus(User recipient, NotificationStatus status);
}
