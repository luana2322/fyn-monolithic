package com.fyn_monolithic.controller.user;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> currentUser() {
        return ResponseEntity.ok(ApiResponse.ok(userService.getCurrentUserProfile()));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok(userService.getUser(userId)));
    }

    @GetMapping("/username/{username}")
    public ResponseEntity<ApiResponse<UserResponse>> getByUsername(@PathVariable String username) {
        return ResponseEntity.ok(ApiResponse.ok(userService.getByUsername(username)));
    }
}
