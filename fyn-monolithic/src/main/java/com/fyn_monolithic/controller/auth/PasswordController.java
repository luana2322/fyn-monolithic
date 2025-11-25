package com.fyn_monolithic.controller.auth;

import com.fyn_monolithic.dto.request.auth.ChangePasswordRequest;
import com.fyn_monolithic.dto.request.auth.ForgotPasswordRequest;
import com.fyn_monolithic.dto.request.auth.VerifyOtpRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.service.auth.PasswordService;
import com.fyn_monolithic.service.user.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth/password")
@RequiredArgsConstructor
public class PasswordController {

    private final PasswordService passwordService;
    private final UserService userService;

    @PostMapping("/change")
    public ResponseEntity<ApiResponse<Void>> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        passwordService.changePassword(userService.getCurrentUser(), request);
        return ResponseEntity.ok(ApiResponse.message("Password updated"));
    }

    @PostMapping("/forgot")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        passwordService.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.message("OTP sent"));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<Void>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        passwordService.verifyOtp(request);
        return ResponseEntity.ok(ApiResponse.message("OTP verified"));
    }
}
