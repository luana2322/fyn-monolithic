package com.fyn_monolithic.mapper;

import com.fyn_monolithic.dto.response.message.ConversationResponse;
import com.fyn_monolithic.dto.response.message.MessageResponse;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.message.ConversationType;
import com.fyn_monolithic.model.message.Message;
import com.fyn_monolithic.model.user.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface MessageMapper {

    @Mapping(target = "memberIds", expression = "java(memberIds(conversation.getMembers()))")
    @Mapping(target = "otherUserId", ignore = true)
    @Mapping(target = "otherUserName", ignore = true)
    @Mapping(target = "otherUserAvatar", ignore = true)
    ConversationResponse toConversationResponse(Conversation conversation);

    @Mapping(target = "conversationId", source = "conversation.id")
    @Mapping(target = "senderId", source = "sender.id")
    @Mapping(target = "senderName", source = "sender.username")
    @Mapping(target = "senderAvatar", expression = "java(senderAvatar(message))")
    @Mapping(target = "mediaUrl", expression = "java(mediaUrl(message))")
    @Mapping(target = "reaction", source = "reaction")
    MessageResponse toMessageResponse(Message message);

    default Set<String> memberIds(Set<ConversationMember> members) {
        if (members == null) {
            return Set.of();
        }
        return members.stream()
                .map(member -> member.getMember().getId().toString())
                .collect(Collectors.toSet());
    }

    default String mediaUrl(Message message) {
        if (message.getAttachments() == null || message.getAttachments().isEmpty()) {
            return null;
        }
        return message.getAttachments().iterator().next().getObjectKey();
    }

    default String senderAvatar(Message message) {
        User sender = message.getSender();
        if (sender == null || sender.getProfile() == null) {
            return null;
        }
        return sender.getProfile().getAvatarObjectKey();
    }

    /**
     * Enrich a ConversationResponse with other user info for DIRECT chats.
     */
    default ConversationResponse withOtherUserInfo(Conversation conversation,
                                                   ConversationResponse base,
                                                   UUID currentUserId) {
        if (conversation.getType() != ConversationType.DIRECT) {
            return base;
        }
        if (conversation.getMembers() == null) {
            return base;
        }
        return conversation.getMembers().stream()
                .map(ConversationMember::getMember)
                .filter(user -> !user.getId().equals(currentUserId))
                .findFirst()
                .map(other -> base.toBuilder()
                        .otherUserId(other.getId().toString())
                        .otherUserName(other.getFullName() != null
                                ? other.getFullName()
                                : other.getUsername())
                        .otherUserAvatar(other.getProfile() != null
                                ? other.getProfile().getAvatarObjectKey()
                                : null)
                        .build())
                .orElse(base);
    }
}
