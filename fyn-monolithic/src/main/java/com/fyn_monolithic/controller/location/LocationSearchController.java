package com.fyn_monolithic.controller.location;

import com.fyn_monolithic.service.location.SerpApiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Controller for location search via SerpAPI
 * Proxies requests to avoid CORS issues
 */
@RestController
@RequestMapping("/api/v1/locations")
@RequiredArgsConstructor
public class LocationSearchController {

    private final SerpApiService serpApiService;

    /**
     * Search for places using SerpAPI Google Maps engine
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchPlaces(
            @RequestParam String query,
            @RequestParam(required = false) String location) {

        Map<String, Object> results = serpApiService.searchPlaces(query, location);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", results));
    }
}
