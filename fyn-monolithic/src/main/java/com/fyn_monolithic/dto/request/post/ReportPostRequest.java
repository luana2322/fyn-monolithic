package com.fyn_monolithic.dto.request.post;

import com.fyn_monolithic.model.post.ReportReason;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReportPostRequest {
    @NotNull
    private ReportReason reason;
    private String description;
}
