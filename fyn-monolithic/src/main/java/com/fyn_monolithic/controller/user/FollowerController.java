package com.fyn_monolithic.controller.user;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.service.user.FollowerService;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class FollowerController {

    private final FollowerService followerService;

    @PostMapping("/{userId}/follow")
    public ResponseEntity<ApiResponse<Void>> follow(@PathVariable UUID userId) {
        followerService.follow(userId);
        return ResponseEntity.ok(ApiResponse.message("Followed user"));
    }

    @DeleteMapping("/{userId}/follow")
    public ResponseEntity<ApiResponse<Void>> unfollow(@PathVariable UUID userId) {
        followerService.unfollow(userId);
        return ResponseEntity.ok(ApiResponse.message("Unfollowed user"));
    }

    @GetMapping("/{userId}/followers")
    public ResponseEntity<ApiResponse<PageResponse<UserResponse>>> followers(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size) {
        return ResponseEntity.ok(ApiResponse.ok(followerService.followers(userId, page, size)));
    }

    @GetMapping("/{userId}/following")
    public ResponseEntity<ApiResponse<PageResponse<UserResponse>>> following(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size) {
        return ResponseEntity.ok(ApiResponse.ok(followerService.following(userId, page, size)));
    }
}
