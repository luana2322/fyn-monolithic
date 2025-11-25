package com.fyn_monolithic.repository.post;

import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostLike;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PostLikeRepository extends JpaRepository<PostLike, UUID> {
    Optional<PostLike> findByPostAndUser(Post post, User user);
    long countByPost(Post post);
}
