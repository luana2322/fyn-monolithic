package com.fyn_monolithic.repository.post;

import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PostRepository extends JpaRepository<Post, UUID> {
    Page<Post> findByAuthor(User author, Pageable pageable);
}
