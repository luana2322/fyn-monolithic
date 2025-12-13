package com.fyn_monolithic.repository.match;

import com.fyn_monolithic.model.match.SwipeAction;
import com.fyn_monolithic.model.match.SwipeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SwipeActionRepository extends JpaRepository<SwipeAction, UUID> {
    Optional<SwipeAction> findByActorIdAndTargetId(UUID actorId, UUID targetId);

    // Find all swipe actions by an actor
    List<SwipeAction> findByActorId(UUID actorId);

    // Check if actor already swiped on target
    boolean existsByActorIdAndTargetId(UUID actorId, UUID targetId);

    // Check if target has already liked actor
    boolean existsByActorIdAndTargetIdAndActionType(UUID actorId, UUID targetId, SwipeType actionType);
}
