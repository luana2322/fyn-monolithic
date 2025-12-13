package com.fyn_monolithic.service.event;

import com.fyn_monolithic.dto.request.event.CreateEventRequest;
import com.fyn_monolithic.dto.response.event.EventResponse;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.mapper.event.EventMapper;
import com.fyn_monolithic.model.event.Event;
import com.fyn_monolithic.model.event.EventStatus;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.event.EventRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final UserRepository userRepository;
    private final EventMapper eventMapper;

    private static final Pattern NONLATIN = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE = Pattern.compile("[\\s]");

    @Transactional
    public EventResponse createEvent(UUID userId, CreateEventRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        Event event = eventMapper.toEntity(request);
        event.setCreatedBy(user);

        // Generate Slug
        String slug = toSlug(event.getTitle());
        event.setSlug(slug + "-" + UUID.randomUUID().toString().substring(0, 8));

        event = eventRepository.save(event);
        return eventMapper.toResponse(event);
    }

    @Transactional(readOnly = true)
    public Page<EventResponse> getNearbyEvents(Double lat, Double lng, Double radiusInMeters, Pageable pageable) {
        // Implement logic to handle null lat/lng if needed, or default
        if (lat == null || lng == null) {
            return eventRepository.findByStatusAndStartTimeAfter(EventStatus.OPEN, LocalDateTime.now(), pageable)
                    .map(eventMapper::toResponse);
        }

        return eventRepository.findNearbyPublicEvents(lat, lng, radiusInMeters, LocalDateTime.now(), pageable)
                .map(eventMapper::toResponse);
    }

    @Transactional(readOnly = true)
    public EventResponse getEvent(UUID eventId) {
        return eventRepository.findById(eventId)
                .map(eventMapper::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Event not found: " + eventId));
    }

    private String toSlug(String input) {
        String nowhitespace = WHITESPACE.matcher(input).replaceAll("-");
        String normalized = Normalizer.normalize(nowhitespace, Normalizer.Form.NFD);
        String slug = NONLATIN.matcher(normalized).replaceAll("");
        return slug.toLowerCase(Locale.ENGLISH);
    }
}
