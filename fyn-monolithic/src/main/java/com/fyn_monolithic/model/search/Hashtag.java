package com.fyn_monolithic.model.search;

import com.fyn_monolithic.model.common.AbstractAuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "hashtags")
public class Hashtag extends AbstractAuditableEntity {

    @Column(name = "tag", nullable = false, unique = true)
    private String tag;

    @Column(name = "usage_count", nullable = false)
    private long usageCount = 0;

    @OneToMany(mappedBy = "hashtag")
    private Set<PostHashtag> posts = new LinkedHashSet<>();
}
