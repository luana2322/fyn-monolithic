package com.fyn_monolithic.mapper;

import com.fyn_monolithic.dto.response.user.ProfileResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserProfile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @Mapping(target = "profile", expression = "java(toProfileResponse(user.getProfile(), user.getSettings() != null && user.getSettings().isPrivate()))")
    UserResponse toUserResponse(User user);

    default ProfileResponse toProfileResponse(UserProfile profile, boolean isPrivate) {
        if (profile == null) {
            return ProfileResponse.builder()
                    .bio(null)
                    .avatarUrl(null)
                    .location(null)
                    .website(null)
                    .isPrivate(isPrivate)
                    .gender(null)
                    .age(null)
                    .educationLevel(null)
                    .reputationScore(100.0) // Default
                    .build();
        }

        return ProfileResponse.builder()
                .bio(profile.getBio())
                .avatarUrl(profile.getAvatarObjectKey())
                .location(profile.getLocation())
                .website(profile.getWebsite())
                .isPrivate(isPrivate)
                .gender(profile.getGender())
                .age(profile.getAge()) // Calculated from dateOfBirth
                .educationLevel(profile.getEducationLevel())
                .reputationScore(profile.getReputationScore())
                .build();
    }
}
