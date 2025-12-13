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
}
