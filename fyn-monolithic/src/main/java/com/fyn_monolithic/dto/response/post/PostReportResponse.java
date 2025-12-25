package com.fyn_monolithic.dto.response.post;

import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.model.post.ReportReason;
import com.fyn_monolithic.model.post.ReportStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Value;

import java.time.Instant;
import java.util.UUID;

@Value
@AllArgsConstructor
@Builder
public class PostReportResponse {
    UUID id;
    PostResponse post;
    UserResponse reporter;
    ReportReason reason;
    String description;
    ReportStatus status;
    String moderationComment;
    Instant createdAt;
}
