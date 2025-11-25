package com.fyn_monolithic.service.user;

import com.fyn_monolithic.dto.request.user.UpdateProfileRequest;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserProfile;
import com.fyn_monolithic.repository.user.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UserService userService;
    private final UserProfileRepository profileRepository;
    private final UserMapper userMapper;
    private final com.fyn_monolithic.service.storage.MinioService minioService;

    @Transactional
    public UserResponse updateProfile(UpdateProfileRequest request) {
        User user = userService.getCurrentUser();
        UserProfile profile = Optional.ofNullable(user.getProfile())
                .orElseGet(() -> {
                    UserProfile created = new UserProfile();
                    created.setUser(user);
                    return created;
                });
        profile.setBio(request.getBio());
        profile.setLocation(request.getLocation());
        profile.setWebsite(request.getWebsite());
        profileRepository.save(profile);

        user.setFullName(request.getFullName());
        return buildUserResponseWithPresignedUrl(user);
    }

    @Transactional
    public UserResponse changeAvatar(MultipartFile file) {
        User user = userService.getCurrentUser();
        String objectKey = minioService.upload(file);
        UserProfile profile = Optional.ofNullable(user.getProfile())
                .orElseGet(() -> {
                    UserProfile created = new UserProfile();
                    created.setUser(user);
                    return created;
                });
        profile.setAvatarObjectKey(objectKey);
        profileRepository.save(profile);
        return buildUserResponseWithPresignedUrl(user);
    }
    
    private UserResponse buildUserResponseWithPresignedUrl(User user) {
        UserResponse response = userMapper.toUserResponse(user);
        if (response.getProfile() != null && response.getProfile().getAvatarUrl() != null) {
            try {
                String objectKey = response.getProfile().getAvatarUrl();
                // If it's already a URL, use it; otherwise generate presigned URL
                if (!objectKey.startsWith("http://") && !objectKey.startsWith("https://")) {
                    String presignedUrl = minioService.getPresignedUrl(objectKey);
                    // Rebuild response with presigned URL
                    return UserResponse.builder()
                            .id(response.getId())
                            .username(response.getUsername())
                            .email(response.getEmail())
                            .phone(response.getPhone())
                            .fullName(response.getFullName())
                            .status(response.getStatus())
                            .profile(com.fyn_monolithic.dto.response.user.ProfileResponse.builder()
                                    .bio(response.getProfile().getBio())
                                    .website(response.getProfile().getWebsite())
                                    .location(response.getProfile().getLocation())
                                    .avatarUrl(presignedUrl)
                                    .isPrivate(response.getProfile().isPrivate())
                                    .build())
                            .build();
                }
            } catch (Exception e) {
                // If presigned URL generation fails, keep objectKey
                // Frontend will handle building the URL via /api/files/{key}
            }
        }
        return response;
    }
}
