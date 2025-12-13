package com.fyn_monolithic.service.date;

import com.fyn_monolithic.dto.response.date.UserSummary;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.date.Meetup;
import com.fyn_monolithic.model.date.MeetupStatus;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.date.MeetupRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MeetupService {

    private final MeetupRepository meetupRepository;
    private final UserRepository userRepository;

    /**
     * Create a new meetup
     */
    @Transactional
    public Map<String, Object> createMeetup(UUID organizerId, Map<String, Object> request) {
        User organizer = userRepository.findById(organizerId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Meetup meetup = new Meetup();
        meetup.setOrganizer(organizer);
        meetup.setTitle((String) request.get("title"));
        meetup.setDescription((String) request.get("description"));
        meetup.setCategory((String) request.get("category"));
        meetup.setLocation((String) request.get("location"));

        if (request.get("latitude") != null) {
            meetup.setLatitude(((Number) request.get("latitude")).doubleValue());
        }
        if (request.get("longitude") != null) {
            meetup.setLongitude(((Number) request.get("longitude")).doubleValue());
        }

        // Parse scheduledAt - accept both String and ZonedDateTime
        Object scheduledAtObj = request.get("scheduledAt");
        if (scheduledAtObj instanceof String) {
            meetup.setScheduledAt(ZonedDateTime.parse((String) scheduledAtObj));
        } else if (scheduledAtObj != null) {
            meetup.setScheduledAt((ZonedDateTime) scheduledAtObj);
        }

        if (request.get("maxParticipants") != null) {
            meetup.setMaxParticipants(((Number) request.get("maxParticipants")).intValue());
        }

        meetup.setStatus(MeetupStatus.OPEN);
        meetup = meetupRepository.save(meetup);

        return toMeetupResponse(meetup);
    }

    /**
     * Get list of open meetups
     */
    public Page<Map<String, Object>> getMeetups(String category, Pageable pageable) {
        Page<Meetup> meetups;
        if (category != null && !category.isEmpty()) {
            meetups = meetupRepository.findByCategoryAndStatusOrderByScheduledAtAsc(
                    category, MeetupStatus.OPEN, pageable);
        } else {
            meetups = meetupRepository.findByStatusOrderByScheduledAtAsc(MeetupStatus.OPEN, pageable);
        }
        return meetups.map(this::toMeetupResponse);
    }

    /**
     * Get meetup details
     */
    public Map<String, Object> getMeetupDetails(UUID meetupId) {
        Meetup meetup = meetupRepository.findById(meetupId)
                .orElseThrow(() -> new ResourceNotFoundException("Meetup not found"));
        return toMeetupResponse(meetup);
    }

    /**
     * Join a meetup
     */
    @Transactional
    public void joinMeetup(UUID meetupId, UUID userId) {
        Meetup meetup = meetupRepository.findById(meetupId)
                .orElseThrow(() -> new ResourceNotFoundException("Meetup not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!meetup.canJoin(user)) {
            if (meetup.isFull()) {
                throw new BadRequestException("Meetup is full");
            }
            if (meetup.getParticipants().contains(user)) {
                throw new BadRequestException("Already joined this meetup");
            }
            throw new BadRequestException("Cannot join this meetup");
        }

        meetup.getParticipants().add(user);

        // Auto-update status if full
        if (meetup.isFull()) {
            meetup.setStatus(MeetupStatus.FULL);
        }

        meetupRepository.save(meetup);
    }

    /**
     * Leave a meetup
     */
    @Transactional
    public void leaveMeetup(UUID meetupId, UUID userId) {
        Meetup meetup = meetupRepository.findById(meetupId)
                .orElseThrow(() -> new ResourceNotFoundException("Meetup not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!meetup.getParticipants().contains(user)) {
            throw new BadRequestException("Not a participant of this meetup");
        }

        meetup.getParticipants().remove(user);

        // Reopen if was full
        if (meetup.getStatus() == MeetupStatus.FULL) {
            meetup.setStatus(MeetupStatus.OPEN);
        }

        meetupRepository.save(meetup);
    }

    /**
     * Cancel a meetup (organizer only)
     */
    @Transactional
    public void cancelMeetup(UUID meetupId, UUID userId) {
        Meetup meetup = meetupRepository.findById(meetupId)
                .orElseThrow(() -> new ResourceNotFoundException("Meetup not found"));

        if (!meetup.getOrganizer().getId().equals(userId)) {
            throw new BadRequestException("Only the organizer can cancel this meetup");
        }

        meetup.setStatus(MeetupStatus.CANCELLED);
        meetupRepository.save(meetup);
    }

    private Map<String, Object> toMeetupResponse(Meetup meetup) {
        List<UserSummary> participants = meetup.getParticipants().stream()
                .map(UserSummary::fromUser)
                .collect(Collectors.toList());

        Map<String, Object> response = new java.util.HashMap<>();
        response.put("id", meetup.getId());
        response.put("title", meetup.getTitle());
        response.put("description", meetup.getDescription() != null ? meetup.getDescription() : "");
        response.put("category", meetup.getCategory());
        response.put("location", meetup.getLocation() != null ? meetup.getLocation() : "");
        response.put("scheduledAt", meetup.getScheduledAt().toString());
        response.put("maxParticipants", meetup.getMaxParticipants());
        response.put("participantCount", meetup.getParticipantCount());
        response.put("spotsLeft", meetup.getSpotsLeft());
        response.put("status", meetup.getStatus().name());
        response.put("organizer", UserSummary.fromUser(meetup.getOrganizer()));
        response.put("participants", participants);
        return response;
    }
}
