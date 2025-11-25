package com.fyn_monolithic.repository.user;

import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserProfileRepository extends JpaRepository<UserProfile, UUID> {
    Optional<UserProfile> findByUser(User saved);
}
