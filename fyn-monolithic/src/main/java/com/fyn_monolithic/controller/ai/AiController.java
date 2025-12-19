package com.fyn_monolithic.controller.ai;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.service.ai.HuggingFaceEmbeddingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Controller for AI-related endpoints and health checks.
 */
@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController {

    private final HuggingFaceEmbeddingService embeddingService;

    /**
     * Check if HuggingFace embedding service is available.
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<Map<String, Object>>> health() {
        boolean healthy = embeddingService.isHealthy();
        Map<String, Object> status = Map.of(
                "huggingface_api", healthy ? "connected" : "unavailable",
                "embedding_dimension", 384,
                "model", "sentence-transformers/all-MiniLM-L6-v2");
        return ResponseEntity.ok(ApiResponse.ok(status));
    }

    /**
     * Generate embedding for a test text (for debugging).
     */
    @PostMapping("/embed")
    public ResponseEntity<ApiResponse<Map<String, Object>>> embed(@RequestBody Map<String, String> request) {
        String text = request.getOrDefault("text", "Hello world");
        float[] embedding = embeddingService.getEmbedding(text);

        Map<String, Object> result = Map.of(
                "text", text,
                "dimension", embedding.length,
                "embedding_preview", new float[] { embedding[0], embedding[1], embedding[2] } // First 3 values
        );
        return ResponseEntity.ok(ApiResponse.ok(result));
    }
}
