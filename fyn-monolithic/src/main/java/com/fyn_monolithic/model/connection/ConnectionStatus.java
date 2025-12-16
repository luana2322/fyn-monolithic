package com.fyn_monolithic.model.connection;

public enum ConnectionStatus {
    PENDING,
    ACCEPTED,
    REJECTED,
    BLOCKED,
    EXPIRED,
    CANCELLED, // User cancelled the match
    COMPLETED, // Match completed successfully
    NO_SHOW // Other person didn't show up
}
