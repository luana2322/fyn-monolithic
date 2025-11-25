package com.fyn_monolithic.controller.search;

import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.post.PostResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.service.search.SearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping("/hashtags")
    public ResponseEntity<ApiResponse<List<PostResponse>>> searchByHashtag(@RequestParam String tag) {
        return ResponseEntity.ok(ApiResponse.ok(searchService.searchByHashtag(tag)));
    }

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<UserResponse>>> searchUsers(@RequestParam("query") String query) {
        return ResponseEntity.ok(ApiResponse.ok(searchService.searchUsers(query)));
    }
}
