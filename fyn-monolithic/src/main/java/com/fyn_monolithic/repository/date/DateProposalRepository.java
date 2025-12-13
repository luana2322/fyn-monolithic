package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.DateProposal;
import com.fyn_monolithic.model.date.ProposalStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DateProposalRepository extends JpaRepository<DateProposal, UUID> {

    // Find proposals for a specific date
    Page<DateProposal> findByDatePlanIdOrderByCreatedAtDesc(UUID datePlanId, Pageable pageable);

    // Find pending proposals for a date
    List<DateProposal> findByDatePlanIdAndStatusOrderByCreatedAtAsc(UUID datePlanId, ProposalStatus status);

    // Find proposal by date and proposer
    Optional<DateProposal> findByDatePlanIdAndProposerId(UUID datePlanId, UUID proposerId);

    // Check if user already proposed
    boolean existsByDatePlanIdAndProposerId(UUID datePlanId, UUID proposerId);

    // Find all proposals by a user
    Page<DateProposal> findByProposerIdOrderByCreatedAtDesc(UUID proposerId, Pageable pageable);

    // Count pending proposals for a date
    long countByDatePlanIdAndStatus(UUID datePlanId, ProposalStatus status);
}
