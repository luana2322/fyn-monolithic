package com.fyn_monolithic.service.auth;

import com.fyn_monolithic.dto.request.auth.ChangePasswordRequest;
import com.fyn_monolithic.dto.request.auth.ForgotPasswordRequest;
import com.fyn_monolithic.dto.request.auth.LoginRequest;
import com.fyn_monolithic.dto.request.auth.RefreshTokenRequest;
import com.fyn_monolithic.dto.request.auth.RegisterRequest;
import com.fyn_monolithic.dto.request.auth.VerifyOtpRequest;
import com.fyn_monolithic.dto.response.auth.AuthResponse;
import com.fyn_monolithic.dto.response.auth.TokenResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserProfile;
import com.fyn_monolithic.model.user.UserSettings;
import com.fyn_monolithic.model.user.UserStatus;
import com.fyn_monolithic.repository.user.UserProfileRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import com.fyn_monolithic.repository.user.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final UserMapper userMapper;

@Transactional
public AuthResponse register(RegisterRequest request) {

    // Kiểm tra email, username, phone
    userRepository.findByEmail(request.getEmail())
            .ifPresent(u -> { throw new BadRequestException("Email already in use"); });
    userRepository.findByUsername(request.getUsername())
            .ifPresent(u -> { throw new BadRequestException("Username already in use"); });
    if (request.getPhone() != null) {
        userRepository.findByPhone(request.getPhone())
                .ifPresent(u -> { throw new BadRequestException("Phone already in use"); });
    }

    // 1️⃣ Tạo User
    User user = new User();
    user.setEmail(request.getEmail());
    user.setPhone(request.getPhone());
    user.setUsername(request.getUsername());
    user.setFullName(request.getFullName());
    user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
    user.setStatus(UserStatus.ACTIVE);

    // 2️⃣ Tạo UserProfile và UserSettings
    UserProfile profile = new UserProfile();
    profile.setUser(user);
    user.setProfile(profile);

    UserSettings settings = new UserSettings();
    settings.setUser(user);
    user.setSettings(settings);

    // 3️⃣ Lưu User (cascade tự lưu profile & settings)
    User savedUser = userRepository.save(user);

    // 4️⃣ Tạo token
    TokenResponse tokenResponse = tokenService.createSession(savedUser);

    return AuthResponse.builder()
            .accessToken(tokenResponse.getAccessToken())
            .refreshToken(tokenResponse.getRefreshToken())
            .expiresIn(tokenResponse.getExpiresIn())
            .user(userMapper.toUserResponse(savedUser))
            .build();
}



//    @Transactional
//    public AuthResponse register(RegisterRequest request) {
//        // Kiểm tra email, username, phone
//        userRepository.findByEmail(request.getEmail()).ifPresent(user -> {
//            throw new BadRequestException("Email already in use");
//        });
//        userRepository.findByUsername(request.getUsername()).ifPresent(user -> {
//            throw new BadRequestException("Username already in use");
//        });
//        if (request.getPhone() != null) {
//            userRepository.findByPhone(request.getPhone()).ifPresent(user -> {
//                throw new BadRequestException("Phone already in use");
//            });
//        }
//
//        // Tạo User mới
//        User user = new User();
//        user.setEmail(request.getEmail());
//        user.setPhone(request.getPhone());
//        user.setUsername(request.getUsername());
//        user.setFullName(request.getFullName());
//        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
//        user.setStatus(UserStatus.ACTIVE);
//
//        // Tạo hoặc lấy UserProfile
//        UserProfile profile = userProfileRepository.findByUser(user)
//                .orElseGet(() -> {
//                    UserProfile p = new UserProfile();
//                    p.setUser(user);
//                    return p;
//                });
//        user.setProfile(profile);
//
//        // Tạo hoặc lấy UserSettings
//        UserSettings settings = userSettingsRepository.findByUser(user)
//                .orElseGet(() -> {
//                    UserSettings s = new UserSettings();
//                    s.setUser(user);
//                    return s;
//                });
//        user.setSettings(settings);
//
//        // Lưu User, Hibernate sẽ tự động lưu profile & settings
//        User saved = userRepository.save(user);
//
//        // Tạo token
//        TokenResponse tokenResponse = tokenService.createSession(saved);
//        UserResponse userResponse = userMapper.toUserResponse(saved);
//
//        return AuthResponse.builder()
//                .accessToken(tokenResponse.getAccessToken())
//                .refreshToken(tokenResponse.getRefreshToken())
//                .expiresIn(tokenResponse.getExpiresIn())
//                .user(userResponse)
//                .build();
//    }


    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getIdentifier())
                .or(() -> userRepository.findByPhone(request.getIdentifier()))
                .or(() -> userRepository.findByUsername(request.getIdentifier()))
                .orElseThrow(() -> new ResourceNotFoundException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Invalid credentials");
        }

        TokenResponse tokenResponse = tokenService.createSession(user);
        return AuthResponse.builder()
                .accessToken(tokenResponse.getAccessToken())
                .refreshToken(tokenResponse.getRefreshToken())
                .expiresIn(tokenResponse.getExpiresIn())
                .user(userMapper.toUserResponse(user))
                .build();
    }

    @Transactional
    public void logout(String refreshToken) {
        tokenService.revoke(refreshToken);
    }

    @Transactional
    public TokenResponse refreshToken(RefreshTokenRequest request) {
        return tokenService.refresh(request.getRefreshToken());
    }

    @Transactional
    public void changePassword(User user, ChangePasswordRequest request) {
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Current password does not match");
        }
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public void forgotPassword(ForgotPasswordRequest request) {
        // Placeholder for OTP or email-based recovery.
    }

    public void verifyOtp(VerifyOtpRequest request) {
        // Placeholder for OTP verification implementation.
    }
}
