package com.fyn_monolithic.repository.post;

import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostLike;
import com.fyn_monolithic.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface PostLikeRepository extends JpaRepository<PostLike, UUID> {
    Optional<PostLike> findByPostAndUser(Post post, User user);

    long countByPost(Post post);

    @Query("select pl.post.id from PostLike pl where pl.user = :user and pl.post in :posts")
    Set<UUID> findPostIdsLikedByUser(@Param("user") User user, @Param("posts") List<Post> posts);
}
