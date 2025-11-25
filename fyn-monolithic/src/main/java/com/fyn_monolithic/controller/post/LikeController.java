package com.fyn_monolithic.controller.post;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.post.PostReactionResponse;
import com.fyn_monolithic.service.post.LikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/posts/{postId}/likes")
@RequiredArgsConstructor
public class LikeController {

    private final LikeService likeService;

    @PostMapping
    public ResponseEntity<ApiResponse<PostReactionResponse>> like(@PathVariable UUID postId) {
        return ResponseEntity.ok(ApiResponse.ok(likeService.like(postId)));
    }

    @DeleteMapping
    public ResponseEntity<ApiResponse<PostReactionResponse>> unlike(@PathVariable UUID postId) {
        return ResponseEntity.ok(ApiResponse.ok(likeService.unlike(postId)));
    }
}
