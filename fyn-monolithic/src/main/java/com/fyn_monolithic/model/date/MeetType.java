package com.fyn_monolithic.model.date;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
 * Type of meetup: one-to-one or group
 */
public enum MeetType {
    ONE_TO_ONE("oneToOne"), // 1-1 meet
    GROUP("group"); // Group meet

    private final String value;

    MeetType(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static MeetType fromValue(String value) {
        if (value == null) {
            return null;
        }
        // Accept both formats: "ONE_TO_ONE" or "oneToOne"
        for (MeetType type : values()) {
            if (type.value.equalsIgnoreCase(value) || type.name().equalsIgnoreCase(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Invalid MeetType: " + value);
    }
}
