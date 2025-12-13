package com.fyn_monolithic.service.match;

import com.fyn_monolithic.dto.response.match.DiscoverProfileResponse;
import com.fyn_monolithic.model.connection.Connection;
import com.fyn_monolithic.model.connection.ConnectionStatus;
import com.fyn_monolithic.model.connection.ConnectionType;
import com.fyn_monolithic.model.match.SwipeAction;
import com.fyn_monolithic.model.match.SwipeType;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.connection.ConnectionRepository;
import com.fyn_monolithic.repository.match.SwipeActionRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchingService {

    private final SwipeActionRepository swipeActionRepository;
    private final ConnectionRepository connectionRepository;
    private final UserRepository userRepository;

    /**
     * Get potential matches for the discover screen
     * Excludes: current user, already swiped users, blocked users
     */
    public Page<DiscoverProfileResponse> getDiscoverProfiles(UUID userId, String connectionType, Pageable pageable) {
        // Get users already swiped by this user
        Set<UUID> swipedUserIds = swipeActionRepository.findByActorId(userId)
                .stream()
                .map(action -> action.getTarget().getId())
                .collect(Collectors.toSet());
        swipedUserIds.add(userId); // Exclude self

        // Get all active users except swiped ones
        Page<User> potentialMatches = userRepository.findAll(pageable);

        List<DiscoverProfileResponse> profiles = potentialMatches.getContent().stream()
                .filter(user -> !swipedUserIds.contains(user.getId()))
                .map(user -> mapToDiscoverProfile(user, userId))
                .collect(Collectors.toList());

        return new PageImpl<>(profiles, pageable, profiles.size());
    }

    /**
     * Get user's matches (mutual likes)
     */
    public Page<DiscoverProfileResponse> getMatches(UUID userId, String status, Pageable pageable) {
        // Get connections where user is requester or receiver and status is ACCEPTED
        Page<Connection> connections = connectionRepository.findByRequesterIdOrReceiverId(
                userId, userId, pageable);

        List<DiscoverProfileResponse> matches = connections.getContent().stream()
                .filter(c -> c.getStatus() == ConnectionStatus.ACCEPTED)
                .filter(c -> "SWIPE".equals(c.getMatchSource()))
                .map(connection -> {
                    // Get the other user in the connection
                    User other = connection.getRequester().getId().equals(userId)
                            ? connection.getReceiver()
                            : connection.getRequester();
                    return mapToDiscoverProfile(other, userId);
                })
                .collect(Collectors.toList());

        return new PageImpl<>(matches, pageable, matches.size());
    }

    /**
     * Swipe on a user
     */
    @Transactional
    public boolean swipe(UUID actorId, UUID targetId, SwipeType swipeType) {
        if (actorId.equals(targetId)) {
            throw new IllegalArgumentException("Cannot swipe on yourself");
        }

        User actor = userRepository.findById(actorId)
                .orElseThrow(() -> new ResourceNotFoundException("Actor not found"));
        User target = userRepository.findById(targetId)
                .orElseThrow(() -> new ResourceNotFoundException("Target not found"));

        // Check if already swiped
        if (swipeActionRepository.existsByActorIdAndTargetId(actorId, targetId)) {
            return false; // Already swiped
        }

        // Save swipe action
        SwipeAction action = new SwipeAction();
        action.setActor(actor);
        action.setTarget(target);
        action.setActionType(swipeType);
        swipeActionRepository.save(action);

        // Check for match
        if (swipeType == SwipeType.LIKE || swipeType == SwipeType.SUPERLIKE) {
            boolean isMatch = swipeActionRepository.existsByActorIdAndTargetIdAndActionType(
                    targetId, actorId, SwipeType.LIKE) ||
                    swipeActionRepository.existsByActorIdAndTargetIdAndActionType(
                            targetId, actorId, SwipeType.SUPERLIKE);

            if (isMatch) {
                _createMatch(actor, target);
                return true;
            }
        }
        return false;
    }

    /**
     * Block a match (removes connection)
     */
    @Transactional
    public void blockMatch(UUID userId, UUID matchId) {
        // Find and delete the connection
        connectionRepository.findByRequesterIdAndReceiverId(userId, matchId)
                .ifPresent(connectionRepository::delete);
        connectionRepository.findByRequesterIdAndReceiverId(matchId, userId)
                .ifPresent(connectionRepository::delete);
    }

    private void _createMatch(User u1, User u2) {
        // Check if connection already exists
        if (connectionRepository.existsByRequesterIdAndReceiverId(u1.getId(), u2.getId()) ||
                connectionRepository.existsByRequesterIdAndReceiverId(u2.getId(), u1.getId())) {
            return;
        }

        // Create mutual connection
        Connection c1 = new Connection();
        c1.setRequester(u1);
        c1.setReceiver(u2);
        c1.setConnectionType(ConnectionType.FRIEND);
        c1.setStatus(ConnectionStatus.ACCEPTED);
        c1.setMatchSource("SWIPE");
        connectionRepository.save(c1);
    }

    /**
     * Map user entity to discover profile response
     */
    private DiscoverProfileResponse mapToDiscoverProfile(User user, UUID viewerId) {
        // Calculate mock match score (in real app, use matching algorithm)
        double matchScore = 50 + (Math.random() * 50); // 50-100%

        // Get profile data safely
        String bio = null;
        String avatarUrl = null;
        if (user.getProfile() != null) {
            bio = user.getProfile().getBio();
            if (user.getProfile().getAvatarObjectKey() != null) {
                avatarUrl = "/api/v1/files/" + user.getProfile().getAvatarObjectKey();
            }
        }

        return DiscoverProfileResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .bio(bio)
                .photos(avatarUrl != null ? List.of(avatarUrl) : List.of())
                .matchScore(Math.round(matchScore * 10.0) / 10.0)
                .commonInterests(List.of()) // Would be calculated from user interests
                .distanceKm(Math.round(Math.random() * 50 * 10.0) / 10.0) // Mock distance
                .build();
    }
}
