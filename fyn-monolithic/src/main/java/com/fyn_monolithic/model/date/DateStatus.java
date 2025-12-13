package com.fyn_monolithic.model.date;

/**
 * Status lifecycle for date plans
 */
public enum DateStatus {
    OPEN, // Open for proposals
    PROPOSAL_PENDING, // Has pending proposals
    ACCEPTED, // Proposal accepted, date confirmed
    REJECTED, // All proposals rejected
    COMPLETED, // Date happened
    CANCELLED, // Owner cancelled
    EXPIRED, // Passed scheduled time without acceptance
    NO_SHOW // Partner didn't show up
}
