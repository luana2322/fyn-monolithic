package com.fyn_monolithic.controller.auth;

import com.fyn_monolithic.dto.request.auth.*;
import com.fyn_monolithic.dto.response.auth.AuthResponse;
import com.fyn_monolithic.dto.response.auth.TokenResponse;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.service.auth.AuthService;
import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.register(request)));
    }


    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.login(request)));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.refreshToken(request)));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.message("Logged out"));
    }
    @PostMapping("/verify")
    public ResponseEntity<ApiResponse<Void>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        boolean verified = authService.verifyOtp(request);

        if (verified) {
            return ResponseEntity.ok(
                    ApiResponse.message("OTP verified successfully, user is now ACTIVE")
            );
        }

        return ResponseEntity.badRequest().body(
                ApiResponse.<Void>builder()
                        .success(false)
                        .message("Invalid OTP or email")
                        .build()
        );
    }

    @PostMapping("/send-otp")
    public ResponseEntity<ApiResponse<Void>> sendOtp(@Valid @RequestBody SendOtpRequest request)
            throws MessagingException {

        // Trim và gửi OTP
        authService.sendOtp(request.getEmail().trim());

        return ResponseEntity.ok(
                ApiResponse.message("OTP has been sent to your email")
        );
    }
    }

