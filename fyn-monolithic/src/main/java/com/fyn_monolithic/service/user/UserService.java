package com.fyn_monolithic.service.user;

import com.fyn_monolithic.dto.request.user.UpdateProfileRequest;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserProfile;
import com.fyn_monolithic.repository.user.UserRepository;
import com.fyn_monolithic.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Transactional(readOnly = true)
    public User getCurrentUser() {
        String username = SecurityUtils.getCurrentUsername();
        if (username == null) {
            throw new ResourceNotFoundException("User not authenticated");
        }
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUserProfile() {
        return userMapper.toUserResponse(getCurrentUser());
    }

    @Transactional(readOnly = true)
    public User findEntity(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Transactional(readOnly = true)
    public UserResponse getUser(UUID userId) {
        return userMapper.toUserResponse(findEntity(userId));
    }

    @Transactional(readOnly = true)
    public UserResponse getByUsername(String username) {
        return userRepository.findByUsername(username)
                .map(userMapper::toUserResponse)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Transactional
    public UserResponse updateProfile(UpdateProfileRequest request) {
        User user = getCurrentUser();
        UserProfile profile = user.getProfile();

        if (profile == null) {
            profile = new UserProfile();
            profile.setUser(user);
            user.setProfile(profile);
        }

        // Update existing fields
        if (request.getBio() != null) {
            profile.setBio(request.getBio());
        }
        if (request.getWebsite() != null) {
            profile.setWebsite(request.getWebsite());
        }
        if (request.getLocation() != null) {
            profile.setLocation(request.getLocation());
        }

        // Update new fields
        if (request.getGender() != null) {
            profile.setGender(request.getGender());
        }
        if (request.getDateOfBirth() != null) {
            profile.setDateOfBirth(request.getDateOfBirth());
        }
        if (request.getEducationLevel() != null) {
            profile.setEducationLevel(request.getEducationLevel());
        }

        // Update fullName on User entity
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }

        User savedUser = userRepository.save(user);
        return userMapper.toUserResponse(savedUser);
    }
}
