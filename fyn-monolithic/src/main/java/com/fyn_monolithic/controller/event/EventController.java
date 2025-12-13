package com.fyn_monolithic.controller.event;

import com.fyn_monolithic.dto.request.event.CreateEventRequest;
import com.fyn_monolithic.dto.response.event.EventResponse;
import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.event.EventService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateEventRequest request) {
        return ResponseEntity.ok(eventService.createEvent(userDetails.getUser().getId(), request));
    }

    @GetMapping
    public ResponseEntity<Page<EventResponse>> getEvents(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(defaultValue = "10000") Double radius,
            Pageable pageable) {
        return ResponseEntity.ok(eventService.getNearbyEvents(lat, lng, radius, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventResponse> getEvent(@PathVariable UUID id) {
        return ResponseEntity.ok(eventService.getEvent(id));
    }
}
