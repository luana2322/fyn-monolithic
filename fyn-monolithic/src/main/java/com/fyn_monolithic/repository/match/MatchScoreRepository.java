package com.fyn_monolithic.repository.match;

import com.fyn_monolithic.model.match.MatchScore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface MatchScoreRepository extends JpaRepository<MatchScore, UUID> {
    // Basic CRUD for now
}
