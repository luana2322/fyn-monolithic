package com.fyn_monolithic.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Configuration for HuggingFace Inference API client.
 * Uses the sentence-transformers/all-MiniLM-L6-v2 model for 384-dim embeddings.
 */
@Configuration
public class HuggingFaceConfig {

    private static final String HUGGINGFACE_INFERENCE_API_BASE = "https://router.huggingface.co/hf-inference";

    @Value("${huggingface.api.token:}")
    private String apiToken;

    @Value("${huggingface.model:sentence-transformers/all-MiniLM-L6-v2}")
    private String model;

    @Bean
    public WebClient huggingFaceWebClient() {
        WebClient.Builder builder = WebClient.builder()
                .baseUrl(HUGGINGFACE_INFERENCE_API_BASE)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);

        // Add authorization header if token is provided
        if (apiToken != null && !apiToken.isBlank()) {
            builder.defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiToken);
        }

        return builder.build();
    }

    public String getModel() {
        return model;
    }
}
