package com.fyn_monolithic.service.search;

import com.fyn_monolithic.dto.response.post.PostResponse;
import com.fyn_monolithic.dto.response.user.UserResponse;
import com.fyn_monolithic.mapper.PostMapper;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.search.PostHashtag;
import com.fyn_monolithic.repository.search.HashtagRepository;
import com.fyn_monolithic.repository.search.PostHashtagRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final HashtagRepository hashtagRepository;
    private final PostHashtagRepository postHashtagRepository;
    private final PostMapper postMapper;
    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Transactional(readOnly = true)
    public List<PostResponse> searchByHashtag(String tag) {
        return hashtagRepository.findByTag(tag.toLowerCase())
                .map(found -> postHashtagRepository.findByHashtag(found).stream()
                        .map(PostHashtag::getPost)
                        .map(postMapper::toPostResponse)
                        .toList())
                .orElse(List.of());
    }

    @Transactional(readOnly = true)
    public List<UserResponse> searchUsers(String query) {
        final String keyword = query == null ? "" : query.trim();
        if (keyword.isEmpty()) {
            return List.of();
        }
        return userRepository
                .findTop20ByUsernameContainingIgnoreCaseOrFullNameContainingIgnoreCase(keyword, keyword)
                .stream()
                .map(userMapper::toUserResponse)
                .toList();
    }
}
