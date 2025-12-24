package com.fyn_monolithic.dto.request.date;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * Request to confirm attendance at a meetup
 */
@Data
public class AttendanceConfirmRequest {

    @NotNull(message = "Status is required (CONFIRMED or NO_SHOW)")
    private String status;

    private String feedback;

    private Double rating; // 1.0 - 5.0
}
