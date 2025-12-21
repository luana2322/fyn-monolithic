package com.fyn_monolithic.service.location;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Optimized location search service
 * - Prioritizes nearby locations
 * - Fast search using bounded viewport
 * - Sorts results by distance from user
 */
@Service
public class SerpApiService {

    @Value("${serpapi.key:}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Search for places - optimized for nearby results
     */
    public Map<String, Object> searchPlaces(String query, String location) {
        return searchWithNominatim(query, location);
    }

    /**
     * Optimized search using OpenStreetMap Nominatim API
     * - Uses viewbox to prioritize nearby results
     * - Sorts by distance from user location
     */
    private Map<String, Object> searchWithNominatim(String query, String location) {
        // Parse user location
        double userLat = 21.0285; // Default: Hanoi
        double userLng = 105.8542;
        if (location != null && location.contains(",")) {
            String[] parts = location.split(",");
            try {
                userLat = Double.parseDouble(parts[0].trim());
                userLng = Double.parseDouble(parts[1].trim());
            } catch (NumberFormatException ignored) {
            }
        }

        // Create a bounded search area (roughly 50km radius)
        double delta = 0.5; // ~50km
        String viewbox = String.format("%f,%f,%f,%f",
                userLng - delta, userLat - delta,
                userLng + delta, userLat + delta);

        String url = UriComponentsBuilder
                .fromHttpUrl("https://nominatim.openstreetmap.org/search")
                .queryParam("q", query)
                .queryParam("format", "json")
                .queryParam("addressdetails", "1")
                .queryParam("limit", "15")
                .queryParam("viewbox", viewbox)
                .queryParam("bounded", "0") // Prefer but don't restrict to viewbox
                .queryParam("countrycodes", "vn") // Prioritize Vietnam
                .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.set("User-Agent", "FynApp/1.0 (contact@fyn.app)");
        headers.set("Accept-Language", "vi,en");
        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> results = restTemplate.exchange(
                    url, HttpMethod.GET, entity, List.class).getBody();

            List<Map<String, Object>> localResults = new ArrayList<>();
            if (results != null) {
                final double finalUserLat = userLat;
                final double finalUserLng = userLng;

                for (Map<String, Object> result : results) {
                    double lat = Double.parseDouble((String) result.get("lat"));
                    double lng = Double.parseDouble((String) result.get("lon"));
                    double distance = calculateDistance(finalUserLat, finalUserLng, lat, lng);

                    Map<String, Object> place = new HashMap<>();

                    // Create a cleaner title from the address parts
                    String displayName = (String) result.get("display_name");
                    String[] nameParts = displayName.split(",");
                    String title = nameParts.length > 0 ? nameParts[0].trim() : displayName;
                    String address = nameParts.length > 1
                            ? String.join(", ",
                                    java.util.Arrays.copyOfRange(nameParts, 1, Math.min(4, nameParts.length))).trim()
                            : displayName;

                    place.put("title", title);
                    place.put("address", address);
                    place.put("distance_km", Math.round(distance * 10.0) / 10.0);

                    Map<String, Object> gps = new HashMap<>();
                    gps.put("latitude", lat);
                    gps.put("longitude", lng);
                    place.put("gps_coordinates", gps);

                    place.put("type", result.get("type"));
                    place.put("category", result.get("class"));
                    localResults.add(place);
                }

                // Sort by distance (nearest first)
                localResults.sort(Comparator.comparingDouble(
                        p -> (Double) ((Map<String, Object>) p).get("distance_km")));
            }

            Map<String, Object> response = new HashMap<>();
            response.put("local_results", localResults);
            return response;
        } catch (Exception e) {
            throw new RuntimeException("Failed to search places: " + e.getMessage(), e);
        }
    }

    /**
     * Calculate distance between two points using Haversine formula
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth's radius in km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
