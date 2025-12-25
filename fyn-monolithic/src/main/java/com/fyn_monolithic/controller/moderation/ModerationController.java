package com.fyn_monolithic.controller.moderation;

import com.fyn_monolithic.dto.request.moderation.ModerationActionRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.post.PostReportResponse;
import com.fyn_monolithic.mapper.PostMapper;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostReport;
import com.fyn_monolithic.repository.post.PostReportRepository;
import com.fyn_monolithic.service.moderation.ModerationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class ModerationController {

    private final ModerationService moderationService;
    private final PostReportRepository postReportRepository;
    private final PostMapper postMapper;

    @GetMapping("/reported-posts")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<PageResponse<PostReportResponse>>> getReportedPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<PostReport> result = postReportRepository.findAll(PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.<PostReportResponse>builder()
                .content(result.getContent().stream().map(postMapper::toPostReportResponse).toList())
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build()));
    }

    @GetMapping("/posts/{postId}/reports")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<PageResponse<PostReportResponse>>> getReportsForPost(
            @PathVariable UUID postId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Post post = new Post();
        post.setId(postId);
        Page<PostReport> result = postReportRepository.findByPost(post, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.<PostReportResponse>builder()
                .content(result.getContent().stream().map(postMapper::toPostReportResponse).toList())
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build()));
    }

    @PostMapping("/posts/{postId}/hide")
    public ResponseEntity<ApiResponse<Void>> hidePost(
            @PathVariable UUID postId,
            @RequestBody ModerationActionRequest request) {
        moderationService.hidePost(postId, request.getReason());
        return ResponseEntity.ok(ApiResponse.message("Post hidden"));
    }

    @PostMapping("/posts/{postId}/delete")
    public ResponseEntity<ApiResponse<Void>> deletePost(
            @PathVariable UUID postId,
            @RequestBody ModerationActionRequest request) {
        moderationService.deletePost(postId, request.getReason());
        return ResponseEntity.ok(ApiResponse.message("Post deleted (soft)"));
    }

    @PostMapping("/posts/{postId}/restore")
    public ResponseEntity<ApiResponse<Void>> restorePost(
            @PathVariable UUID postId,
            @RequestBody ModerationActionRequest request) {
        moderationService.restorePost(postId, request.getReason());
        return ResponseEntity.ok(ApiResponse.message("Post restored"));
    }

    @PostMapping("/reports/{reportId}/mark-valid")
    public ResponseEntity<ApiResponse<Void>> markValid(
            @PathVariable UUID reportId,
            @RequestBody ModerationActionRequest request) {
        moderationService.markReportValid(reportId, request.getAdminComment());
        return ResponseEntity.ok(ApiResponse.message("Report marked as valid"));
    }

    @PostMapping("/reports/{reportId}/mark-invalid")
    public ResponseEntity<ApiResponse<Void>> markInvalid(
            @PathVariable UUID reportId,
            @RequestBody ModerationActionRequest request) {
        moderationService.markReportInvalid(reportId, request.getAdminComment());
        return ResponseEntity.ok(ApiResponse.message("Report marked as invalid"));
    }
}
