package com.fyn_monolithic.model.date;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * Status of a meetup match application
 */
public enum MatchStatus {
    PENDING("pending"), // Waiting for organizer decision
    ACCEPTED("accepted"), // Organizer accepted - chat opened
    REJECTED("rejected"), // Organizer rejected
    CANCELLED("cancelled"), // User cancelled their application
    CONFIRMED("confirmed"); // Both parties confirmed post-meet

    private final String value;

    MatchStatus(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static MatchStatus fromValue(String value) {
        if (value == null) {
            return null;
        }
        for (MatchStatus status : values()) {
            if (status.value.equalsIgnoreCase(value) || status.name().equalsIgnoreCase(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid MatchStatus: " + value);
    }
}
