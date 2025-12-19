package com.fyn_monolithic.service.post;

import com.fyn_monolithic.dto.request.post.CreatePostRequest;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.post.PostResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.mapper.PostMapper;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostMedia;
import com.fyn_monolithic.model.search.Hashtag;
import com.fyn_monolithic.model.search.PostHashtag;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.post.PostLikeRepository;
import com.fyn_monolithic.repository.post.PostMediaRepository;
import com.fyn_monolithic.repository.post.PostRepository;
import com.fyn_monolithic.repository.search.HashtagRepository;
import com.fyn_monolithic.repository.search.PostHashtagRepository;
import com.fyn_monolithic.service.ai.PostRecommendationService;
import com.fyn_monolithic.service.storage.MinioService;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final PostMediaRepository postMediaRepository;
    private final HashtagRepository hashtagRepository;
    private final PostHashtagRepository postHashtagRepository;
    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final UserService userService;
    private final MinioService minioService;
    private final PostLikeRepository postLikeRepository;
    private final PostRecommendationService postRecommendationService;

    @Transactional
    public PostResponse createPost(CreatePostRequest request, List<MultipartFile> mediaFiles) {
        User author = userService.getCurrentUser();
        Post post = new Post();
        post.setAuthor(author);
        post.setContent(request.getContent());
        post.setVisibility(request.getVisibility());

        // Handle location - MUTUALLY EXCLUSIVE validation
        handleLocation(post, request);

        Post saved = postRepository.save(post);

        if (mediaFiles != null) {
            int orderIndex = 0;
            for (MultipartFile file : mediaFiles) {
                String objectKey = minioService.upload(file);
                PostMedia media = new PostMedia();
                media.setPost(saved);
                media.setObjectKey(objectKey);
                media.setMediaType(minioService.detectMediaType(file));
                media.setOrderIndex(orderIndex++);
                postMediaRepository.save(media);
            }
        }

        upsertHashtags(saved, request.getHashtags());
        return postMapper.toPostResponse(saved).toBuilder()
                .likedByCurrentUser(false)
                .build();
    }

    private void handleLocation(Post post, CreatePostRequest request) {
        boolean hasGpsLocation = request.getLatitude() != null && request.getLongitude() != null;
        boolean hasPlaceTag = request.getPlaceCode() != null && !request.getPlaceCode().isBlank();

        // Validate mutual exclusivity
        if (hasGpsLocation && hasPlaceTag) {
            throw new IllegalArgumentException("Cannot specify both GPS location and place tag");
        }

        if (hasGpsLocation) {
            // Create PostGIS Point from lat/lng
            org.locationtech.jts.geom.GeometryFactory geometryFactory = new org.locationtech.jts.geom.GeometryFactory(
                    new org.locationtech.jts.geom.PrecisionModel(), 4326);
            org.locationtech.jts.geom.Point point = geometryFactory.createPoint(
                    new org.locationtech.jts.geom.Coordinate(request.getLongitude(), request.getLatitude()));
            post.setLocation(point);
        } else if (hasPlaceTag) {
            // Validate and set place tag
            com.fyn_monolithic.model.post.PlaceTag placeTag = com.fyn_monolithic.model.post.PlaceTag
                    .fromCode(request.getPlaceCode());

            if (placeTag == null) {
                throw new IllegalArgumentException("Invalid place code: " + request.getPlaceCode());
            }

            post.setPlaceCode(placeTag.getCode());
            post.setPlaceName(placeTag.getDisplayName());
        }
    }

    @Transactional(readOnly = true)
    public PageResponse<PostResponse> getFeed(int page, int size) {
        Page<Post> result = postRepository.findAll(PageRequest.of(page, size));
        return PageResponse.<PostResponse>builder()
                .content(applyUserContext(result.getContent()))
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build();
    }

    /**
     * Get AI-powered personalized feed based on user's liked post history.
     * Uses HuggingFace embeddings and cosine similarity for post ranking.
     * Falls back to chronological feed if user has insufficient interactions.
     */
    @Transactional(readOnly = true)
    public PageResponse<PostResponse> getRecommendedFeed(int page, int size) {
        List<PostResponse> recommended = postRecommendationService.getRecommendedPosts(size);
        return PageResponse.<PostResponse>builder()
                .content(recommended)
                .page(page)
                .size(size)
                .totalElements(recommended.size())
                .totalPages(1) // Recommendations are computed, not paginated from DB
                .build();
    }

    @Transactional(readOnly = true)
    public PageResponse<PostResponse> getPostsOfUser(UUID userId, int page, int size) {
        User user = userService.findEntity(userId);
        Page<Post> result = postRepository.findByAuthor(user, PageRequest.of(page, size));
        return PageResponse.<PostResponse>builder()
                .content(applyUserContext(result.getContent()))
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build();
    }

    @Transactional(readOnly = true)
    public PageResponse<PostResponse> getPostsByPlace(String placeCode, int page, int size) {
        // Validate place code
        if (!com.fyn_monolithic.model.post.PlaceTag.isValidCode(placeCode)) {
            throw new IllegalArgumentException("Invalid place code: " + placeCode);
        }

        Page<Post> result = postRepository.findByPlaceCode(placeCode, PageRequest.of(page, size));
        return PageResponse.<PostResponse>builder()
                .content(applyUserContext(result.getContent()))
                .page(page)
                .size(size)
                .totalElements(result.getTotalElements())
                .totalPages(result.getTotalPages())
                .build();
    }

    @Transactional
    public void deletePost(UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        postRepository.delete(post);
    }

    @Transactional(readOnly = true)
    public UserResponse getAuthor(UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        return userMapper.toUserResponse(post.getAuthor());
    }

    private void upsertHashtags(Post saved, Set<String> hashtags) {
        if (hashtags == null) {
            return;
        }
        hashtags.forEach(tag -> {
            Hashtag hashtag = hashtagRepository.findByTag(tag.toLowerCase())
                    .orElseGet(() -> {
                        Hashtag created = new Hashtag();
                        created.setTag(tag.toLowerCase());
                        return hashtagRepository.save(created);
                    });
            hashtag.setUsageCount(hashtag.getUsageCount() + 1);
            hashtagRepository.save(hashtag);
            PostHashtag relation = new PostHashtag();
            relation.setPost(saved);
            relation.setHashtag(hashtag);
            postHashtagRepository.save(relation);
        });
    }

    private List<PostResponse> applyUserContext(List<Post> posts) {
        if (posts.isEmpty()) {
            return List.of();
        }
        User currentUser = userService.getCurrentUser();
        Set<UUID> likedPostIds = postLikeRepository.findPostIdsLikedByUser(currentUser, posts);
        return posts.stream()
                .map(post -> {
                    PostResponse base = postMapper.toPostResponse(post);
                    return base.toBuilder()
                            .likedByCurrentUser(likedPostIds.contains(post.getId()))
                            .build();
                })
                .toList();
    }
}
