package com.fyn_monolithic.repository.system;

import com.fyn_monolithic.model.system.FileStorage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface FileStorageRepository extends JpaRepository<FileStorage, UUID> {
    Optional<FileStorage> findByObjectKey(String objectKey);
}
