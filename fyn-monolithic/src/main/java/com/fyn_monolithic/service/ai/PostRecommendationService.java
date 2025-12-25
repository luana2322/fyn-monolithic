package com.fyn_monolithic.service.ai;

import com.fyn_monolithic.dto.response.post.PostResponse;
import com.fyn_monolithic.mapper.PostMapper;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.post.PostLikeRepository;
import com.fyn_monolithic.repository.post.PostRepository;
import com.fyn_monolithic.service.user.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Service for generating personalized post recommendations using
 * embedding-based similarity.
 * Uses HuggingFace embeddings to compute cosine similarity between user
 * preferences and posts.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PostRecommendationService {

    private final HuggingFaceEmbeddingService embeddingService;
    private final PostLikeRepository postLikeRepository;
    private final PostRepository postRepository;
    private final PostMapper postMapper;
    private final UserService userService;

    @Value("${ai.recommendation.min-interaction-count:3}")
    private int minInteractionCount;

    @Value("${ai.recommendation.max-candidate-posts:500}")
    private int maxCandidatePosts;

    private static final int EMBEDDING_DIMENSION = 384;

    /**
     * Get personalized post recommendations for the current user.
     * Falls back to chronological feed if user has insufficient interactions.
     *
     * @param limit maximum number of posts to return
     * @return list of recommended posts, ranked by relevance
     */
    @Transactional(readOnly = true)
    public List<PostResponse> getRecommendedPosts(int limit) {
        User currentUser = userService.getCurrentUser();

        // Get user's liked posts for preference computation
        List<Post> likedPosts = postLikeRepository.findLikedPostsByUser(currentUser);

        if (likedPosts.size() < minInteractionCount) {
            log.info("User {} has only {} likes, falling back to chronological feed",
                    currentUser.getId(), likedPosts.size());
            return getFallbackPosts(limit);
        }

        // Compute user preference vector from liked posts
        float[] userPreferenceVector = computeUserPreferenceVector(currentUser.getId(), likedPosts);

        if (isZeroVector(userPreferenceVector)) {
            log.warn("Failed to compute preference vector for user {}, using fallback", currentUser.getId());
            return getFallbackPosts(limit);
        }

        // Get candidate posts (excluding already liked posts)
        Set<UUID> likedPostIds = likedPosts.stream().map(Post::getId).collect(Collectors.toSet());
        List<Post> candidatePosts = postRepository.findAll(PageRequest.of(0, maxCandidatePosts)).getContent()
                .stream()
                .filter(post -> !likedPostIds.contains(post.getId()))
                .filter(post -> !post.getAuthor().getId().equals(currentUser.getId())) // Exclude own posts
                .toList();

        if (candidatePosts.isEmpty()) {
            log.info("No candidate posts for user {}", currentUser.getId());
            return List.of();
        }

        // Rank posts by similarity to user preference
        List<PostWithScore> rankedPosts = rankPostsBySimilarity(candidatePosts, userPreferenceVector);

        // Get the final list of recommended posts
        List<Post> recommendedPosts = rankedPosts.stream()
                .limit(limit)
                .map(PostWithScore::post)
                .toList();

        // Check which posts have been liked by current user
        Set<UUID> currentlyLikedPostIds = postLikeRepository.findPostIdsLikedByUser(currentUser, recommendedPosts);

        return rankedPosts.stream()
                .limit(limit)
                .map(pws -> postMapper.toPostResponse(pws.post()).toBuilder()
                        .likedByCurrentUser(currentlyLikedPostIds.contains(pws.post().getId()))
                        .build())
                .toList();
    }

    /**
     * Compute user preference vector by averaging embeddings of liked post content.
     * Cached to avoid repeated API calls.
     */
    @Cacheable(value = "userPreferenceVectors", key = "#userId")
    public float[] computeUserPreferenceVector(UUID userId, List<Post> likedPosts) {
        log.info("Computing preference vector for user {} from {} liked posts", userId, likedPosts.size());

        // Extract text content from liked posts
        List<String> contents = likedPosts.stream()
                .map(Post::getContent)
                .filter(content -> content != null && !content.isBlank())
                .limit(50) // Use most recent 50 posts for efficiency
                .toList();

        if (contents.isEmpty()) {
            log.warn("No valid content in liked posts for user {}", userId);
            return new float[EMBEDDING_DIMENSION];
        }

        // Get embeddings for all liked post contents
        List<float[]> embeddings = embeddingService.getEmbeddings(contents);

        // Average all embeddings to create user preference vector
        return averageVectors(embeddings);
    }

    /**
     * Rank candidate posts by cosine similarity to user preference vector.
     */
    private List<PostWithScore> rankPostsBySimilarity(List<Post> posts, float[] userVector) {
        // Get content for all candidate posts
        List<String> contents = posts.stream()
                .map(post -> post.getContent() != null ? post.getContent() : "")
                .toList();

        // Get embeddings for candidate posts
        List<float[]> postEmbeddings = embeddingService.getEmbeddings(contents);

        // Calculate similarity scores
        List<PostWithScore> scored = new ArrayList<>();
        for (int i = 0; i < posts.size(); i++) {
            double similarity = cosineSimilarity(userVector, postEmbeddings.get(i));
            scored.add(new PostWithScore(posts.get(i), similarity));
        }

        // Sort by similarity (descending)
        scored.sort((a, b) -> Double.compare(b.score(), a.score()));

        return scored;
    }

    /**
     * Fallback to chronological feed when personalization is not possible.
     */
    private List<PostResponse> getFallbackPosts(int limit) {
        User currentUser = userService.getCurrentUser();
        List<Post> posts = postRepository.findAll(PageRequest.of(0, limit)).getContent();

        if (posts.isEmpty()) {
            return List.of();
        }

        Set<UUID> likedPostIds = postLikeRepository.findPostIdsLikedByUser(currentUser, posts);

        return posts.stream()
                .map(post -> postMapper.toPostResponse(post).toBuilder()
                        .likedByCurrentUser(likedPostIds.contains(post.getId()))
                        .build())
                .toList();
    }

    /**
     * Calculate cosine similarity between two vectors.
     * Returns value between -1 and 1, where 1 means identical direction.
     */
    double cosineSimilarity(float[] a, float[] b) {
        if (a.length != b.length) {
            throw new IllegalArgumentException("Vectors must have same length");
        }

        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;

        for (int i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        double denominator = Math.sqrt(normA) * Math.sqrt(normB);
        if (denominator == 0) {
            return 0.0;
        }

        return dotProduct / denominator;
    }

    /**
     * Average multiple vectors into a single vector.
     */
    private float[] averageVectors(List<float[]> vectors) {
        if (vectors.isEmpty()) {
            return new float[EMBEDDING_DIMENSION];
        }

        float[] result = new float[vectors.get(0).length];
        for (float[] vector : vectors) {
            for (int i = 0; i < result.length; i++) {
                result[i] += vector[i];
            }
        }

        for (int i = 0; i < result.length; i++) {
            result[i] /= vectors.size();
        }

        return result;
    }

    /**
     * Check if a vector is all zeros (indicates failed embedding).
     */
    private boolean isZeroVector(float[] vector) {
        for (float v : vector) {
            if (v != 0.0f) {
                return false;
            }
        }
        return true;
    }

    /**
     * Record holding a post and its similarity score.
     */
    private record PostWithScore(Post post, double score) {
    }
}
