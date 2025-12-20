package com.fyn_monolithic.service.location;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

/**
 * Service to proxy SerpAPI requests
 * Handles CORS and keeps API key secure on backend
 */
@Service
public class SerpApiService {

    @Value("${serpapi.key:1ffea8fc5e9c214ff9a73ba9348e5c3a0bf22ba991e81ec385ad535c76946121}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Search for places using Google Maps engine
     */
    public Map<String, Object> searchPlaces(String query, String location) {
        String url = UriComponentsBuilder
                .fromHttpUrl("https://serpapi.com/search.json")
                .queryParam("engine", "google_maps")
                .queryParam("q", query)
                .queryParam("type", "search")
                .queryParam("api_key", apiKey)
                .queryParam("ll", location)
                .toUriString();

        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            return response;
        } catch (Exception e) {
            throw new RuntimeException("Failed to search places: " + e.getMessage(), e);
        }
    }
}
