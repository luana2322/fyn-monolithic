package com.fyn_monolithic.repository.user;

import com.fyn_monolithic.model.user.UserProfileExtended;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserProfileExtendedRepository extends JpaRepository<UserProfileExtended, UUID> {
    Optional<UserProfileExtended> findByUserId(UUID userId);

    @Query(value = """
            SELECT * FROM user_profiles_extended u
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(u.location_lng, u.location_lat), 4326),
                ST_SetSRID(ST_MakePoint(:lng, :lat), 4326),
                :radiusInMeters
            )
            AND u.user_id != :excludeUserId
            """, nativeQuery = true)
    List<UserProfileExtended> findNearbyUsers(
            @Param("lat") double lat,
            @Param("lng") double lng,
            @Param("radiusInMeters") double radiusInMeters,
            @Param("excludeUserId") UUID excludeUserId);
}
