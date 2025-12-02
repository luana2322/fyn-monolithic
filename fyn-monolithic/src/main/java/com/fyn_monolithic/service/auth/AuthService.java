package com.fyn_monolithic.service.auth;

import com.fyn_monolithic.config.RandomStringGenerator;
import com.fyn_monolithic.dto.request.auth.ChangePasswordRequest;
import com.fyn_monolithic.dto.request.auth.ForgotPasswordRequest;
import com.fyn_monolithic.dto.request.auth.LoginRequest;
import com.fyn_monolithic.dto.request.auth.RefreshTokenRequest;
import com.fyn_monolithic.dto.request.auth.RegisterRequest;
import com.fyn_monolithic.dto.request.auth.VerifyOtpRequest;
import com.fyn_monolithic.dto.response.auth.AuthResponse;
import com.fyn_monolithic.dto.response.auth.TokenResponse;
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
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.java.Log;
import lombok.extern.log4j.Log4j;
import lombok.extern.log4j.Log4j2;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Log4j2
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final UserMapper userMapper;

    private final JavaMailSender javaMailSender;
    private final Map<String, String> otpCache = new ConcurrentHashMap<>();
    private RandomStringGenerator randomStringGenerator;
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

    public boolean verifyOtp(VerifyOtpRequest verifyOtpRequest) {
        String cachedOtp = otpCache.get(verifyOtpRequest.getEmail());
        if (cachedOtp != null && cachedOtp.equals(verifyOtpRequest.getOtp())) {
            otpCache.remove(verifyOtpRequest.getEmail()); // xóa sau khi verify thành công
            return true;
        }
        return false;
    }

    public void sendOtp(String email) throws MessagingException {
        String cleanEmail = email.trim();
        if (cleanEmail.isEmpty() || !cleanEmail.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$")) {
            throw new IllegalArgumentException("Email không hợp lệ");
        }

        String otp = generateOtp();

        // Gửi mail
        MimeMessage message = javaMailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setTo(cleanEmail);
        helper.setSubject("Your OTP Code");
        helper.setText("Your OTP code is: " + otp, true);
        javaMailSender.send(message);

        // Lưu vào map tạm
        otpCache.put(cleanEmail, otp);

        log.info("OTP sent to {}: {}", cleanEmail, otp);
    }


    private String generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
