package com.fyn_monolithic.mapper.event;

import com.fyn_monolithic.dto.request.event.CreateEventRequest;
import com.fyn_monolithic.dto.response.event.EventResponse;
import com.fyn_monolithic.mapper.UserMapper;
import com.fyn_monolithic.model.event.Event;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE, uses = { UserMapper.class })
public interface EventMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "slug", ignore = true) // Handle slug generation in service
    @Mapping(target = "status", constant = "OPEN") // Default open for now
    @Mapping(target = "currentParticipants", constant = "0")
    @Mapping(target = "waitlistCount", constant = "0")
    @Mapping(target = "createdBy", ignore = true) // Set manually
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "version", ignore = true)
    Event toEntity(CreateEventRequest request);

    @Mapping(target = "createdBy", source = "createdBy") // Uses UserMapper
    EventResponse toResponse(Event event);

    default java.time.LocalDateTime map(java.time.Instant instant) {
        return instant == null ? null : java.time.LocalDateTime.ofInstant(instant, java.time.ZoneId.systemDefault());
    }
}
