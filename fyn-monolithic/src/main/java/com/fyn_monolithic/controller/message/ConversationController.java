package com.fyn_monolithic.controller.message;

import com.fyn_monolithic.dto.request.message.CreateConversationRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.message.ConversationResponse;
import com.fyn_monolithic.service.message.ConversationService;
import com.fyn_monolithic.mapper.MessageMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationService conversationService;
    private final MessageMapper messageMapper;

    @PostMapping
    public ResponseEntity<ApiResponse<ConversationResponse>> create(
            @Valid @RequestBody CreateConversationRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(conversationService.createConversation(request)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ConversationResponse>>> list() {
        return ResponseEntity.ok(ApiResponse.ok(conversationService.listConversations()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ConversationResponse>> getById(@PathVariable UUID id) {
        var conversation = conversationService.getConversation(id);
        return ResponseEntity.ok(ApiResponse.ok(messageMapper.toConversationResponse(conversation)));
    }
}
