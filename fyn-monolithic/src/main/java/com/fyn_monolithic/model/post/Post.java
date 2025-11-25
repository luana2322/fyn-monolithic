package com.fyn_monolithic.model.post;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import com.fyn_monolithic.model.search.PostHashtag;
import com.fyn_monolithic.model.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "posts")
public class Post extends AbstractAuditableEntity {

    @ManyToOne
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    @Column(name = "content", length = 2048)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility", nullable = false)
    private PostVisibility visibility = PostVisibility.PUBLIC;

    @Column(name = "comment_count", nullable = false)
    private long commentCount = 0;

    @Column(name = "like_count", nullable = false)
    private long likeCount = 0;

    @OneToMany(mappedBy = "post")
    private Set<PostMedia> media = new LinkedHashSet<>();

    @OneToMany(mappedBy = "post")
    private Set<PostComment> comments = new LinkedHashSet<>();

    @OneToMany(mappedBy = "post")
    private Set<PostLike> likes = new LinkedHashSet<>();

    @OneToMany(mappedBy = "post")
    private Set<PostHashtag> hashtags = new LinkedHashSet<>();

    public void increaseLikeCount() {
        this.likeCount = this.likeCount + 1;
    }

    public void decreaseLikeCount() {
        if (this.likeCount > 0) {
            this.likeCount = this.likeCount - 1;
        }
    }

    public void increaseCommentCount() {
        this.commentCount = this.commentCount + 1;
    }

    public void decreaseCommentCount() {
        if (this.commentCount > 0) {
            this.commentCount = this.commentCount - 1;
        }
    }
}
