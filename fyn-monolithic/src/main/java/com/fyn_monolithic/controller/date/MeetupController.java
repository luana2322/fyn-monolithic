package com.fyn_monolithic.controller.date;

import com.fyn_monolithic.dto.request.date.CreateMeetupRequest;
import com.fyn_monolithic.dto.request.date.UpdateMeetupRequest;
import com.fyn_monolithic.dto.request.date.MeetupFeedbackRequest;
import com.fyn_monolithic.dto.request.date.AttendanceConfirmRequest;
import com.fyn_monolithic.dto.response.date.MeetupMatchResponse;
import com.fyn_monolithic.dto.response.date.MeetupResponse;
import com.fyn_monolithic.model.date.AttendanceStatus;
import com.fyn_monolithic.model.date.MatchStatus;
import com.fyn_monolithic.model.date.MeetType;
import com.fyn_monolithic.model.date.MeetupAttendance;
import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.date.AttendanceService;
import com.fyn_monolithic.service.date.MeetupMatchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.ZonedDateTime;
import java.util.Map;
import java.util.UUID;

import static org.springframework.format.annotation.DateTimeFormat.ISO;

@RestController
@RequestMapping("/api/v1/meetups")
@RequiredArgsConstructor
public class MeetupController {

        private final MeetupMatchService meetupMatchService;
        private final AttendanceService attendanceService;

        /**
         * Create a new meetup
         */
        @PostMapping
        public ResponseEntity<Map<String, Object>> createMeetup(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody CreateMeetupRequest request) {

                MeetupResponse meetup = meetupMatchService.createMeetup(userDetails.getUser().getId(), request);
                return ResponseEntity.ok(Map.of("success", true, "data", meetup));
        }

        /**
         * Update an existing meetup
         */
        @PutMapping("/{id}")
        public ResponseEntity<Map<String, Object>> updateMeetup(
                        @PathVariable UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody UpdateMeetupRequest request) {

                MeetupResponse meetup = meetupMatchService.updateMeetup(id, userDetails.getUser().getId(), request);
                return ResponseEntity.ok(Map.of("success", true, "data", meetup));
        }

        /**
         * Get a single meetup by ID
         */
        @GetMapping("/{id}")
        public ResponseEntity<Map<String, Object>> getMeetup(
                        @PathVariable UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                MeetupResponse meetup = meetupMatchService.getMeetupById(id, userDetails.getUser().getId());
                return ResponseEntity.ok(Map.of("success", true, "data", meetup));
        }

        /**
         * Discover nearby meetups with filters
         */
        @GetMapping("/discover")
        public ResponseEntity<Map<String, Object>> discoverMeetups(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false) Double latitude,
                        @RequestParam(required = false) Double longitude,
                        @RequestParam(defaultValue = "10.0") Double radiusKm,
                        @RequestParam(required = false) MeetType meetType,
                        @RequestParam(required = false) String category,
                        @RequestParam(required = false) @DateTimeFormat(iso = ISO.DATE_TIME) ZonedDateTime afterDate,
                        @RequestParam(required = false) String sortBy,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                // Use user's location if not provided
                if (latitude == null || longitude == null) {
                        latitude = userDetails.getUser().getLatitude();
                        longitude = userDetails.getUser().getLongitude();
                }

                if (afterDate == null) {
                        afterDate = ZonedDateTime.now();
                }

                Pageable pageable = PageRequest.of(page, size);
                Page<MeetupResponse> meetups = meetupMatchService.discoverMeetups(
                                userDetails.getUser().getId(),
                                latitude, longitude, radiusKm, meetType, category, afterDate, sortBy, pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", meetups.getContent(),
                                                "page", meetups.getNumber(),
                                                "totalElements", meetups.getTotalElements())));
        }

        /**
         * Get meetups organized by the current user
         */
        @GetMapping
        public ResponseEntity<Map<String, Object>> getMyMeetups(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false) String category,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<MeetupResponse> meetups = meetupMatchService.getMeetupsByOrganizer(
                                userDetails.getUser().getId(),
                                category,
                                pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", meetups.getContent(),
                                                "page", meetups.getNumber(),
                                                "totalElements", meetups.getTotalElements())));
        }

        /**
         * Get meetups that the current user has applied to
         */
        @GetMapping("/my-applied")
        public ResponseEntity<Map<String, Object>> getMyAppliedMeetups(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false) MatchStatus status,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<MeetupMatchResponse> appliedMeetups = meetupMatchService.getMyAppliedMeetups(
                                userDetails.getUser().getId(),
                                status,
                                pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", appliedMeetups.getContent(),
                                                "page", appliedMeetups.getNumber(),
                                                "totalElements", appliedMeetups.getTotalElements())));
        }

        /**
         * Get meetup history (completed, cancelled, expired) for the current user
         */
        @GetMapping("/history")
        public ResponseEntity<Map<String, Object>> getMeetupHistory(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<MeetupResponse> history = meetupMatchService.getMeetupHistory(
                                userDetails.getUser().getId(),
                                pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", history.getContent(),
                                                "page", history.getNumber(),
                                                "totalElements", history.getTotalElements())));
        }

        /**
         * Get meetups awaiting confirmation for the current user
         */
        @GetMapping("/awaiting-confirmation")
        public ResponseEntity<Map<String, Object>> getAwaitingConfirmation(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<MeetupResponse> awaiting = meetupMatchService.getAwaitingConfirmation(
                                userDetails.getUser().getId(),
                                pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", awaiting.getContent(),
                                                "page", awaiting.getNumber(),
                                                "totalElements", awaiting.getTotalElements())));
        }

        /**
         * Apply/Match to a meetup
         */
        @PostMapping("/{id}/match")
        public ResponseEntity<Map<String, Object>> applyToMeetup(
                        @PathVariable("id") UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestBody(required = false) Map<String, String> body) {

                String message = body != null ? body.get("message") : null;
                MeetupMatchResponse match = meetupMatchService.applyToMeetup(
                                id,
                                userDetails.getUser().getId(),
                                message);

                return ResponseEntity.ok(Map.of("success", true, "data", match));
        }

        /**
         * Get match requests for a meetup (organizer only)
         */
        @GetMapping("/{id}/matches")
        public ResponseEntity<Map<String, Object>> getMatchRequests(
                        @PathVariable("id") UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false) MatchStatus status,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<MeetupMatchResponse> matches = meetupMatchService.getMatchRequests(
                                id,
                                userDetails.getUser().getId(),
                                status,
                                pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", matches.getContent(),
                                                "totalElements", matches.getTotalElements())));
        }

        /**
         * Accept a match request
         */
        @PostMapping("/matches/{matchId}/accept")
        public ResponseEntity<Map<String, Object>> acceptMatch(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                meetupMatchService.acceptMatch(matchId, userDetails.getUser().getId());
                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Match accepted and chat created"));
        }

        /**
         * Reject a match request
         */
        @PostMapping("/matches/{matchId}/reject")
        public ResponseEntity<Map<String, Object>> rejectMatch(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                meetupMatchService.rejectMatch(matchId, userDetails.getUser().getId());
                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Match rejected"));
        }

        /**
         * Initiate chat for a match request without accepting it
         */
        @PostMapping("/matches/{matchId}/chat")
        public ResponseEntity<Map<String, Object>> initiateChat(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                MeetupMatchResponse match = meetupMatchService.initiateChat(matchId, userDetails.getUser().getId());
                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", match,
                                "message", "Chat initiated"));
        }

        /**
         * Confirm meetup completion (post-meet) with feedback
         */
        @PostMapping("/{id}/confirm")
        public ResponseEntity<Map<String, Object>> confirmMeetup(
                        @PathVariable UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody MeetupFeedbackRequest request) {

                meetupMatchService.confirmMeetup(id, userDetails.getUser().getId(), request);
                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Meetup confirmation recorded"));
        }

        /**
         * Confirm attendance for a GROUP meetup (new system)
         * Uses AttendanceService for group meetups
         */
        @PostMapping("/{id}/attendance")
        public ResponseEntity<Map<String, Object>> confirmGroupAttendance(
                        @PathVariable UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody AttendanceConfirmRequest request) {

                AttendanceStatus status = AttendanceStatus.fromValue(request.getStatus());
                MeetupAttendance attendance = attendanceService.confirmAttendance(
                                id,
                                userDetails.getUser().getId(),
                                status,
                                request.getFeedback(),
                                request.getRating());

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Attendance confirmed",
                                "data", Map.of(
                                                "status", attendance.getStatus().getValue(),
                                                "confirmedAt", attendance.getConfirmedAt())));
        }

        /**
         * Cancel meetup
         */
        @DeleteMapping("/{id}")
        public ResponseEntity<Map<String, Object>> cancelMeetup(
                        @PathVariable UUID id,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                meetupMatchService.cancelMeetup(id, userDetails.getUser().getId());
                return ResponseEntity.ok(Map.of("success", true, "message", "Meetup cancelled"));
        }
}
