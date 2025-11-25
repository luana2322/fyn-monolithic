package com.fyn_monolithic.service.post;

import com.fyn_monolithic.dto.request.post.CreateCommentRequest;
import com.fyn_monolithic.dto.response.post.CommentResponse;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.mapper.PostMapper;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostComment;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.post.PostCommentRepository;
import com.fyn_monolithic.repository.post.PostRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final PostRepository postRepository;
    private final PostCommentRepository commentRepository;
    private final UserService userService;
    private final PostMapper postMapper;

    @Transactional
    public CommentResponse addComment(UUID postId, CreateCommentRequest request) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        User author = userService.getCurrentUser();
        PostComment comment = new PostComment();
        comment.setPost(post);
        comment.setAuthor(author);
        comment.setContent(request.getContent());
        if (request.getParentCommentId() != null) {
            PostComment parent = commentRepository.findById(request.getParentCommentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Parent comment not found"));
            comment.setParentComment(parent);
        }
        return postMapper.toCommentResponse(commentRepository.save(comment));
    }

    @Transactional(readOnly = true)
    public List<CommentResponse> getComments(UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        return commentRepository.findByPost(post).stream()
                .map(postMapper::toCommentResponse)
                .toList();
    }

    @Transactional
    public void deleteComment(UUID commentId) {
        PostComment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found"));
        commentRepository.delete(comment);
    }
}
