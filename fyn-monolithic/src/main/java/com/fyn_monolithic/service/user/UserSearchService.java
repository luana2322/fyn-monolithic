package com.fyn_monolithic.service.user;

import com.fyn_monolithic.dto.request.user.SearchUserRequest;
import com.fyn_monolithic.dto.response.common.PageResponse;
import com.fyn_monolithic.dto.response.user.UserListItemResponse;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.user.Gender;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserProfile;
import com.fyn_monolithic.repository.user.UserRepository;
import com.fyn_monolithic.service.storage.MinioService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import jakarta.persistence.criteria.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for searching and filtering users
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserSearchService {

    private final UserRepository userRepository;
    private final EntityManager entityManager;
    private final MinioService minioService;

    /**
     * Search users with filters
     * 
     * @param request  Search criteria
     * @param pageable Pagination
     * @return Page of user list items
     */
    @Transactional(readOnly = true)
    public PageResponse<UserListItemResponse> searchUsers(SearchUserRequest request, Pageable pageable) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<User> query = cb.createQuery(User.class);
        Root<User> user = query.from(User.class);
        Join<User, UserProfile> profile = user.join("profile", JoinType.LEFT);

        List<Predicate> predicates = new ArrayList<>();

        // Filter by gender
        if (request.getGender() != null) {
            predicates.add(cb.equal(profile.get("gender"), request.getGender()));
        }

        // Filter by age range
        if (request.getMinAge() != null || request.getMaxAge() != null) {
            LocalDate now = LocalDate.now();

            if (request.getMinAge() != null) {
                // Max birth year for min age
                LocalDate maxBirthDate = now.minusYears(request.getMinAge());
                predicates.add(cb.lessThanOrEqualTo(profile.get("dateOfBirth"), maxBirthDate));
            }

            if (request.getMaxAge() != null) {
                // Min birth year for max age
                LocalDate minBirthDate = now.minusYears(request.getMaxAge() + 1);
                predicates.add(cb.greaterThan(profile.get("dateOfBirth"), minBirthDate));
            }
        }

        // Filter by location (simple text match)
        if (request.getLocation() != null && !request.getLocation().isBlank()) {
            predicates.add(cb.like(cb.lower(profile.get("location")),
                    "%" + request.getLocation().toLowerCase() + "%"));
        }

        // Exclude users without profiles or with null dateOfBirth for age filtering
        if (request.getMinAge() != null || request.getMaxAge() != null) {
            predicates.add(cb.isNotNull(profile.get("dateOfBirth")));
        }

        query.where(predicates.toArray(new Predicate[0]));
        query.orderBy(cb.desc(user.get("createdAt")));

        // Execute query with pagination
        TypedQuery<User> typedQuery = entityManager.createQuery(query);
        typedQuery.setFirstResult((int) pageable.getOffset());
        typedQuery.setMaxResults(pageable.getPageSize());

        List<User> users = typedQuery.getResultList();

        // Count total results
        CriteriaQuery<Long> countQuery = cb.createQuery(Long.class);
        Root<User> countRoot = countQuery.from(User.class);
        Join<User, UserProfile> countProfile = countRoot.join("profile", JoinType.LEFT);

        List<Predicate> countPredicates = new ArrayList<>();
        if (request.getGender() != null) {
            countPredicates.add(cb.equal(countProfile.get("gender"), request.getGender()));
        }
        if (request.getMinAge() != null || request.getMaxAge() != null) {
            LocalDate now = LocalDate.now();
            if (request.getMinAge() != null) {
                LocalDate maxBirthDate = now.minusYears(request.getMinAge());
                countPredicates.add(cb.lessThanOrEqualTo(countProfile.get("dateOfBirth"), maxBirthDate));
            }
            if (request.getMaxAge() != null) {
                LocalDate minBirthDate = now.minusYears(request.getMaxAge() + 1);
                countPredicates.add(cb.greaterThan(countProfile.get("dateOfBirth"), minBirthDate));
            }
            countPredicates.add(cb.isNotNull(countProfile.get("dateOfBirth")));
        }
        if (request.getLocation() != null && !request.getLocation().isBlank()) {
            countPredicates.add(cb.like(cb.lower(countProfile.get("location")),
                    "%" + request.getLocation().toLowerCase() + "%"));
        }

        countQuery.select(cb.count(countRoot));
        countQuery.where(countPredicates.toArray(new Predicate[0]));
        Long total = entityManager.createQuery(countQuery).getSingleResult();

        // Convert to DTOs
        List<UserListItemResponse> responseList = users.stream()
                .map(this::toUserListItemResponse)
                .collect(Collectors.toList());

        int totalPages = (int) Math.ceil((double) total / pageable.getPageSize());

        return PageResponse.<UserListItemResponse>builder()
                .content(responseList)
                .page(pageable.getPageNumber())
                .size(pageable.getPageSize())
                .totalElements(total)
                .totalPages(totalPages)
                .build();
    }

    /**
     * Convert User entity to UserListItemResponse
     */
    private UserListItemResponse toUserListItemResponse(User user) {
        UserProfile profile = user.getProfile();

        String avatarUrl = null;
        if (profile != null && profile.getAvatarObjectKey() != null) {
            avatarUrl = minioService.getPresignedUrl(profile.getAvatarObjectKey());
        }

        return UserListItemResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .age(profile != null ? profile.getAge() : null)
                .gender(profile != null ? profile.getGender() : null)
                .bio(profile != null ? profile.getBio() : null)
                .avatarUrl(avatarUrl)
                .location(profile != null ? profile.getLocation() : null)
                .distanceKm(null) // TODO: Implement distance calculation
                .isOnline(false) // TODO: Implement online status
                .reputationScore(profile != null ? profile.getReputationScore() : null)
                .build();
    }
}
