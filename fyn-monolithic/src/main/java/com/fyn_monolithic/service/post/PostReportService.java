package com.fyn_monolithic.service.post;

import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostReport;
import com.fyn_monolithic.model.post.ReportReason;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.post.PostReportRepository;
import com.fyn_monolithic.repository.post.PostRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PostReportService {

    private final PostReportRepository postReportRepository;
    private final PostRepository postRepository;
    private final UserService userService;

    @Transactional
    public void reportPost(UUID postId, ReportReason reason, String description) {
        User reporter = userService.getCurrentUser();
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));

        if (postReportRepository.existsByPostAndReporter(post, reporter)) {
            throw new IllegalStateException("You have already reported this post");
        }

        PostReport report = new PostReport();
        report.setPost(post);
        report.setReporter(reporter);
        report.setReason(reason);
        report.setDescription(description);

        postReportRepository.save(report);
    }
}
