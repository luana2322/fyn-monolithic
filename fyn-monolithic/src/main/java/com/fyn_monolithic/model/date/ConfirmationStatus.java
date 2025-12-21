package com.fyn_monolithic.model.date;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * Confirmation status for post-meet verification
 */
public enum ConfirmationStatus {
    NONE("none"), // Not yet time to confirm
    PENDING("pending"), // Waiting for confirmations
    CONFIRMED("confirmed"), // Both confirmed
    DISPUTED("disputed"), // Only one confirmed
    NO_SHOW("noShow"); // Marked as no-show

    private final String value;

    ConfirmationStatus(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static ConfirmationStatus fromValue(String value) {
        if (value == null) {
            return null;
        }
        for (ConfirmationStatus status : values()) {
            if (status.value.equalsIgnoreCase(value) || status.name().equalsIgnoreCase(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid ConfirmationStatus: " + value);
    }
}
