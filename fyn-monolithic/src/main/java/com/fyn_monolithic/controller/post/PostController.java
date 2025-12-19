package com.fyn_monolithic.controller.post;

import com.fyn_monolithic.dto.request.post.CreatePostRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.post.PostResponse;
import com.fyn_monolithic.service.post.PostService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    // @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    // public ResponseEntity<ApiResponse<PostResponse>> createPost(
    // @Valid @RequestPart("payload") CreatePostRequest request,
    // @RequestPart(value = "media", required = false) List<MultipartFile> media) {
    // return ResponseEntity.ok(ApiResponse.ok(postService.createPost(request,
    // media)));
    // }
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<PostResponse>> createPost(
            @Valid @RequestPart("payload") CreatePostRequest request,
            @RequestPart(value = "media", required = false) List<MultipartFile> media) {
        return ResponseEntity.ok(ApiResponse.ok(postService.createPost(request, media)));
    }
    // @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    // public ResponseEntity<ApiResponse<PostResponse>> createPost(
    // @RequestHeader("Content-Type") String contentType,
    // @Valid @RequestPart("payload") CreatePostRequest request,
    // @RequestPart(value = "media", required = false) List<MultipartFile> media) {
    //
    // System.out.println("Content-Type received: " + contentType);
    // return ResponseEntity.ok(ApiResponse.ok(postService.createPost(request,
    // media)));
    // }

    @GetMapping("/feed")
    public ResponseEntity<ApiResponse<PageResponse<PostResponse>>> feed(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(ApiResponse.ok(postService.getFeed(page, size)));
    }

    /**
     * Get AI-powered personalized post recommendations.
     * Uses HuggingFace embeddings to rank posts based on user's liked post history.
     * Falls back to chronological feed if user has fewer than 3 liked posts.
     */
    @GetMapping("/recommended")
    public ResponseEntity<ApiResponse<PageResponse<PostResponse>>> recommended(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(ApiResponse.ok(postService.getRecommendedFeed(page, size)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<PageResponse<PostResponse>>> postsByUser(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(ApiResponse.ok(postService.getPostsOfUser(userId, page, size)));
    }

    @GetMapping("/place/{placeCode}")
    public ResponseEntity<ApiResponse<PageResponse<PostResponse>>> postsByPlace(
            @PathVariable String placeCode,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(ApiResponse.ok(postService.getPostsByPlace(placeCode, page, size)));
    }

    @DeleteMapping("/{postId}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID postId) {
        postService.deletePost(postId);
        return ResponseEntity.ok(ApiResponse.message("Post deleted"));
    }
}
