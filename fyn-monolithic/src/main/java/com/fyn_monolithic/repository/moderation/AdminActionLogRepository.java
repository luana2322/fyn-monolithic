package com.fyn_monolithic.repository.moderation;

import com.fyn_monolithic.model.moderation.AdminActionLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface AdminActionLogRepository extends JpaRepository<AdminActionLog, UUID> {
}
