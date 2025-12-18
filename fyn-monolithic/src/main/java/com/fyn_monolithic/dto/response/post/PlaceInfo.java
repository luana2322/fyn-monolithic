package com.fyn_monolithic.dto.response.post;

import lombok.Builder;
import lombok.Value;

/**
 * Place tag information for posts
 */
@Value
@Builder
public class PlaceInfo {
    String code;
    String name;
}
