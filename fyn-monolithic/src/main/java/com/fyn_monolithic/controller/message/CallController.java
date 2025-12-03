package com.fyn_monolithic.controller.message;

import com.fyn_monolithic.dto.request.message.StartCallRequest;
import com.fyn_monolithic.dto.response.message.CallResponse;
import com.fyn_monolithic.service.message.CallService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/calls")
@RequiredArgsConstructor
public class CallController {

    private final CallService callService;

    @PostMapping
    public ResponseEntity<CallResponse> startCall(
            @Valid @RequestBody StartCallRequest request
    ) {
        return ResponseEntity.ok(callService.startCall(request));
    }

    @PostMapping("/{id}/accept")
    public ResponseEntity<CallResponse> acceptCall(@PathVariable UUID id) {
        return ResponseEntity.ok(callService.acceptCall(id));
    }

    @PostMapping("/{id}/end")
    public ResponseEntity<CallResponse> endCall(@PathVariable UUID id) {
        return ResponseEntity.ok(callService.endCall(id));
    }
}


