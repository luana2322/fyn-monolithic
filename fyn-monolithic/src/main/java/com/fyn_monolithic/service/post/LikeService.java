package com.fyn_monolithic.service.post;

import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostLike;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.post.PostLikeRepository;
import com.fyn_monolithic.repository.post.PostRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LikeService {

    private final PostRepository postRepository;
    private final PostLikeRepository likeRepository;
    private final UserService userService;

    @Transactional
    public void like(UUID postId) {
        User user = userService.getCurrentUser();
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        likeRepository.findByPostAndUser(post, user).ifPresent(existing -> {
            throw new IllegalStateException("Post already liked");
        });
        PostLike like = new PostLike();
        like.setPost(post);
        like.setUser(user);
        likeRepository.save(like);
    }

    @Transactional
    public void unlike(UUID postId) {
        User user = userService.getCurrentUser();
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        likeRepository.findByPostAndUser(post, user)
                .ifPresent(likeRepository::delete);
    }
}
