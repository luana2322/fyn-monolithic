package com.fyn_monolithic.service.message;

import com.fyn_monolithic.dto.response.message.ConversationResponse;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.date.Meetup;
import com.fyn_monolithic.model.message.*;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.message.ConversationMemberRepository;
import com.fyn_monolithic.repository.message.ConversationRepository;
import com.fyn_monolithic.repository.message.MessageRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Service for managing group chats (GROUP_MEETUP and FRIENDS_GROUP)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class GroupChatService {

    private final ConversationRepository conversationRepository;
    private final ConversationMemberRepository conversationMemberRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    // ========================================
    // GROUP MEETUP CHAT
    // ========================================

    /**
     * Create a group chat for a meetup
     * Called when first member is accepted or when organizer manually opens chat
     */
    @Transactional
    public Conversation createMeetupGroupChat(Meetup meetup, User organizer) {
        // Check if group chat already exists
        Optional<Conversation> existing = conversationRepository.findByMeetupId(meetup.getId());
        if (existing.isPresent()) {
            log.info("Group chat already exists for meetup {}", meetup.getId());
            return existing.get();
        }

        // Create new conversation
        Conversation conversation = new Conversation();
        conversation.setType(ConversationType.GROUP_MEETUP);
        conversation.setTitle(meetup.getTitle());
        conversation.setMeetupId(meetup.getId());
        conversation.setIsArchived(false);
        conversation = conversationRepository.save(conversation);

        // Add organizer as ORGANIZER role
        addMemberToGroupChat(conversation, organizer, MemberRole.ORGANIZER);

        // Send system message (organizer as sender)
        sendSystemMessage(conversation, organizer, "👋 Group chat has been created for this meetup");

        log.info("Created group chat {} for meetup {}", conversation.getId(), meetup.getId());
        return conversation;
    }

    /**
     * Get or create group chat for a meetup
     */
    @Transactional
    public Conversation getOrCreateMeetupGroupChat(Meetup meetup, User organizer) {
        return conversationRepository.findByMeetupId(meetup.getId())
                .orElseGet(() -> createMeetupGroupChat(meetup, organizer));
    }

    /**
     * Add a member to the meetup group chat when they are accepted
     */
    @Transactional
    public void addAcceptedMemberToGroupChat(UUID meetupId, User member) {
        Conversation conversation = conversationRepository.findByMeetupId(meetupId)
                .orElseThrow(() -> new ResourceNotFoundException("Group chat not found for meetup: " + meetupId));

        if (!isMemberActive(conversation, member)) {
            addMemberToGroupChat(conversation, member, MemberRole.MEMBER);
            sendSystemMessage(conversation, member, "👋 " + member.getFullName() + " has joined the group");
        }
    }

    /**
     * Archive the group chat when meetup ends or is cancelled
     */
    @Transactional
    public void archiveGroupChat(UUID meetupId) {
        conversationRepository.findByMeetupId(meetupId).ifPresent(conversation -> {
            conversation.setIsArchived(true);
            conversationRepository.save(conversation);
            // Get first admin to send system message
            getFirstAdmin(conversation)
                    .ifPresent(admin -> sendSystemMessage(conversation, admin, "📦 This group chat has been archived"));
            log.info("Archived group chat for meetup {}", meetupId);
        });
    }

    // ========================================
    // FRIENDS GROUP CHAT
    // ========================================

    /**
     * Create a friends group chat
     */
    @Transactional
    public Conversation createFriendsGroupChat(UUID creatorId, String name, List<UUID> memberIds) {
        User creator = getUser(creatorId);

        if (memberIds == null || memberIds.isEmpty()) {
            throw new BadRequestException("At least one member is required to create a group");
        }

        // Validate all members exist
        List<User> members = userRepository.findAllById(memberIds);
        if (members.size() != memberIds.size()) {
            throw new BadRequestException("Some members not found");
        }

        // Create conversation
        Conversation conversation = new Conversation();
        conversation.setType(ConversationType.FRIENDS_GROUP);
        conversation.setTitle(name);
        conversation.setIsArchived(false);
        conversation = conversationRepository.save(conversation);

        // Add creator as ADMIN
        addMemberToGroupChat(conversation, creator, MemberRole.ADMIN);

        // Add other members
        for (User member : members) {
            if (!member.getId().equals(creatorId)) {
                addMemberToGroupChat(conversation, member, MemberRole.MEMBER);
            }
        }

        sendSystemMessage(conversation, creator, "👋 " + creator.getFullName() + " created this group");

        log.info("Created friends group chat {} with {} members", conversation.getId(), members.size() + 1);
        return conversation;
    }

    /**
     * Add a member to a friends group (admin only)
     */
    @Transactional
    public void addMemberToFriendsGroup(UUID conversationId, UUID adminId, UUID memberId) {
        Conversation conversation = getConversation(conversationId);
        User admin = getUser(adminId);
        User member = getUser(memberId);

        // Verify it's a friends group
        if (conversation.getType() != ConversationType.FRIENDS_GROUP) {
            throw new BadRequestException("Can only add members to friends group chats");
        }

        // Verify caller is admin
        if (!isAdmin(conversation, admin)) {
            throw new BadRequestException("Only admins can add members");
        }

        // Check if already a member
        if (isMemberActive(conversation, member)) {
            throw new BadRequestException("User is already a member");
        }

        addMemberToGroupChat(conversation, member, MemberRole.MEMBER);
        sendSystemMessage(conversation, admin, "👋 " + admin.getFullName() + " added " + member.getFullName());
    }

    /**
     * Remove a member from friends group
     */
    @Transactional
    public void removeMemberFromFriendsGroup(UUID conversationId, UUID adminId, UUID memberId) {
        Conversation conversation = getConversation(conversationId);
        User admin = getUser(adminId);
        User member = getUser(memberId);

        // Verify it's a friends group
        if (conversation.getType() != ConversationType.FRIENDS_GROUP) {
            throw new BadRequestException("Can only remove members from friends group chats");
        }

        // Verify caller is admin (or user is removing themselves)
        if (!isAdmin(conversation, admin) && !adminId.equals(memberId)) {
            throw new BadRequestException("Only admins can remove members");
        }

        removeMemberFromGroupChat(conversation, member);
        sendSystemMessage(conversation, admin, "👋 " + member.getFullName() + " left the group");
    }

    /**
     * Update group name (admin only)
     */
    @Transactional
    public Conversation updateGroupName(UUID conversationId, UUID adminId, String newName) {
        Conversation conversation = getConversation(conversationId);
        User admin = getUser(adminId);

        if (!isAdmin(conversation, admin)) {
            throw new BadRequestException("Only admins can rename the group");
        }

        String oldName = conversation.getTitle();
        conversation.setTitle(newName);
        conversationRepository.save(conversation);

        sendSystemMessage(conversation, admin,
                "✏️ " + admin.getFullName() + " renamed the group from \"" + oldName + "\" to \"" + newName + "\"");

        return conversation;
    }

    // ========================================
    // HELPER METHODS
    // ========================================

    private void addMemberToGroupChat(Conversation conversation, User member, MemberRole role) {
        ConversationMember conversationMember = new ConversationMember();
        conversationMember.setConversation(conversation);
        conversationMember.setMember(member);
        conversationMember.setRole(role);
        conversationMember.setAdmin(role == MemberRole.ADMIN || role == MemberRole.ORGANIZER);
        conversationMember.setJoinedAt(ZonedDateTime.now());
        conversationMemberRepository.save(conversationMember);
    }

    private void removeMemberFromGroupChat(Conversation conversation, User member) {
        conversationMemberRepository.findByConversationAndMember(conversation, member)
                .ifPresent(cm -> {
                    cm.setLeftAt(ZonedDateTime.now());
                    conversationMemberRepository.save(cm);
                });
    }

    private boolean isMemberActive(Conversation conversation, User member) {
        return conversationMemberRepository.existsByConversationAndMemberAndLeftAtIsNull(conversation, member);
    }

    private boolean isAdmin(Conversation conversation, User user) {
        return conversationMemberRepository.findByConversationAndMember(conversation, user)
                .map(cm -> cm.isAdmin() && cm.getLeftAt() == null)
                .orElse(false);
    }

    private void sendSystemMessage(Conversation conversation, User sender, String content) {
        Message message = new Message();
        message.setConversation(conversation);
        message.setSender(sender); // Use provided sender for system messages
        message.setContent(content);
        message.setStatus(MessageStatus.SENT);
        messageRepository.save(message);
    }

    private Optional<User> getFirstAdmin(Conversation conversation) {
        return conversationMemberRepository.findByConversationAndAdminTrue(conversation)
                .stream()
                .filter(cm -> cm.getLeftAt() == null)
                .map(ConversationMember::getMember)
                .findFirst();
    }

    private Conversation getConversation(UUID id) {
        return conversationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found: " + id));
    }

    private User getUser(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + id));
    }

    /**
     * Get active member count for a conversation
     */
    public long getActiveMemberCount(UUID conversationId) {
        Conversation conversation = getConversation(conversationId);
        return conversationMemberRepository.countByConversationAndLeftAtIsNull(conversation);
    }

    /**
     * Get group chat by meetup ID
     */
    public Optional<Conversation> getGroupChatByMeetupId(UUID meetupId) {
        return conversationRepository.findByMeetupId(meetupId);
    }
}
