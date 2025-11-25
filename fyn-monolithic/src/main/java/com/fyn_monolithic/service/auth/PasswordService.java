package com.fyn_monolithic.service.auth;

import com.fyn_monolithic.dto.request.auth.ChangePasswordRequest;
import com.fyn_monolithic.dto.request.auth.ForgotPasswordRequest;
import com.fyn_monolithic.dto.request.auth.VerifyOtpRequest;
import com.fyn_monolithic.model.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PasswordService {

    private final AuthService authService;

    public void changePassword(User user, ChangePasswordRequest request) {
        authService.changePassword(user, request);
    }

    public void forgotPassword(ForgotPasswordRequest request) {
        authService.forgotPassword(request);
    }

    public void verifyOtp(VerifyOtpRequest request) {
        authService.verifyOtp(request);
    }
}
