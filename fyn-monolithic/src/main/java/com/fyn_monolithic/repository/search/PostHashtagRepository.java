package com.fyn_monolithic.repository.search;

import com.fyn_monolithic.model.search.PostHashtag;
import com.fyn_monolithic.model.search.Hashtag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PostHashtagRepository extends JpaRepository<PostHashtag, UUID> {
    List<PostHashtag> findByHashtag(Hashtag hashtag);
}
