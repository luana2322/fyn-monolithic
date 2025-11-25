package com.fyn_monolithic.model.user;

import com.fyn_monolithic.model.auth.UserToken;
import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.message.ConversationMember;
import com.fyn_monolithic.model.notification.Notification;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostComment;
import com.fyn_monolithic.model.post.PostLike;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "users")
public class User extends AbstractAuditableEntity {

    @Column(name = "email", unique = true, nullable = false)
    private String email;

    @Column(name = "phone", unique = true)
    private String phone;

    @Column(name = "username", unique = true, nullable = false)
    private String username;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "full_name")
    private String fullName;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private UserStatus status = UserStatus.PENDING_VERIFICATION;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private UserProfile profile;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private UserSettings settings;

    @OneToMany(mappedBy = "user")
    @ToString.Exclude
    private Set<UserFollower> followers = new LinkedHashSet<>();

    @OneToMany(mappedBy = "follower")
    @ToString.Exclude
    private Set<UserFollower> following = new LinkedHashSet<>();

    @OneToMany(mappedBy = "author")
    @ToString.Exclude
    private Set<Post> posts = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user")
    @ToString.Exclude
    private Set<PostLike> likes = new LinkedHashSet<>();

    @OneToMany(mappedBy = "author")
    @ToString.Exclude
    private Set<PostComment> comments = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user")
    @ToString.Exclude
    private Set<UserToken> tokens = new LinkedHashSet<>();

    @OneToMany(mappedBy = "recipient")
    @ToString.Exclude
    private Set<Notification> notifications = new LinkedHashSet<>();

    @OneToMany(mappedBy = "member")
    @ToString.Exclude
    private Set<ConversationMember> conversations = new LinkedHashSet<>();
}
