package com.fyn_monolithic.controller.user;

import com.fyn_monolithic.dto.request.user.SearchUserRequest;
import com.fyn_monolithic.dto.response.common.ApiResponse;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.user.UserListItemResponse;
import com.fyn_monolithic.model.user.Gender;
import com.fyn_monolithic.service.user.UserSearchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller for user search and discovery
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserSearchController {

    private final UserSearchService userSearchService;

    /**
     * Search users with filters
     * 
     * @param keyword  Search text for username, full name, or bio
     * @param gender   Filter by gender
     * @param minAge   Minimum age
     * @param maxAge   Maximum age
     * @param location Location search text
     * @param page     Page number
     * @param size     Page size
     * @return Paginated list of users
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<PageResponse<UserListItemResponse>>> searchUsers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Gender gender,
            @RequestParam(required = false) Integer minAge,
            @RequestParam(required = false) Integer maxAge,
            @RequestParam(required = false) String location,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        // Validate page size
        if (size > 100) {
            size = 100;
        }

        SearchUserRequest request = new SearchUserRequest();
        request.setKeyword(keyword);
        request.setGender(gender);
        request.setMinAge(minAge);
        request.setMaxAge(maxAge);
        request.setLocation(location);

        log.debug("Searching users with filters: keyword={}, gender={}, minAge={}, maxAge={}, location={}",
                keyword, gender, minAge, maxAge, location);

        PageResponse<UserListItemResponse> result = userSearchService.searchUsers(
                request,
                PageRequest.of(page, size));

        return ResponseEntity.ok(ApiResponse.ok(result));
    }
}
