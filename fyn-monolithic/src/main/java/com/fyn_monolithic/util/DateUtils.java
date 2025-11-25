package com.fyn_monolithic.util;

import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

public final class DateUtils {

    private static final DateTimeFormatter ISO_FORMATTER = DateTimeFormatter.ISO_OFFSET_DATE_TIME;

    private DateUtils() {
    }

    public static String formatIso(Instant instant) {
        if (instant == null) {
            return null;
        }
        return ISO_FORMATTER.format(instant.atOffset(ZoneOffset.UTC));
    }
}
