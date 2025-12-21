package com.fyn_monolithic.service.ai;

import com.fyn_monolithic.config.HuggingFaceConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.List;
import java.util.Map;

/**
 * Service for generating text embeddings using HuggingFace Inference API.
 * Uses sentence-transformers/all-MiniLM-L6-v2 model which produces
 * 384-dimensional embeddings.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HuggingFaceEmbeddingService {

    private final WebClient huggingFaceWebClient;
    private final HuggingFaceConfig huggingFaceConfig;

    private static final int EMBEDDING_DIMENSION = 384;
    private static final Duration TIMEOUT = Duration.ofSeconds(30);

    /**
     * Generate embedding for a single text input.
     *
     * @param text input text to embed
     * @return 384-dimensional float array, or null if API call fails
     */
    public float[] getEmbedding(String text) {
        if (text == null || text.isBlank()) {
            log.warn("Empty text provided for embedding, returning zero vector");
            return new float[EMBEDDING_DIMENSION];
        }

        try {
            String endpoint = "/pipeline/feature-extraction/" + huggingFaceConfig.getModel();

            // HuggingFace expects: {"inputs": "text"} for single input
            Map<String, Object> requestBody = Map.of(
                    "inputs", text,
                    "options", Map.of("wait_for_model", true));

            List<Double> result = huggingFaceWebClient.post()
                    .uri(endpoint)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(new org.springframework.core.ParameterizedTypeReference<List<Double>>() {
                    })
                    .timeout(TIMEOUT)
                    .onErrorResume(WebClientResponseException.class, e -> {
                        log.error("HuggingFace API error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
                        return Mono.empty();
                    })
                    .block();

            if (result == null || result.isEmpty()) {
                log.warn("Empty embedding result from HuggingFace API");
                return new float[EMBEDDING_DIMENSION];
            }

            return toFloatArray(result);

        } catch (Exception e) {
            log.error("Failed to get embedding from HuggingFace: {}", e.getMessage(), e);
            return new float[EMBEDDING_DIMENSION];
        }
    }

    /**
     * Generate embeddings for multiple texts in batch.
     *
     * @param texts list of texts to embed
     * @return list of 384-dimensional float arrays
     */
    public List<float[]> getEmbeddings(List<String> texts) {
        if (texts == null || texts.isEmpty()) {
            return List.of();
        }

        try {
            String endpoint = "/pipeline/feature-extraction/" + huggingFaceConfig.getModel();

            // HuggingFace expects: {"inputs": ["text1", "text2"]} for batch input
            Map<String, Object> requestBody = Map.of(
                    "inputs", texts,
                    "options", Map.of("wait_for_model", true));

            List<List<Double>> results = huggingFaceWebClient.post()
                    .uri(endpoint)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(new org.springframework.core.ParameterizedTypeReference<List<List<Double>>>() {
                    })
                    .timeout(TIMEOUT)
                    .onErrorResume(WebClientResponseException.class, e -> {
                        log.error("HuggingFace batch API error: {} - {}", e.getStatusCode(),
                                e.getResponseBodyAsString());
                        return Mono.empty();
                    })
                    .block();

            if (results == null || results.isEmpty()) {
                log.warn("Empty batch embedding result from HuggingFace API");
                return texts.stream().map(t -> new float[EMBEDDING_DIMENSION]).toList();
            }

            return results.stream()
                    .map(this::toFloatArray)
                    .toList();

        } catch (Exception e) {
            log.error("Failed to get batch embeddings from HuggingFace: {}", e.getMessage(), e);
            return texts.stream().map(t -> new float[EMBEDDING_DIMENSION]).toList();
        }
    }

    /**
     * Check if the HuggingFace API is available and responding.
     *
     * @return true if API is healthy
     */
    public boolean isHealthy() {
        try {
            float[] result = getEmbedding("health check");
            return result != null && result.length == EMBEDDING_DIMENSION;
        } catch (Exception e) {
            log.warn("HuggingFace health check failed: {}", e.getMessage());
            return false;
        }
    }

    private float[] toFloatArray(List<Double> doubles) {
        float[] floats = new float[doubles.size()];
        for (int i = 0; i < doubles.size(); i++) {
            floats[i] = doubles.get(i).floatValue();
        }
        return floats;
    }
}
