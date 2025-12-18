package com.fyn_monolithic.controller.post;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.model.post.PlaceTag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Controller for place management and discovery
 */
@RestController
@RequestMapping("/api/places")
@RequiredArgsConstructor
public class PlaceController {

    /**
     * Get all available places for tagging
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Map<String, String>>>> getAllPlaces() {
        List<Map<String, String>> places = Arrays.stream(PlaceTag.values())
                .map(tag -> Map.of(
                        "code", tag.getCode(),
                        "name", tag.getDisplayName()))
                .toList();

        return ResponseEntity.ok(ApiResponse.ok(places));
    }
}
