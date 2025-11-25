package com.fyn_monolithic.mapper;

import com.fyn_monolithic.dto.response.notification.NotificationResponse;
import com.fyn_monolithic.model.notification.Notification;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NotificationMapper {
    NotificationResponse toResponse(Notification notification);
}
