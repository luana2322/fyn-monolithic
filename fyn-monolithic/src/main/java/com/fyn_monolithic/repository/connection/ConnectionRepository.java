package com.fyn_monolithic.repository.connection;

import com.fyn_monolithic.model.connection.Connection;
import com.fyn_monolithic.model.connection.ConnectionStatus;
import com.fyn_monolithic.model.connection.ConnectionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConnectionRepository extends JpaRepository<Connection, UUID> {

    Optional<Connection> findByRequesterIdAndReceiverIdAndConnectionType(UUID requesterId, UUID receiverId,
            ConnectionType connectionType);

    @Query("SELECT c FROM Connection c WHERE (c.requester.id = :userId OR c.receiver.id = :userId) AND c.status = :status")
    Page<Connection> findByUserIdAndStatus(UUID userId, ConnectionStatus status, Pageable pageable);

    Page<Connection> findByReceiverIdAndStatus(UUID receiverId, ConnectionStatus status, Pageable pageable);

    Page<Connection> findByRequesterIdAndStatus(UUID requesterId, ConnectionStatus status, Pageable pageable);

    // Find connections where user is requester OR receiver
    Page<Connection> findByRequesterIdOrReceiverId(UUID requesterId, UUID receiverId, Pageable pageable);

    // Find connections with eager fetch for users (to avoid
    // LazyInitializationException)
    @Query("SELECT c FROM Connection c " +
            "LEFT JOIN FETCH c.requester r LEFT JOIN FETCH r.profile " +
            "LEFT JOIN FETCH c.receiver v LEFT JOIN FETCH v.profile " +
            "WHERE c.requester.id = :userId OR c.receiver.id = :userId")
    List<Connection> findByUserIdWithUsers(UUID userId);

    // Find specific connection between two users
    Optional<Connection> findByRequesterIdAndReceiverId(UUID requesterId, UUID receiverId);

    // Check if connection exists
    boolean existsByRequesterIdAndReceiverId(UUID requesterId, UUID receiverId);
}
