package com.fyn_monolithic.dto.request.match;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * Request DTO for post-date feedback
 * Submitted 12-24h after the date via push notification
 */
@Data
public class DateFeedbackRequest {

    @NotNull(message = "Did meet status is required")
    private Boolean didMeet;

    // Required if didMeet = false
    private String noShowReason; // partner_no_show, cancelled, other

    // Required if didMeet = true
    private String rating; // good, neutral, bad

    private String feedbackText;
}
