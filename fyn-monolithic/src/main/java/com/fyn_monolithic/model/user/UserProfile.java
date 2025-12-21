package com.fyn_monolithic.model.user;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_profiles")
public class UserProfile extends AbstractAuditableEntity {

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "bio", length = 512)
    private String bio;

    @Column(name = "website")
    private String website;

    @Column(name = "location")
    private String location;

    @Column(name = "avatar_object_key")
    private String avatarObjectKey;

    @Column(name = "reputation_score")
    private Double reputationScore = 100.0; // Default 100, decreases on no-show

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private Gender gender;

    @Column(name = "date_of_birth")
    private java.time.LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(name = "education_level")
    private EducationLevel educationLevel;

    @Column(name = "total_meets_completed")
    private Integer totalMeetsCompleted = 0;

    @Column(name = "total_meets_cancelled")
    private Integer totalMeetsCancelled = 0;

    @Column(name = "total_no_shows")
    private Integer totalNoShows = 0;

    /**
     * Calculate age from date of birth
     * 
     * @return age in years, or null if date of birth not set
     */
    public Integer getAge() {
        if (dateOfBirth == null) {
            return null;
        }
        return java.time.Period.between(dateOfBirth, java.time.LocalDate.now()).getYears();
    }

    /**
     * Calculate cancellation rate
     * 
     * @return cancellation rate (0.0 to 1.0)
     */
    public double getCancellationRate() {
        int total = totalMeetsCompleted + totalMeetsCancelled + totalNoShows;
        return total > 0 ? (double) totalMeetsCancelled / total : 0.0;
    }
}
