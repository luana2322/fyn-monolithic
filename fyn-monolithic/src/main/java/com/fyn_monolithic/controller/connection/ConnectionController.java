package com.fyn_monolithic.controller.connection;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.model.connection.Connection;
import com.fyn_monolithic.model.connection.ConnectionStatus;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.connection.ConnectionRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller for managing user connections/follows
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/connections")
@RequiredArgsConstructor
public class ConnectionController {

    private final ConnectionRepository connectionRepository;
    private final UserService userService;

    /**
     * Get list of user IDs that the current user is following
     * 
     * @return List of followed user IDs
     */
    @GetMapping("/following/ids")
    public ResponseEntity<ApiResponse<List<String>>> getFollowingUserIds() {
        User currentUser = userService.getCurrentUser();

        log.debug("Getting followed user IDs for user: {}", currentUser.getId());

        // Find all connections where current user is following
        List<Connection> connections = connectionRepository
                .findAllByRequesterIdAndStatus(currentUser.getId(), ConnectionStatus.ACCEPTED);

        // Extract receiver IDs (users being followed)
        List<String> followedUserIds = connections.stream()
                .filter(conn -> Boolean.TRUE.equals(conn.getRequesterFollowsReceiver()))
                .map(conn -> conn.getReceiver().getId().toString())
                .collect(Collectors.toList());

        // Also check where current user is the receiver
        List<Connection> receivedConnections = connectionRepository
                .findAllByReceiverIdAndStatus(currentUser.getId(), ConnectionStatus.ACCEPTED);

        followedUserIds.addAll(
                receivedConnections.stream()
                        .filter(conn -> Boolean.TRUE.equals(conn.getReceiverFollowsRequester()))
                        .map(conn -> conn.getRequester().getId().toString())
                        .collect(Collectors.toList()));

        log.debug("Found {} followed users", followedUserIds.size());

        return ResponseEntity.ok(ApiResponse.ok(followedUserIds));
    }

    /**
     * Follow a user (create or update connection)
     * 
     * @param userId ID of user to follow
     * @return Success response
     */
    @PostMapping("/follow/{userId}")
    public ResponseEntity<ApiResponse<Void>> followUser(@PathVariable String userId) {
        User currentUser = userService.getCurrentUser();

        log.debug("User {} following user {}", currentUser.getId(), userId);

        // TODO: Implement follow logic
        // 1. Check if connection exists
        // 2. If exists, update requesterFollowsReceiver = true
        // 3. If not, create new connection with status ACCEPTED

        return ResponseEntity.ok(ApiResponse.message("Successfully followed user"));
    }

    /**
     * Unfollow a user
     * 
     * @param userId ID of user to unfollow
     * @return Success response
     */
    @DeleteMapping("/follow/{userId}")
    public ResponseEntity<ApiResponse<Void>> unfollowUser(@PathVariable String userId) {
        User currentUser = userService.getCurrentUser();

        log.debug("User {} unfollowing user {}", currentUser.getId(), userId);

        // TODO: Implement unfollow logic
        // Update requesterFollowsReceiver = false

        return ResponseEntity.ok(ApiResponse.message("Successfully unfollowed user"));
    }
}
