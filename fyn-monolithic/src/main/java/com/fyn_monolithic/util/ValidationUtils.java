package com.fyn_monolithic.util;

import java.util.UUID;

public final class ValidationUtils {

    private ValidationUtils() {
    }

    public static UUID safeUuid(String value) {
        return value == null ? null : UUID.fromString(value);
    }
}
