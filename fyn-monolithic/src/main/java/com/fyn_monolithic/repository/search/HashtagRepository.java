package com.fyn_monolithic.repository.search;

import com.fyn_monolithic.model.search.Hashtag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface HashtagRepository extends JpaRepository<Hashtag, UUID> {
    Optional<Hashtag> findByTag(String tag);
}
