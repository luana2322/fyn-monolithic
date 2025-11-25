package com.fyn_monolithic.repository.user;

import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.model.user.UserFollower;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserFollowerRepository extends JpaRepository<UserFollower, UUID> {
    long countByUser(User user);
    long countByFollower(User follower);
    List<UserFollower> findByUser(User user);
    List<UserFollower> findByFollower(User follower);
    Optional<UserFollower> findByUserAndFollower(User user, User follower);
}
