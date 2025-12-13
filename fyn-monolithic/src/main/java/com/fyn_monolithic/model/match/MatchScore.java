package com.fyn_monolithic.model.match;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "match_scores")
public class MatchScore extends AbstractAuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id_1", nullable = false)
    private User user1;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id_2", nullable = false)
    private User user2;

    @Column(name = "total_score")
    private Double totalScore;

    @Column(name = "interest_score")
    private Double interestScore;

    @Column(name = "location_score")
    private Double locationScore;

    @Column(name = "activity_score")
    private Double activityScore;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "common_interests", columnDefinition = "text[]")
    private List<String> commonInterests;
}
