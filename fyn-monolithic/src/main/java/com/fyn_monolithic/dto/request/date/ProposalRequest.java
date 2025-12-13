package com.fyn_monolithic.dto.request.date;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.ZonedDateTime;

/**
 * Request DTO for sending a proposal to join a date
 */
@Data
public class ProposalRequest {

    private String message;

    // Optional: proposer can suggest a different time
    private ZonedDateTime proposedTime;
}
