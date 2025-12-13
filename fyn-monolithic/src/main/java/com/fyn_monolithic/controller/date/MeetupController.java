package com.fyn_monolithic.controller.date;

import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.date.MeetupService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/meetups")
@RequiredArgsConstructor
public class MeetupController {

    private final MeetupService meetupService;

    /**
     * Create a new meetup
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createMeetup(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, Object> request) {

        Map<String, Object> meetup = meetupService.createMeetup(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(Map.of("success", true, "data", meetup));
    }

    /**
     * Get list of open meetups
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getMeetups(
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size);
        Page<Map<String, Object>> meetups = meetupService.getMeetups(category, pageable);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "content", meetups.getContent(),
                        "page", meetups.getNumber(),
                        "totalPages", meetups.getTotalPages(),
                        "totalElements", meetups.getTotalElements())));
    }

    /**
     * Get meetup details
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getMeetupDetails(@PathVariable UUID id) {
        Map<String, Object> meetup = meetupService.getMeetupDetails(id);
        return ResponseEntity.ok(Map.of("success", true, "data", meetup));
    }

    /**
     * Join a meetup
     */
    @PostMapping("/{id}/join")
    public ResponseEntity<Map<String, Object>> joinMeetup(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        meetupService.joinMeetup(id, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Successfully joined meetup"));
    }

    /**
     * Leave a meetup
     */
    @DeleteMapping("/{id}/leave")
    public ResponseEntity<Map<String, Object>> leaveMeetup(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        meetupService.leaveMeetup(id, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Left meetup"));
    }

    /**
     * Cancel a meetup (organizer only)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> cancelMeetup(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        meetupService.cancelMeetup(id, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Meetup cancelled"));
    }
}
