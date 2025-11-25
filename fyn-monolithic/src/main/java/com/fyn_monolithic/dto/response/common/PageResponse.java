package com.fyn_monolithic.dto.response.common;

import lombok.Builder;
import lombok.Value;

import java.util.List;

@Value
@Builder
public class PageResponse<T> {
    List<T> content;
    long totalElements;
    int totalPages;
    int page;
    int size;
}
