package com.fyn_monolithic.repository.post;

import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostReport;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.UUID;

public interface PostReportRepository extends JpaRepository<PostReport, UUID> {
    boolean existsByPostAndReporter(Post post, User reporter);

    @Query("SELECT pr.post.id as postId, COUNT(pr) as reportCount FROM PostReport pr " +
            "GROUP BY pr.post.id ORDER BY reportCount DESC")
    Page<Object[]> findReportedPosts(Pageable pageable);

    Page<PostReport> findByPost(Post post, Pageable pageable);
}
