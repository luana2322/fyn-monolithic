package com.fyn_monolithic.service.message;

import com.fyn_monolithic.dto.request.message.CreateConversationRequest;
import com.fyn_monolithic.dto.response.message.ConversationResponse;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.mapper.MessageMapper;
import com.fyn_monolithic.model.message.Conversation;
import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.message.ConversationType;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.message.ConversationMemberRepository;
import com.fyn_monolithic.repository.message.ConversationRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final ConversationMemberRepository memberRepository;
    private final UserService userService;
    private final MessageMapper messageMapper;

    @Transactional
    public ConversationResponse createConversation(CreateConversationRequest request) {
        User initiator = userService.getCurrentUser();
        Set<User> participants = new HashSet<>();
        participants.add(initiator);
        request.getParticipantIds().forEach(id -> participants.add(userService.findEntity(UUID.fromString(id))));

        if (request.getType() == ConversationType.DIRECT && participants.size() != 2) {
            throw new BadRequestException("Direct conversations must have exactly two members");
        }

        Conversation conversation = new Conversation();
        conversation.setTitle(request.getTitle());
        conversation.setType(request.getType());
        Conversation saved = conversationRepository.save(conversation);

        participants.forEach(user -> {
            ConversationMember member = new ConversationMember();
            member.setConversation(saved);
            member.setMember(user);
            memberRepository.save(member);
            saved.getMembers().add(member);
        });

        return messageMapper.toConversationResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ConversationResponse> listConversations() {
        User user = userService.getCurrentUser();
        List<Conversation> conversations = conversationRepository.findDistinctByMembers_Member(user);
        return conversations.stream().map(messageMapper::toConversationResponse).toList();
    }

    @Transactional(readOnly = true)
    public Conversation getConversation(UUID conversationId) {
        return conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Conversation not found"));
    }
}
