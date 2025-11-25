package com.fyn_monolithic.model.user;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
}
