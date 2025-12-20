package com.fyn_monolithic.controller.match;

import com.fyn_monolithic.dto.request.match.SwipeRequest;
import com.fyn_monolithic.dto.response.match.DiscoverProfileResponse;
import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.match.MatchingService;
import jakarta.validation.Valid;
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
@RequestMapping("/api/v1/matches")
@RequiredArgsConstructor
public class MatchingController {

        private final MatchingService matchingService;
        private final com.fyn_monolithic.service.match.DateFeedbackService dateFeedbackService;

        /**
         * Get potential matches for swiping (discover)
         */
        @GetMapping("/discover")
        public ResponseEntity<Map<String, Object>> discover(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false) String type,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<DiscoverProfileResponse> profiles = matchingService.getDiscoverProfiles(
                                userDetails.getUser().getId(), type, pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", profiles.getContent(),
                                                "page", profiles.getNumber(),
                                                "totalPages", profiles.getTotalPages(),
                                                "totalElements", profiles.getTotalElements())));
        }

        /**
         * Swipe on a user (like/dislike/superlike)
         */
        @PostMapping("/swipe")
        public ResponseEntity<Map<String, Object>> swipe(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody SwipeRequest request) {

                boolean isMatch = matchingService.swipe(
                                userDetails.getUser().getId(),
                                request.getTargetUserId(),
                                request.getSwipeType());

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "isMatch", isMatch,
                                "message", isMatch ? "It's a match!" : "Swipe recorded"));
        }

        /**
         * Undo the last swipe action
         */
        @DeleteMapping("/swipe/undo")
        public ResponseEntity<Map<String, Object>> undoLastSwipe(
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                boolean success = matchingService.undoLastSwipe(
                                userDetails.getUser().getId());

                return ResponseEntity.ok(Map.of(
                                "success", success,
                                "message", success ? "Swipe undone" : "No recent swipe to undo"));
        }

        /**
         * Get current user's matches
         */
        @GetMapping
        public ResponseEntity<Map<String, Object>> getMatches(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false) String status,
                        @RequestParam(defaultValue = "0") int page,
                        @RequestParam(defaultValue = "20") int size) {

                Pageable pageable = PageRequest.of(page, size);
                Page<DiscoverProfileResponse> matches = matchingService.getMatches(
                                userDetails.getUser().getId(), status, pageable);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "data", Map.of(
                                                "content", matches.getContent(),
                                                "page", matches.getNumber(),
                                                "totalPages", matches.getTotalPages())));
        }

        /**
         * Block a match
         */
        @PatchMapping("/{matchId}/block")
        public ResponseEntity<Map<String, Object>> blockMatch(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                matchingService.blockMatch(userDetails.getUser().getId(), matchId);
                return ResponseEntity.ok(Map.of("success", true, "message", "Match blocked"));
        }

        /**
         * Cancel a match
         */
        @PatchMapping("/{matchId}/cancel")
        public ResponseEntity<Map<String, Object>> cancelMatch(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                matchingService.cancelMatch(userDetails.getUser().getId(), matchId);
                return ResponseEntity.ok(Map.of("success", true, "message", "Match cancelled"));
        }

        /**
         * Mark match as completed
         */
        @PatchMapping("/{matchId}/complete")
        public ResponseEntity<Map<String, Object>> completeMatch(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                matchingService.completeMatch(userDetails.getUser().getId(), matchId);
                return ResponseEntity.ok(Map.of("success", true, "message", "Match completed"));
        }

        /**
         * Report no-show (applies penalty to other user)
         */
        @PatchMapping("/{matchId}/no-show")
        public ResponseEntity<Map<String, Object>> reportNoShow(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                matchingService.reportNoShow(userDetails.getUser().getId(), matchId);
                return ResponseEntity.ok(Map.of("success", true, "message", "No-show reported, penalty applied"));
        }

        // ==================== Simplified Dating Flow Endpoints ====================

        /**
         * Create date for a match (mandatory after matching)
         * Each match can only have ONE date
         */
        @PostMapping("/{matchId}/date")
        public ResponseEntity<Map<String, Object>> createDateForMatch(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody com.fyn_monolithic.dto.request.match.CreateDateForMatchRequest request) {

                System.out.println("DEBUG: Creating date for match " + matchId);
                System.out.println("DEBUG: scheduledAt = " + request.getScheduledAt());
                System.out.println("DEBUG: description = " + request.getDescription());
                System.out.println("DEBUG: location = " + request.getLocation());

                var connection = matchingService.createDateForMatch(
                                userDetails.getUser().getId(), matchId, request);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Date created successfully",
                                "data", Map.of(
                                                "matchId", connection.getId(),
                                                "dateScheduledAt", connection.getDateScheduledAt(),
                                                "location", Map.of(
                                                                "name", connection.getDateLocationName(),
                                                                "address", connection.getDateLocationAddress(),
                                                                "latitude", connection.getDateLatitude(),
                                                                "longitude", connection.getDateLongitude()),
                                                "description", connection.getDateDescription(),
                                                "status", connection.getDateStatus())));
        }

        /**
         * Update location of an existing date
         */
        @PatchMapping("/{matchId}/location")
        public ResponseEntity<Map<String, Object>> updateDateLocation(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody com.fyn_monolithic.dto.request.match.UpdateDateLocationRequest request) {

                var connection = matchingService.updateDateLocation(
                                userDetails.getUser().getId(), matchId, request);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Location updated",
                                "data", Map.of(
                                                "location", Map.of(
                                                                "name", connection.getDateLocationName(),
                                                                "address", connection.getDateLocationAddress(),
                                                                "latitude", connection.getDateLatitude(),
                                                                "longitude", connection.getDateLongitude()))));
        }

        /**
         * Get match details with full date information
         */
        @GetMapping("/{matchId}")
        public ResponseEntity<Map<String, Object>> getMatchById(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails) {

                var connection = matchingService.getMatchById(
                                userDetails.getUser().getId(), matchId);

                // Get the other user in the connection
                var other = connection.getRequester().getId().equals(userDetails.getUser().getId())
                                ? connection.getReceiver()
                                : connection.getRequester();

                var response = Map.of(
                                "success", true,
                                "data", Map.of(
                                                "id", connection.getId(),
                                                "user", Map.of(
                                                                "id", other.getId(),
                                                                "username", other.getUsername(),
                                                                "fullName",
                                                                other.getFullName() != null ? other.getFullName()
                                                                                : other.getUsername()),
                                                "matchedAt", connection.getRequestedAt(),
                                                "status", connection.getStatus().name(),
                                                "date", connection.getDateScheduledAt() != null ? Map.of(
                                                                "scheduledAt", connection.getDateScheduledAt(),
                                                                "description", connection.getDateDescription(),
                                                                "location", Map.of(
                                                                                "name",
                                                                                connection.getDateLocationName(),
                                                                                "address",
                                                                                connection.getDateLocationAddress(),
                                                                                "latitude",
                                                                                connection.getDateLatitude(),
                                                                                "longitude",
                                                                                connection.getDateLongitude()),
                                                                "status", connection.getDateStatus()) : null));

                return ResponseEntity.ok(response);
        }

        /**
         * Submit post-date feedback (12-24h after date)
         */
        @PostMapping("/{matchId}/feedback")
        public ResponseEntity<Map<String, Object>> submitFeedback(
                        @PathVariable UUID matchId,
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @Valid @RequestBody com.fyn_monolithic.dto.request.match.DateFeedbackRequest request) {

                dateFeedbackService.submitFeedback(
                                userDetails.getUser().getId(), matchId, request);

                return ResponseEntity.ok(Map.of(
                                "success", true,
                                "message", "Feedback submitted successfully"));
        }
}
