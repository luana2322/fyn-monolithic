package com.fyn_monolithic.model.date;

/**
 * Status for date proposals
 */
public enum ProposalStatus {
    PENDING, // Awaiting response from date owner
    ACCEPTED, // Owner accepted this proposal
    REJECTED, // Owner rejected this proposal
    COUNTER_PROPOSED, // Owner suggested a different time
    WITHDRAWN // Proposer withdrew their proposal
}
