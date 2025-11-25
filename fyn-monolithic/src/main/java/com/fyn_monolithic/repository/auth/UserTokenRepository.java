package com.fyn_monolithic.repository.auth;

import com.fyn_monolithic.model.auth.UserToken;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserTokenRepository extends JpaRepository<UserToken, UUID> {
    Optional<UserToken> findByRefreshToken(String refreshToken);
    void deleteByUser(User user);
}
