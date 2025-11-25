package com.fyn_monolithic.controller.post;

import com.fyn_monolithic.dto.request.post.CreateCommentRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.post.CommentResponse;
import com.fyn_monolithic.service.post.CommentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/posts/{postId}/comments")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @PostMapping
    public ResponseEntity<ApiResponse<CommentResponse>> addComment(@PathVariable UUID postId,
                                                                   @Valid @RequestBody CreateCommentRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(commentService.addComment(postId, request)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CommentResponse>>> list(@PathVariable UUID postId) {
        return ResponseEntity.ok(ApiResponse.ok(commentService.getComments(postId)));
    }

    @DeleteMapping("/{commentId}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID commentId) {
        commentService.deleteComment(commentId);
        return ResponseEntity.ok(ApiResponse.message("Comment removed"));
    }
}
