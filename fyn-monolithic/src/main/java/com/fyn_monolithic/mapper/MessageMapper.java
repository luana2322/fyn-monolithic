package com.fyn_monolithic.mapper;

import com.fyn_monolithic.dto.response.message.ConversationResponse;
import com.fyn_monolithic.dto.response.message.MessageResponse;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.message.Message;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface MessageMapper {

    @Mapping(target = "memberIds", expression = "java(memberIds(conversation.getMembers()))")
    ConversationResponse toConversationResponse(Conversation conversation);

    @Mapping(target = "conversationId", source = "conversation.id")
    @Mapping(target = "senderId", source = "sender.id")
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
}
