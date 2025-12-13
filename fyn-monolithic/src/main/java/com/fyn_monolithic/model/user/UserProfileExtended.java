package com.fyn_monolithic.model.user;

import com.fasterxml.jackson.databind.JsonNode;
import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "user_profiles_extended")
public class UserProfileExtended extends AbstractAuditableEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "gender")
    private String gender;

    @Column(name = "gender_identity")
    private String genderIdentity;

    @Column(name = "pronouns")
    private String pronouns;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "looking_for", columnDefinition = "text[]")
    private List<String> lookingFor;

    @Column(name = "relationship_status")
    private String relationshipStatus;

    // Location
    @Column(name = "location_lat")
    private Double locationLat;

    @Column(name = "location_lng")
    private Double locationLng;

    // We can also map a PostGIS Point if needed, but for now individual lat/lng +
    // index is fine
    // Or use Hibernate Spatial:
    // @Column(columnDefinition = "geometry(Point,4326)")
    // private Point location;

    @Column(name = "location_city")
    private String locationCity;

    @Column(name = "location_district")
    private String locationDistrict;

    @Column(name = "location_country")
    private String locationCountry;

    @Column(name = "location_approximate")
    private Boolean locationApproximate;

    @Column(name = "max_distance_km")
    private Integer maxDistanceKm;

    // Matching Preferences
    @Column(name = "preferred_age_min")
    private Integer preferredAgeMin;

    @Column(name = "preferred_age_max")
    private Integer preferredAgeMax;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "preferred_genders", columnDefinition = "varchar[]")
    private List<String> preferredGenders;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "available_days", columnDefinition = "varchar[]")
    private List<String> availableDays;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "available_time_slots", columnDefinition = "jsonb")
    private JsonNode availableTimeSlots;

    @Column(name = "timezone")
    private String timezone;

    // Personality & Interests
    @Column(name = "personality_type")
    private String personalityType;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "interests", columnDefinition = "text[]")
    private List<String> interests;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "languages", columnDefinition = "varchar[]")
    private List<String> languages;

    @Column(name = "occupation")
    private String occupation;

    @Column(name = "company")
    private String company;

    @Column(name = "education")
    private String education;

    @Column(name = "education_level")
    private String educationLevel;

    // Lifestyle
    @Column(name = "smoking")
    private String smoking;

    @Column(name = "drinking")
    private String drinking;

    @Column(name = "diet")
    private String diet;

    @Column(name = "exercise_frequency")
    private String exerciseFrequency;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "pets", columnDefinition = "varchar[]")
    private List<String> pets;

    // Reputation
    @Column(name = "reputation_score")
    private Double reputationScore;

    @Column(name = "total_reviews")
    private Integer totalReviews;

    // Verification
    @Column(name = "is_verified")
    private Boolean isVerified;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    @Column(name = "verification_level")
    private Integer verificationLevel;

    @Column(name = "profile_completeness")
    private Integer profileCompleteness;

    // Activity
    @Column(name = "last_active_at")
    private LocalDateTime lastActiveAt;

    @Column(name = "is_online")
    private Boolean isOnline;
}
