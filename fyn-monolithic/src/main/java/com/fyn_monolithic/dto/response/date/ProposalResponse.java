package com.fyn_monolithic.dto.response.date;

import com.fyn_monolithic.model.date.DateProposal;
import com.fyn_monolithic.model.date.ProposalStatus;
import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

/**
 * Response DTO for date proposals
 */
@Data
@Builder
public class ProposalResponse {
    private UUID id;
    private UUID dateId;
    private UserSummary proposer;
    private String message;
    private ZonedDateTime proposedTime;
    private ProposalStatus status;
    private ZonedDateTime createdAt;

    public static ProposalResponse fromEntity(DateProposal entity) {
        return ProposalResponse.builder()
                .id(entity.getId())
                .dateId(entity.getDatePlan().getId())
                .proposer(UserSummary.fromUser(entity.getProposer()))
                .message(entity.getMessage())
                .proposedTime(entity.getProposedTime())
                .status(entity.getStatus())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
