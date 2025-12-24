package com.fyn_monolithic.controller.message;

import com.fyn_monolithic.dto.request.message.CreateGroupRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.message.GroupChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

/**
 * Controller for managing group chats (FRIENDS_GROUP)
 * GROUP_MEETUP chats are automatically managed through MeetupController
 */
@RestController
@RequestMapping("/api/v1/groups")
@RequiredArgsConstructor
public class GroupChatController {

    private final GroupChatService groupChatService;

    /**
     * Create a new friends group chat
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> createFriendsGroup(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateGroupRequest request) {

        Conversation conversation = groupChatService.createFriendsGroupChat(
                userDetails.getUser().getId(),
                request.getName(),
                request.getMemberIds());

        return ResponseEntity.ok(ApiResponse.ok(Map.of(
                "conversationId", conversation.getId(),
                "title", conversation.getTitle(),
                "type", conversation.getType().name(),
                "memberCount", groupChatService.getActiveMemberCount(conversation.getId()))));
    }

    /**
     * Add a member to a friends group
     */
    @PostMapping("/{id}/members")
    public ResponseEntity<ApiResponse<String>> addMember(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, UUID> body) {

        UUID newMemberId = body.get("userId");
        groupChatService.addMemberToFriendsGroup(id, userDetails.getUser().getId(), newMemberId);

        return ResponseEntity.ok(ApiResponse.message("Member added successfully"));
    }

    /**
     * Remove a member from a friends group
     */
    @DeleteMapping("/{id}/members/{userId}")
    public ResponseEntity<ApiResponse<String>> removeMember(
            @PathVariable UUID id,
            @PathVariable UUID userId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        groupChatService.removeMemberFromFriendsGroup(id, userDetails.getUser().getId(), userId);

        return ResponseEntity.ok(ApiResponse.message("Member removed successfully"));
    }

    /**
     * Update group name
     */
    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateGroup(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, String> body) {

        String newName = body.get("name");
        Conversation conversation = groupChatService.updateGroupName(id, userDetails.getUser().getId(), newName);

        return ResponseEntity.ok(ApiResponse.ok(Map.of(
                "conversationId", conversation.getId(),
                "title", conversation.getTitle())));
    }
}
