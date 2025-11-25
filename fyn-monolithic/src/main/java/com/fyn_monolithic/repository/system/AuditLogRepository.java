package com.fyn_monolithic.repository.system;

import com.fyn_monolithic.model.system.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {
}
