package com.fyn_monolithic.dto.request.date;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * Request DTO for meetup feedback
 */
public record MeetupFeedbackRequest(
        @NotNull(message = "Result is required") String result, // "SUCCESS" or "NO_SHOW"
        String feedback,
        @Min(1) @Max(5) Double rating) {
}
