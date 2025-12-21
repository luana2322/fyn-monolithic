package com.fyn_monolithic.model.date;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * Status for group meetups
 */
public enum MeetupStatus {
    OPEN("open"), // Accepting applications
    MATCHED("matched"), // Has accepted participants
    WAITING_CONFIRMATION("waitingConfirmation"), // Meet happened, awaiting post-meet confirmation
    COMPLETED("completed"), // Both parties confirmed
    CANCELLED("cancelled"), // Cancelled by organizer
    EXPIRED("expired"); // Expired without matching

    private final String value;

    MeetupStatus(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static MeetupStatus fromValue(String value) {
        if (value == null) {
            return null;
        }
        for (MeetupStatus status : values()) {
            if (status.value.equalsIgnoreCase(value) || status.name().equalsIgnoreCase(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid MeetupStatus: " + value);
    }
}
