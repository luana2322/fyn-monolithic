package com.fyn_monolithic.model.date;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * Status of user's attendance at a meetup
 */
public enum AttendanceStatus {
    PENDING("pending"), // Not yet confirmed
    CONFIRMED("confirmed"), // User confirmed they attended
    NO_SHOW("noShow"); // User did not show up

    private final String value;

    AttendanceStatus(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static AttendanceStatus fromValue(String value) {
        if (value == null) {
            return null;
        }
        for (AttendanceStatus status : values()) {
            if (status.value.equalsIgnoreCase(value) || status.name().equalsIgnoreCase(value)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid AttendanceStatus: " + value);
    }
}
