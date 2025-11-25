package com.fyn_monolithic.service.notification;

import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.notification.NotificationResponse;
import com.fyn_monolithic.mapper.NotificationMapper;
import com.fyn_monolithic.model.notification.Notification;
import com.fyn_monolithic.model.notification.NotificationStatus;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.notification.NotificationRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserService userService;
    private final NotificationMapper notificationMapper;

    @Transactional(readOnly = true)
    public PageResponse<NotificationResponse> list(int page, int size) {
        User user = userService.getCurrentUser();
        Page<Notification> result = notificationRepository.findByRecipient(user, PageRequest.of(page, size));
        return PageResponse.<NotificationResponse>builder()
                .content(result.getContent().stream().map(notificationMapper::toResponse).toList())
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build();
    }

    @Transactional
    public void markAsRead(UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));
        notification.setStatus(NotificationStatus.READ);
        notificationRepository.save(notification);
    }
}
