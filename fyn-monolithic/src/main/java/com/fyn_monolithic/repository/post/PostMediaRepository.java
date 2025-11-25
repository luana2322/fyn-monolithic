package com.fyn_monolithic.repository.post;

import com.fyn_monolithic.model.post.PostMedia;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PostMediaRepository extends JpaRepository<PostMedia, UUID> {
}
