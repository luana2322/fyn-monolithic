package com.fyn_monolithic.service.moderation;

import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.moderation.AdminActionLog;
import com.fyn_monolithic.model.moderation.AdminActionType;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostReport;
import com.fyn_monolithic.model.post.PostStatus;
import com.fyn_monolithic.model.post.ReportStatus;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.moderation.AdminActionLogRepository;
import com.fyn_monolithic.repository.post.PostReportRepository;
import com.fyn_monolithic.repository.post.PostRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ModerationService {

    private final PostRepository postRepository;
    private final PostReportRepository postReportRepository;
    private final AdminActionLogRepository adminActionLogRepository;
    private final UserService userService;

    @Transactional
    public void hidePost(UUID postId, String reason) {
        Post post = getPost(postId);
        post.setStatus(PostStatus.HIDDEN);
        postRepository.save(post);
        logAction(AdminActionType.HIDE_POST, postId, reason);
    }

    @Transactional
    public void deletePost(UUID postId, String reason) {
        Post post = getPost(postId);
        post.setStatus(PostStatus.DELETED);
        postRepository.save(post);
        logAction(AdminActionType.DELETE_POST, postId, reason);
    }

    @Transactional
    public void restorePost(UUID postId, String reason) {
        Post post = getPost(postId);
        post.setStatus(PostStatus.ACTIVE);
        postRepository.save(post);
        logAction(AdminActionType.RESTORE_POST, postId, reason);
    }

    @Transactional
    public void markReportValid(UUID reportId, String adminComment) {
        PostReport report = getReport(reportId);
        report.setStatus(ReportStatus.VALID);
        report.setModerationComment(adminComment);
        postReportRepository.save(report);
        logAction(AdminActionType.MARK_REPORT_VALID, reportId, adminComment);
    }

    @Transactional
    public void markReportInvalid(UUID reportId, String adminComment) {
        PostReport report = getReport(reportId);
        report.setStatus(ReportStatus.INVALID);
        report.setModerationComment(adminComment);
        postReportRepository.save(report);
        logAction(AdminActionType.MARK_REPORT_INVALID, reportId, adminComment);
    }

    private Post getPost(UUID postId) {
        return postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
    }

    private PostReport getReport(UUID reportId) {
        return postReportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
    }

    private void logAction(AdminActionType actionType, UUID targetId, String note) {
        User admin = userService.getCurrentUser();
        AdminActionLog log = new AdminActionLog();
        log.setAdmin(admin);
        log.setActionType(actionType);
        log.setTargetId(targetId);
        log.setNote(note);
        adminActionLogRepository.save(log);
    }
}
