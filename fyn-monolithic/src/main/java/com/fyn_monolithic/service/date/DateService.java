package com.fyn_monolithic.service.date;

import com.fyn_monolithic.dto.request.date.CreateDateRequest;
import com.fyn_monolithic.dto.request.date.ProposalRequest;
import com.fyn_monolithic.dto.response.date.DatePlanResponse;
import com.fyn_monolithic.dto.response.date.ProposalResponse;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.date.*;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.date.DatePlanRepository;
import com.fyn_monolithic.repository.date.DateProposalRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DateService {

    private final DatePlanRepository datePlanRepository;
    private final DateProposalRepository proposalRepository;
    private final UserRepository userRepository;

    /**
     * Create a new date plan
     */
    @Transactional
    public DatePlanResponse createDate(UUID ownerId, CreateDateRequest request) {
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        DatePlan datePlan = new DatePlan();
        datePlan.setOwner(owner);
        datePlan.setTitle(request.getTitle());
        datePlan.setDescription(request.getDescription());
        datePlan.setPlaceType(request.getPlaceType());
        datePlan.setPlaceName(request.getPlaceName());
        datePlan.setPlaceAddress(request.getPlaceAddress());
        datePlan.setLatitude(request.getLatitude());
        datePlan.setLongitude(request.getLongitude());
        datePlan.setScheduledAt(request.getScheduledAt());
        datePlan.setDurationMinutes(request.getDurationMinutes());
        datePlan.setIsPublic(request.getIsPublic());
        datePlan.setConnectionType(request.getConnectionType());
        datePlan.setMaxProposals(request.getMaxProposals());
        datePlan.setStatus(DateStatus.OPEN);

        datePlan = datePlanRepository.save(datePlan);
        return DatePlanResponse.fromEntity(datePlan);
    }

    /**
     * Get public dates for browsing
     */
    public Page<DatePlanResponse> getPublicDates(ConnectionTypeEnum type, Pageable pageable) {
        Page<DatePlan> dates;
        if (type != null) {
            dates = datePlanRepository.findPublicDatesByType(type, pageable);
        } else {
            dates = datePlanRepository.findPublicDates(DateStatus.OPEN, pageable);
        }
        return dates.map(DatePlanResponse::fromEntity);
    }

    /**
     * Get user's own dates
     */
    public Page<DatePlanResponse> getMyDates(UUID userId, DateStatus status, Pageable pageable) {
        Page<DatePlan> dates;
        if (status != null) {
            dates = datePlanRepository.findByOwnerIdAndStatusOrderByScheduledAtDesc(userId, status, pageable);
        } else {
            dates = datePlanRepository.findByOwnerIdOrderByScheduledAtDesc(userId, pageable);
        }
        return dates.map(DatePlanResponse::fromEntity);
    }

    /**
     * Get date details
     */
    public DatePlanResponse getDateDetails(UUID dateId) {
        DatePlan datePlan = datePlanRepository.findById(dateId)
                .orElseThrow(() -> new ResourceNotFoundException("Date not found"));
        return DatePlanResponse.fromEntity(datePlan);
    }

    /**
     * Cancel a date (owner only)
     */
    @Transactional
    public void cancelDate(UUID dateId, UUID userId) {
        DatePlan datePlan = datePlanRepository.findById(dateId)
                .orElseThrow(() -> new ResourceNotFoundException("Date not found"));

        if (!datePlan.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Only the owner can cancel this date");
        }

        datePlan.setStatus(DateStatus.CANCELLED);
        datePlanRepository.save(datePlan);
    }

    /**
     * Mark date as completed
     */
    @Transactional
    public void completeDate(UUID dateId, UUID userId) {
        DatePlan datePlan = datePlanRepository.findById(dateId)
                .orElseThrow(() -> new ResourceNotFoundException("Date not found"));

        if (!datePlan.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Only the owner can complete this date");
        }

        datePlan.setStatus(DateStatus.COMPLETED);
        datePlanRepository.save(datePlan);
    }

    /**
     * Send a proposal to join a date
     */
    @Transactional
    public ProposalResponse sendProposal(UUID dateId, UUID proposerId, ProposalRequest request) {
        DatePlan datePlan = datePlanRepository.findById(dateId)
                .orElseThrow(() -> new ResourceNotFoundException("Date not found"));

        if (!datePlan.canReceiveProposals()) {
            throw new BadRequestException("This date is not accepting proposals");
        }

        if (datePlan.getOwner().getId().equals(proposerId)) {
            throw new BadRequestException("Cannot propose to your own date");
        }

        if (proposalRepository.existsByDatePlanIdAndProposerId(dateId, proposerId)) {
            throw new BadRequestException("You already sent a proposal");
        }

        User proposer = userRepository.findById(proposerId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        DateProposal proposal = new DateProposal();
        proposal.setDatePlan(datePlan);
        proposal.setProposer(proposer);
        proposal.setMessage(request.getMessage());
        proposal.setProposedTime(request.getProposedTime());
        proposal.setStatus(ProposalStatus.PENDING);

        proposal = proposalRepository.save(proposal);

        // Update proposal count
        datePlan.setProposalCount(datePlan.getProposalCount() + 1);
        datePlanRepository.save(datePlan);

        return ProposalResponse.fromEntity(proposal);
    }

    /**
     * Get proposals for a date (owner only)
     */
    public Page<ProposalResponse> getProposals(UUID dateId, UUID userId, Pageable pageable) {
        DatePlan datePlan = datePlanRepository.findById(dateId)
                .orElseThrow(() -> new ResourceNotFoundException("Date not found"));

        if (!datePlan.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Only the owner can view proposals");
        }

        return proposalRepository.findByDatePlanIdOrderByCreatedAtDesc(dateId, pageable)
                .map(ProposalResponse::fromEntity);
    }

    /**
     * Accept a proposal
     */
    @Transactional
    public void acceptProposal(UUID proposalId, UUID userId) {
        DateProposal proposal = proposalRepository.findById(proposalId)
                .orElseThrow(() -> new ResourceNotFoundException("Proposal not found"));

        DatePlan datePlan = proposal.getDatePlan();
        if (!datePlan.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Only the date owner can accept proposals");
        }

        // Accept this proposal
        proposal.setStatus(ProposalStatus.ACCEPTED);
        proposalRepository.save(proposal);

        // Reject all other pending proposals
        proposalRepository.findByDatePlanIdAndStatusOrderByCreatedAtAsc(datePlan.getId(), ProposalStatus.PENDING)
                .forEach(p -> {
                    if (!p.getId().equals(proposalId)) {
                        p.setStatus(ProposalStatus.REJECTED);
                        proposalRepository.save(p);
                    }
                });

        // Update date with partner
        datePlan.setPartner(proposal.getProposer());
        datePlan.setStatus(DateStatus.ACCEPTED);
        datePlanRepository.save(datePlan);
    }

    /**
     * Reject a proposal
     */
    @Transactional
    public void rejectProposal(UUID proposalId, UUID userId) {
        DateProposal proposal = proposalRepository.findById(proposalId)
                .orElseThrow(() -> new ResourceNotFoundException("Proposal not found"));

        DatePlan datePlan = proposal.getDatePlan();
        if (!datePlan.getOwner().getId().equals(userId)) {
            throw new BadRequestException("Only the date owner can reject proposals");
        }

        proposal.setStatus(ProposalStatus.REJECTED);
        proposalRepository.save(proposal);
    }
}
