package com.fyn_monolithic.repository.auth;

import com.fyn_monolithic.model.auth.UserLoginHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface UserLoginHistoryRepository extends JpaRepository<UserLoginHistory, UUID> {
}
