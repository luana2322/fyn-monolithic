package com.fyn_monolithic.repository.user;

import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserSettings;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserSettingsRepository extends JpaRepository<UserSettings, UUID> {
    Optional<UserSettings> findByUser(User user);
}
