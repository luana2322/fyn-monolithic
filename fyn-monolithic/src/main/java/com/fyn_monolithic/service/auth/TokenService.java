package com.fyn_monolithic.service.auth;

import com.fyn_monolithic.config.JwtConfig;
import com.fyn_monolithic.dto.response.auth.TokenResponse;
import com.fyn_monolithic.exception.UnauthorizedException;
import com.fyn_monolithic.model.auth.UserToken;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.auth.UserTokenRepository;
import com.fyn_monolithic.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TokenService {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserTokenRepository userTokenRepository;
    private final JwtConfig jwtConfig;

    @Transactional
    public TokenResponse createSession(User user) {
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                user.getUsername(),
                user.getPasswordHash(),
                java.util.List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER"))
        );
        String accessToken = jwtTokenProvider.generateToken(authentication);
        String refreshToken = UUID.randomUUID().toString();
        Instant expiresAt = Instant.now().plusMillis(jwtConfig.getRefreshExpiration());

        UserToken token = new UserToken();
        token.setUser(user);
        token.setRefreshToken(refreshToken);
        token.setExpiresAt(expiresAt);
        userTokenRepository.save(token);

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtConfig.getExpiration())
                .build();
    }

    @Transactional
    public TokenResponse refresh(String refreshToken) {
        UserToken token = userTokenRepository.findByRefreshToken(refreshToken)
                .orElseThrow(() -> new UnauthorizedException("Invalid refresh token"));
        if (token.isRevoked() || token.getExpiresAt().isBefore(Instant.now())) {
            throw new UnauthorizedException("Refresh token expired");
        }
        token.setRevoked(true);
        userTokenRepository.save(token);
        return createSession(token.getUser());
    }

    @Transactional
    public void revoke(String refreshToken) {
        userTokenRepository.findByRefreshToken(refreshToken).ifPresent(token -> {
            token.setRevoked(true);
            userTokenRepository.save(token);
        });
    }

    @Transactional
    public void revokeAll(User user) {
        userTokenRepository.deleteByUser(user);
    }
}
