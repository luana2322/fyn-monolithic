package com.fyn_monolithic.service.date;

import com.fyn_monolithic.dto.request.date.CreateMeetupRequest;
import com.fyn_monolithic.dto.request.date.UpdateMeetupRequest;
import com.fyn_monolithic.dto.request.date.MeetupFeedbackRequest;
import com.fyn_monolithic.dto.response.date.MeetupMatchResponse;
import com.fyn_monolithic.dto.response.date.MeetupResponse;
import com.fyn_monolithic.dto.response.date.UserSummary;
import com.fyn_monolithic.dto.response.message.ConversationResponse;
import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ForbiddenException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.date.*;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.date.MeetupMatchRepository;
import com.fyn_monolithic.repository.date.MeetupRepository;
import com.fyn_monolithic.repository.date.MeetupConfirmationRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import com.fyn_monolithic.service.message.ConversationService;
import com.fyn_monolithic.service.message.GroupChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Service for meetup match system (discovery, apply, accept, confirm)
 */
@Service
@RequiredArgsConstructor
public class MeetupMatchService {

    private final MeetupRepository meetupRepository;
    private final MeetupMatchRepository meetupMatchRepository;
    private final MeetupConfirmationRepository confirmationRepository;
    private final UserRepository userRepository;
    private final ConversationService conversationService;
    private final GroupChatService groupChatService;

    /**
     * Create a meetup
     */
    @Transactional
    public MeetupResponse createMeetup(UUID userId, CreateMeetupRequest request) {
        User user = getUser(userId);

        // Validate meet type and max participants
        if (request.meetType() == MeetType.ONE_TO_ONE && request.maxParticipants() != 1) {
            throw new BadRequestException("1-1 meets must have maxParticipants = 1");
        }

        Meetup meetup = new Meetup();
        meetup.setOrganizer(user);
        meetup.setTitle(request.title());
        meetup.setDescription(request.description());
        meetup.setMeetType(request.meetType());
        meetup.setLocation(request.location());
        meetup.setLatitude(request.latitude());
        meetup.setLongitude(request.longitude());
        meetup.setScheduledAt(request.scheduledAt());
        meetup.setExpiresAt(request.expiresAt());
        meetup.setDurationMinutes(request.durationMinutes() != null ? request.durationMinutes() : 120);
        meetup.setMaxParticipants(request.maxParticipants());
        meetup.setCategory(request.category());
        meetup.setStatus(MeetupStatus.OPEN);

        meetup = meetupRepository.save(meetup);
        return toResponse(meetup, userId);
    }

    /**
     * Update a meetup
     */
    @Transactional
    public MeetupResponse updateMeetup(UUID meetupId, UUID userId, UpdateMeetupRequest request) {
        Meetup meetup = getMeetup(meetupId);

        if (!meetup.getOrganizer().getId().equals(userId)) {
            throw new ForbiddenException("Only the organizer can update the meetup");
        }

        if (meetup.getStatus() != MeetupStatus.OPEN && meetup.getStatus() != MeetupStatus.MATCHED) {
            throw new BadRequestException("Cannot update meetup in its current status: " + meetup.getStatus());
        }

        meetup.setTitle(request.title());
        meetup.setDescription(request.description());
        meetup.setMeetType(request.meetType());
        meetup.setLocation(request.location());
        meetup.setLatitude(request.latitude());
        meetup.setLongitude(request.longitude());
        meetup.setScheduledAt(request.scheduledAt());
        meetup.setExpiresAt(request.expiresAt());
        meetup.setDurationMinutes(request.durationMinutes() != null ? request.durationMinutes() : 120);
        meetup.setMaxParticipants(request.maxParticipants());
        meetup.setCategory(request.category());

        meetup = meetupRepository.save(meetup);
        return toResponse(meetup, userId);
    }

    /**
     * Get a single meetup detail
     */
    @Transactional(readOnly = true)
    public MeetupResponse getMeetupById(UUID meetupId, UUID userId) {
        Meetup meetup = getMeetup(meetupId);
        return toResponse(meetup, userId);
    }

    /**
     * Discover nearby meetups with filters
     */
    @Transactional(readOnly = true)
    public Page<MeetupResponse> discoverMeetups(
            UUID userId,
            Double userLat,
            Double userLng,
            Double radiusKm,
            MeetType meetType,
            String category,
            ZonedDateTime afterDate,
            String sortBy,
            Pageable pageable) {

        Page<Meetup> meetups = meetupRepository.findNearbyMeetups(
                userId, userLat, userLng, radiusKm, meetType, category,
                afterDate, sortBy != null ? sortBy : "soonest", pageable);

        return meetups.map(m -> toResponse(m, userId));
    }

    /**
     * Get meetups organized by a specific user
     */
    @Transactional(readOnly = true)
    public Page<MeetupResponse> getMeetupsByOrganizer(
            UUID organizerId,
            String category,
            Pageable pageable) {

        Page<Meetup> meetups = meetupRepository.findByOrganizerIdOrderByScheduledAtDesc(organizerId, pageable);

        return meetups.map(m -> toResponse(m, organizerId));
    }

    /**
     * Get meetups that the current user has applied to
     */
    @Transactional(readOnly = true)
    public Page<MeetupMatchResponse> getMyAppliedMeetups(
            UUID userId,
            MatchStatus status,
            Pageable pageable) {

        Page<MeetupMatch> matches = status != null
                ? meetupMatchRepository.findByUserIdAndStatus(userId, status, pageable)
                : meetupMatchRepository.findByUserId(userId, pageable);

        return matches.map(this::toMatchResponseWithMeetup);
    }

    /**
     * Get meetup history (completed, cancelled, expired) for a user
     */
    @Transactional(readOnly = true)
    public Page<MeetupResponse> getMeetupHistory(UUID userId, Pageable pageable) {
        Page<Meetup> meetups = meetupRepository.findMeetupHistory(userId, pageable);
        return meetups.map(m -> toResponse(m, userId));
    }

    /**
     * Get meetups awaiting confirmation for a user
     */
    @Transactional(readOnly = true)
    public Page<MeetupResponse> getAwaitingConfirmation(UUID userId, Pageable pageable) {
        Page<Meetup> meetups = meetupRepository.findMeetupsAwaitingConfirmation(userId, pageable);
        return meetups.map(m -> toResponse(m, userId));
    }

    private MeetupMatchResponse toMatchResponseWithMeetup(MeetupMatch match) {
        return new MeetupMatchResponse(
                match.getId(),
                match.getMeetup().getId(),
                UserSummary.fromUser(match.getUser()),
                match.getMessage(),
                match.getStatus(),
                match.getConversationId(),
                match.getCreatedAt(),
                match.getRespondedAt());
    }

    /**
     * Apply/Match to a meetup
     */
    @Transactional
    public MeetupMatchResponse applyToMeetup(UUID meetupId, UUID userId, String message) {
        Meetup meetup = getMeetup(meetupId);
        User user = getUser(userId);

        // Validations
        if (meetup.getOrganizer().getId().equals(userId)) {
            throw new BadRequestException("Cannot apply to your own meetup");
        }

        if (meetup.getStatus() != MeetupStatus.OPEN && meetup.getStatus() != MeetupStatus.MATCHED) {
            throw new BadRequestException("Meetup is not accepting applications");
        }

        if (meetupMatchRepository.existsByMeetupIdAndUserId(meetupId, userId)) {
            throw new BadRequestException("Already applied to this meetup");
        }

        if (meetup.isFull()) {
            throw new BadRequestException("Meetup is full");
        }

        if (meetup.getExpiresAt() != null && meetup.getExpiresAt().isBefore(ZonedDateTime.now())) {
            throw new BadRequestException("Application period has expired");
        }

        // Create match request
        MeetupMatch match = new MeetupMatch();
        match.setMeetup(meetup);
        match.setUser(user);
        match.setMessage(message);
        match.setStatus(MatchStatus.PENDING);
        match.setCreatedAt(ZonedDateTime.now()); // Set manually to ensure it's not null in response

        match = meetupMatchRepository.save(match);
        return toMatchResponse(match);
    }

    /**
     * Get match requests (organizer only)
     */
    public Page<MeetupMatchResponse> getMatchRequests(
            UUID meetupId,
            UUID organizerId,
            MatchStatus status,
            Pageable pageable) {

        Meetup meetup = getMeetup(meetupId);

        if (!meetup.getOrganizer().getId().equals(organizerId)) {
            throw new ForbiddenException("Only organizer can view match requests");
        }

        Page<MeetupMatch> matches = status != null
                ? meetupMatchRepository.findByMeetupIdAndStatus(meetupId, status, pageable)
                : meetupMatchRepository.findByMeetupId(meetupId, pageable);

        return matches.map(this::toMatchResponse);
    }

    /**
     * Accept a match
     */
    @Transactional
    public void acceptMatch(UUID matchId, UUID organizerId) {
        MeetupMatch match = getMatch(matchId);
        Meetup meetup = match.getMeetup();

        // Verify organizer
        if (!meetup.getOrganizer().getId().equals(organizerId)) {
            throw new ForbiddenException("Only organizer can accept matches");
        }

        if (match.getStatus() != MatchStatus.PENDING) {
            throw new BadRequestException("Match already processed");
        }

        if (meetup.isFull()) {
            throw new BadRequestException("Meetup is full");
        }

        // Accept match
        match.setStatus(MatchStatus.ACCEPTED);
        match.setRespondedAt(ZonedDateTime.now());

        // Add to accepted participants
        meetup.getAcceptedParticipants().add(match.getUser());

        // Create/update chat based on meetup type
        if (meetup.isOneToOne()) {
            // For 1-1: Create direct conversation linked to this match
            if (match.getConversationId() == null) {
                initiateChat(match, organizerId);
            }
        } else {
            // For GROUP: Create or get group chat and add new member
            var groupChat = groupChatService.getOrCreateMeetupGroupChat(meetup, meetup.getOrganizer());
            groupChatService.addAcceptedMemberToGroupChat(meetup.getId(), match.getUser());
            // Store group chat ID in match for reference
            match.setConversationId(groupChat.getId());
        }

        match = meetupMatchRepository.save(match);

        // AUTO-REJECT LOGIC
        if (meetup.isOneToOne()) {
            // For 1-1: Auto reject all other pending requests
            List<MeetupMatch> otherPending = meetupMatchRepository
                    .findByMeetupIdAndStatus(meetup.getId(), MatchStatus.PENDING, Pageable.unpaged())
                    .getContent();

            for (MeetupMatch other : otherPending) {
                if (!other.getId().equals(matchId)) {
                    other.setStatus(MatchStatus.REJECTED);
                    other.setRespondedAt(ZonedDateTime.now());
                    meetupMatchRepository.save(other);
                }
            }
        }

        // If full, auto close and reject remaining
        if (meetup.isFull()) {
            meetup.setStatus(MeetupStatus.MATCHED);

            // Auto reject all other pending requests
            List<MeetupMatch> pending = meetupMatchRepository
                    .findByMeetupIdAndStatus(meetup.getId(), MatchStatus.PENDING, Pageable.unpaged())
                    .getContent();

            for (MeetupMatch p : pending) {
                p.setStatus(MatchStatus.REJECTED);
                p.setRespondedAt(ZonedDateTime.now());
                meetupMatchRepository.save(p);
            }
        }

        meetupRepository.save(meetup);
    }

    /**
     * Initiate chat for a match request without accepting it
     */
    @Transactional
    public MeetupMatchResponse initiateChat(UUID matchId, UUID organizerId) {
        MeetupMatch match = getMatch(matchId);
        Meetup meetup = match.getMeetup();

        if (!meetup.getOrganizer().getId().equals(organizerId)) {
            throw new ForbiddenException("Only organizer can initiate chat");
        }

        if (match.getConversationId() != null) {
            return toMatchResponse(match);
        }

        initiateChat(match, organizerId);
        match = meetupMatchRepository.save(match);
        return toMatchResponse(match);
    }

    private void initiateChat(MeetupMatch match, UUID organizerId) {
        String chatTitle = "Chat: " + match.getMeetup().getTitle();
        ConversationResponse conversationResponse = conversationService.createConversationForMatch(
                match.getId(),
                organizerId,
                match.getUser().getId(),
                chatTitle);
        match.setConversationId(conversationResponse.getId());
    }

    /**
     * Reject a match
     */
    @Transactional
    public void rejectMatch(UUID matchId, UUID organizerId) {
        MeetupMatch match = getMatch(matchId);
        Meetup meetup = match.getMeetup();

        if (!meetup.getOrganizer().getId().equals(organizerId)) {
            throw new ForbiddenException("Only organizer can reject matches");
        }

        if (match.getStatus() != MatchStatus.PENDING) {
            throw new BadRequestException("Match already processed");
        }

        match.setStatus(MatchStatus.REJECTED);
        match.setRespondedAt(ZonedDateTime.now());
        meetupMatchRepository.save(match);
    }

    /**
     * Confirm meetup completion (post-meet) with result tracking
     * 
     * @param request The feedback request containing result, comment and rating
     */
    @Transactional
    public void confirmMeetup(UUID meetupId, UUID userId, MeetupFeedbackRequest request) {
        Meetup meetup = getMeetup(meetupId);
        User user = getUser(userId);

        MeetupConfirmation.ConfirmationResult result = MeetupConfirmation.ConfirmationResult.valueOf(request.result());

        boolean isOrganizer = meetup.getOrganizer().getId().equals(userId);
        boolean isParticipant = meetup.getAcceptedParticipants().stream()
                .anyMatch(p -> p.getId().equals(userId));

        if (!isOrganizer && !isParticipant) {
            throw new ForbiddenException("Only participants can confirm");
        }

        // Find the match for this user
        MeetupMatch match = meetupMatchRepository.findByMeetupIdAndUserId(meetupId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        // Check if already confirmed
        if (confirmationRepository.existsByMeetupMatchIdAndUserId(match.getId(), userId)) {
            throw new BadRequestException("Already confirmed");
        }

        // Create confirmation record
        MeetupConfirmation confirmation = new MeetupConfirmation();
        confirmation.setMeetupMatch(match);
        confirmation.setUser(user);
        confirmation.setResult(result);
        confirmation.setComment(request.feedback());
        confirmation.setRating(request.rating());
        confirmationRepository.save(confirmation);

        // Update embedded flags for backwards compatibility
        if (isOrganizer) {
            meetup.setOrganizerConfirmed(result == MeetupConfirmation.ConfirmationResult.SUCCESS);
        } else {
            meetup.setParticipantConfirmed(result == MeetupConfirmation.ConfirmationResult.SUCCESS);
        }

        // Check if both parties have confirmed
        List<MeetupConfirmation> allConfirmations = confirmationRepository.findByMeetupMatchId(match.getId());

        if (allConfirmations.size() >= 2) {
            // Both confirmed - check results
            boolean allSuccess = allConfirmations.stream()
                    .allMatch(c -> c.getResult() == MeetupConfirmation.ConfirmationResult.SUCCESS);

            if (allSuccess) {
                meetup.setStatus(MeetupStatus.COMPLETED);
                meetup.setConfirmationStatus(ConfirmationStatus.CONFIRMED);

                // Positive reputation for both
                updateReputation(meetup.getOrganizer(), 1);
                for (User participant : meetup.getAcceptedParticipants()) {
                    updateReputation(participant, 1);
                }
            } else {
                // Someone reported NO_SHOW
                meetup.setConfirmationStatus(ConfirmationStatus.NO_SHOW);

                // Penalize who was reported as no-show
                for (MeetupConfirmation conf : allConfirmations) {
                    if (conf.getResult() == MeetupConfirmation.ConfirmationResult.NO_SHOW) {
                        // The reporter says other party didn't show
                        // Find who didn't show (not the reporter)
                        boolean reporterIsOrganizer = conf.getUser().getId().equals(meetup.getOrganizer().getId());
                        if (reporterIsOrganizer) {
                            // Organizer reported participant no-show
                            for (User participant : meetup.getAcceptedParticipants()) {
                                updateReputation(participant, -3);
                            }
                        } else {
                            // Participant reported organizer no-show
                            updateReputation(meetup.getOrganizer(), -3);
                        }
                    }
                }
            }
        }

        meetupRepository.save(meetup);
    }

    /**
     * Cancel meetup
     */
    @Transactional
    public void cancelMeetup(UUID meetupId, UUID userId) {
        Meetup meetup = getMeetup(meetupId);
        User user = getUser(userId);

        boolean isOrganizer = meetup.getOrganizer().getId().equals(userId);
        boolean isParticipant = meetup.getAcceptedParticipants().stream()
                .anyMatch(p -> p.getId().equals(userId));

        if (!isOrganizer && !isParticipant) {
            throw new ForbiddenException("Only participants can cancel");
        }

        long hoursUntilMeet = Duration.between(ZonedDateTime.now(), meetup.getScheduledAt()).toHours();

        if (isOrganizer) {
            // Organizer cancels entire meetup
            meetup.setStatus(MeetupStatus.CANCELLED);

            // Reputation penalty if cancelled within 24h
            if (hoursUntilMeet < 24) {
                updateReputation(user, -1);
            }
        } else {
            // Participant cancels their participation
            meetup.getAcceptedParticipants().remove(user);

            // Update match status
            meetupMatchRepository.findByMeetupIdAndUserId(meetupId, userId)
                    .ifPresent(match -> {
                        match.setStatus(MatchStatus.CANCELLED);
                        meetupMatchRepository.save(match);
                    });

            // Reputation penalty if cancelled within 24h
            if (hoursUntilMeet < 24) {
                updateReputation(user, -1);
            }

            // Reopen meetup if it was full
            if (meetup.getStatus() == MeetupStatus.MATCHED && !meetup.isFull()) {
                meetup.setStatus(MeetupStatus.OPEN);
            }
        }

        meetupRepository.save(meetup);
    }

    // Helper methods
    private Meetup getMeetup(UUID id) {
        return meetupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Meetup not found"));
    }

    private User getUser(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private MeetupMatch getMatch(UUID id) {
        return meetupMatchRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));
    }

    private void updateReputation(User user, int delta) {
        if (user.getProfile() == null) {
            return; // Skip if profile not initialized
        }
        Double currentRep = user.getProfile().getReputationScore();
        if (currentRep == null)
            currentRep = 100.0;
        user.getProfile().setReputationScore(currentRep + delta);
        userRepository.save(user);
    }

    private MeetupResponse toResponse(Meetup meetup, UUID userId) {
        // Check if user has applied
        var userMatch = meetupMatchRepository.findByMeetupIdAndUserId(meetup.getId(), userId);
        boolean userHasApplied = userMatch.isPresent();
        MatchStatus userMatchStatus = userMatch.map(MeetupMatch::getStatus).orElse(null);

        int pendingCount = meetupMatchRepository.countByMeetupIdAndStatus(
                meetup.getId(), MatchStatus.PENDING);

        ZonedDateTime now = ZonedDateTime.now();
        boolean isPast = meetup.getScheduledAt().isBefore(now);
        boolean isExpired = meetup.getExpiresAt() != null && meetup.getExpiresAt().isBefore(now);

        return new MeetupResponse(
                meetup.getId(),
                UserSummary.fromUser(meetup.getOrganizer()),
                meetup.getTitle(),
                meetup.getDescription(),
                meetup.getMeetType(),
                meetup.getCategory(),
                meetup.getLocation(),
                meetup.getLatitude(),
                meetup.getLongitude(),
                meetup.getScheduledAt(),
                meetup.getExpiresAt(),
                meetup.getDurationMinutes(),
                meetup.getMaxParticipants(),
                meetup.getAcceptedParticipants().size(),
                pendingCount,
                meetup.getStatus(),
                meetup.getConfirmationStatus(),
                null, // distance - calculated in controller if needed
                userHasApplied,
                userMatchStatus,
                isPast,
                isExpired,
                meetup.getCreatedAt());
    }

    private MeetupMatchResponse toMatchResponse(MeetupMatch match) {
        return new MeetupMatchResponse(
                match.getId(),
                match.getMeetup().getId(),
                UserSummary.fromUser(match.getUser()),
                match.getMessage(),
                match.getStatus(),
                match.getConversationId(),
                match.getCreatedAt(),
                match.getRespondedAt());
    }
}
