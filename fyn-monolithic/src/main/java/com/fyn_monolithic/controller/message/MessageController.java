package com.fyn_monolithic.controller.message;

import com.fyn_monolithic.dto.request.message.SendMessageRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.message.MessageResponse;
import com.fyn_monolithic.service.message.MessageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/conversations/{conversationId}/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<MessageResponse>> sendMessage(
            @PathVariable UUID conversationId,
            @Valid @RequestPart("payload") SendMessageRequest request,
            @RequestPart(value = "media", required = false) MultipartFile media) throws IOException {
        byte[] mediaBytes = media != null ? media.getBytes() : null;
        return ResponseEntity.ok(ApiResponse.ok(messageService.sendMessage(conversationId, request, mediaBytes)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<MessageResponse>>> getMessages(
            @PathVariable UUID conversationId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ResponseEntity.ok(ApiResponse.ok(messageService.getMessages(conversationId, page, size)));
    }
}
