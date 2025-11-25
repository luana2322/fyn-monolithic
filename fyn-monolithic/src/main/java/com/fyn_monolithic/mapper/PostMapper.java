package com.fyn_monolithic.mapper;

import com.fyn_monolithic.dto.response.post.CommentResponse;
import com.fyn_monolithic.dto.response.post.PostMediaResponse;
import com.fyn_monolithic.dto.response.post.PostResponse;
import com.fyn_monolithic.model.post.Post;
import com.fyn_monolithic.model.post.PostComment;
import com.fyn_monolithic.model.post.PostMedia;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;

@Mapper(componentModel = "spring", uses = {UserMapper.class})
public interface PostMapper {

    @Mapping(target = "media", expression = "java(toMediaResponses(post.getMedia()))")
    @Mapping(target = "likedByCurrentUser", constant = "false")
    PostResponse toPostResponse(Post post);

    default List<PostMediaResponse> toMediaResponses(Iterable<PostMedia> media) {
        if (media == null) {
            return List.of();
        }
        return toStream(media).map(this::toMediaResponse).collect(Collectors.toList());
    }

    default List<CommentResponse> toCommentResponses(Iterable<PostComment> comments) {
        if (comments == null) {
            return List.of();
        }
        return toStream(comments).map(this::toCommentResponse).collect(Collectors.toList());
    }

    @Mapping(target = "mediaUrl", source = "objectKey")
    PostMediaResponse toMediaResponse(PostMedia media);

    @Mapping(target = "parentId", expression = "java(comment.getParentComment() != null ? comment.getParentComment().getId() : null)")
    CommentResponse toCommentResponse(PostComment comment);

    private <T> Stream<T> toStream(Iterable<T> iterable) {
        return iterable == null ? Stream.empty() : StreamSupport.stream(iterable.spliterator(), false);
    }
}
