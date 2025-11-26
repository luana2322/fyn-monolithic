package com.fyn_monolithic.service.user;

import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserFollower;
import com.fyn_monolithic.repository.user.UserFollowerRepository;
import com.fyn_monolithic.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FollowerService {

    private final UserFollowerRepository followerRepository;
    private final UserService userService;
    private final UserMapper userMapper;
    private final NotificationService notificationService;

    @Transactional
    public void follow(UUID userId) {
        User currentUser = userService.getCurrentUser();
        if (currentUser.getId().equals(userId)) {
            throw new BadRequestException("Cannot follow yourself");
        }
        User target = userService.findEntity(userId);
        followerRepository.findByUserAndFollower(target, currentUser).ifPresent(existing -> {
            throw new BadRequestException("Already following user");
        });
        UserFollower relation = new UserFollower();
        relation.setUser(target);
        relation.setFollower(currentUser);
        followerRepository.save(relation);

        // Tạo thông báo cho người bị follow
        notificationService.notifyNewFollower(target, currentUser);
    }

    @Transactional
    public void unfollow(UUID userId) {
        User currentUser = userService.getCurrentUser();
        User target = userService.findEntity(userId);
        followerRepository.findByUserAndFollower(target, currentUser)
                .ifPresent(followerRepository::delete);
    }

    @Transactional(readOnly = true)
    public PageResponse<UserResponse> followers(UUID userId, int page, int size) {
        User target = userService.findEntity(userId);
        var followers = followerRepository.findByUser(target);
        long total = followers.size();
        return PageResponse.<UserResponse>builder()
                .content(paginate(followers, page, size).stream()
                        .map(UserFollower::getFollower)
                        .map(userMapper::toUserResponse)
                        .collect(Collectors.toList()))
                .page(page)
                .size(size)
                .totalElements(total)
                .totalPages(calculatePages(total, size))
                .build();
    }

    @Transactional(readOnly = true)
    public PageResponse<UserResponse> following(UUID userId, int page, int size) {
        User target = userService.findEntity(userId);
        var following = followerRepository.findByFollower(target);
        long total = following.size();
        return PageResponse.<UserResponse>builder()
                .content(paginate(following, page, size).stream()
                        .map(UserFollower::getUser)
                        .map(userMapper::toUserResponse)
                        .collect(Collectors.toList()))
                .page(page)
                .size(size)
                .totalElements(total)
                .totalPages(calculatePages(total, size))
                .build();
    }

    private <T> List<T> paginate(List<T> data, int page, int size) {
        int fromIndex = Math.min(page * size, data.size());
        int toIndex = Math.min(fromIndex + size, data.size());
        return data.subList(fromIndex, toIndex);
    }

    private int calculatePages(long total, int size) {
        return size == 0 ? 0 : (int) Math.ceil((double) total / size);
    }
}
