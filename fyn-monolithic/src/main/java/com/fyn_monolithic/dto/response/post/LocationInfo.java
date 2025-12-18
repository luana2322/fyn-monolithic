package com.fyn_monolithic.dto.response.post;

import lombok.Builder;
import lombok.Value;

/**
 * GPS location information for posts
 */
@Value
@Builder
public class LocationInfo {
    double latitude;
    double longitude;
}
