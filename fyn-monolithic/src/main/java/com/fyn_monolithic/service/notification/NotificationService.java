package com.fyn_monolithic.service.notification;

import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.notification.NotificationResponse;
import com.fyn_monolithic.mapper.NotificationMapper;
import com.fyn_monolithic.model.notification.Notification;
import com.fyn_monolithic.model.notification.NotificationType;
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

    @Transactional(readOnly = true)
    public long getUnreadCount() {
        User user = userService.getCurrentUser();
        return notificationRepository.countByRecipientAndStatus(user, NotificationStatus.UNREAD);
    }

    @Transactional
    public void notify(User recipient, NotificationType type, UUID referenceId, String message) {
        Notification notification = new Notification();
        notification.setRecipient(recipient);
        notification.setType(type);
        notification.setStatus(NotificationStatus.UNREAD);
        notification.setReferenceId(referenceId);
        notification.setMessage(message);
        notificationRepository.save(notification);
    }

    /**
     * Thông báo tin nhắn mới trong cuộc trò chuyện
     */
    @Transactional
    public void notifyNewMessage(User recipient, UUID conversationId, String previewText) {
        String safePreview = previewText != null && !previewText.isBlank()
                ? previewText
                : "Bạn có tin nhắn mới";
        notify(recipient, NotificationType.MESSAGE, conversationId, safePreview);
    }

    /**
     * Thông báo khi có người mới follow
     */
    @Transactional
    public void notifyNewFollower(User targetUser, User follower) {
        String message = follower.getUsername() != null
                ? follower.getUsername() + " đã bắt đầu theo dõi bạn"
                : "Bạn có người theo dõi mới";
        notify(targetUser, NotificationType.FOLLOW, follower.getId(), message);
    }

    /**
     * Thông báo khi bài viết được like
     */
    @Transactional
    public void notifyPostLiked(User postAuthor, User liker, UUID postId) {
        String message = liker.getUsername() != null
                ? liker.getUsername() + " đã thích bài viết của bạn"
                : "Bài viết của bạn có lượt thích mới";
        notify(postAuthor, NotificationType.LIKE, postId, message);
    }
}
