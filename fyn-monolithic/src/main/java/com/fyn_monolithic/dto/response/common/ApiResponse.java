package com.fyn_monolithic.dto.response.common;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class ApiResponse<T> {
    boolean success;
    String message;
    T data;

    public static <T> ApiResponse<T> ok(T data) {
        return ApiResponse.<T>builder().success(true).data(data).build();
    }

    public static <T> ApiResponse<T> message(String message) {
        return ApiResponse.<T>builder().success(true).message(message).build();
    }
}
