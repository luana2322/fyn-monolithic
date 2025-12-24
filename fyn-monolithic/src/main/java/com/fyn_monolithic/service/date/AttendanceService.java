package com.fyn_monolithic.service.date;

import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.date.*;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.date.MeetupAttendanceRepository;
import com.fyn_monolithic.repository.date.MeetupRepository;
import com.fyn_monolithic.repository.user.UserRepository;
import com.fyn_monolithic.service.message.GroupChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Service for handling meetup attendance confirmation
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceService {

    private final MeetupAttendanceRepository attendanceRepository;
    private final MeetupRepository meetupRepository;
    private final UserRepository userRepository;
    private final GroupChatService groupChatService;

    // Threshold for auto-completing meetup (percentage of confirmed attendees)
    private static final double COMPLETION_THRESHOLD = 0.7; // 70%

    // Buffer time before allowing confirmation (hours after scheduled time)
    private static final int CONFIRMATION_BUFFER_HOURS = 1;

    /**
     * Confirm attendance for a meetup
     */
    @Transactional
    public MeetupAttendance confirmAttendance(UUID meetupId, UUID userId, AttendanceStatus status,
            String feedback, Double rating) {
        Meetup meetup = getMeetup(meetupId);
        User user = getUser(userId);

        // Validate user is a participant
        if (!isParticipant(meetup, user)) {
            throw new BadRequestException("You are not a participant of this meetup");
        }

        // Validate meetup has ended
        if (!canConfirmAttendance(meetup)) {
            throw new BadRequestException("Cannot confirm attendance yet. Meetup must have ended.");
        }

        // Check if already confirmed
        if (attendanceRepository.existsByMeetupIdAndUserId(meetupId, userId)) {
            throw new BadRequestException("You have already confirmed your attendance");
        }

        // Create attendance record
        MeetupAttendance attendance = new MeetupAttendance();
        attendance.setMeetupId(meetupId);
        attendance.setUserId(userId);
        attendance.setStatus(status);
        attendance.setFeedback(feedback);
        attendance.setRating(rating);
        attendance.setConfirmedAt(ZonedDateTime.now());

        attendance = attendanceRepository.save(attendance);

        // Update reputation based on status
        updateReputation(user, status);

        // Check if meetup should be marked as completed
        checkAndCompleteMeetup(meetup);

        log.info("User {} confirmed attendance for meetup {} with status {}", userId, meetupId, status);
        return attendance;
    }

    /**
     * Check if meetup can be confirmed for attendance
     * Confirmation is allowed after meetup end time + buffer
     */
    public boolean canConfirmAttendance(Meetup meetup) {
        ZonedDateTime meetupEndTime = meetup.getScheduledAt()
                .plusMinutes(meetup.getDurationMinutes() != null ? meetup.getDurationMinutes() : 120);
        ZonedDateTime confirmationOpenTime = meetupEndTime.plusHours(CONFIRMATION_BUFFER_HOURS);

        return ZonedDateTime.now().isAfter(confirmationOpenTime);
    }

    /**
     * Check if meetup should be marked as completed based on confirmation threshold
     */
    @Transactional
    public void checkAndCompleteMeetup(Meetup meetup) {
        if (meetup.getStatus() == MeetupStatus.COMPLETED) {
            return; // Already completed
        }

        int totalParticipants = meetup.getAcceptedParticipants().size() + 1; // +1 for organizer
        long confirmedCount = attendanceRepository.countByMeetupIdAndStatus(meetup.getId(), AttendanceStatus.CONFIRMED);

        double confirmationRate = (double) confirmedCount / totalParticipants;

        if (confirmationRate >= COMPLETION_THRESHOLD) {
            meetup.setStatus(MeetupStatus.COMPLETED);
            meetup.setConfirmationStatus(ConfirmationStatus.CONFIRMED);
            meetupRepository.save(meetup);

            // Archive the group chat
            groupChatService.archiveGroupChat(meetup.getId());

            // TODO: Generate friend suggestions for participants
            processFriendSuggestions(meetup);

            log.info("Meetup {} marked as COMPLETED with {}% confirmation rate",
                    meetup.getId(), (int) (confirmationRate * 100));
        }
    }

    /**
     * Process friend suggestions after meetup completion
     */
    private void processFriendSuggestions(Meetup meetup) {
        // Get all confirmed attendees
        List<MeetupAttendance> confirmedAttendances = attendanceRepository
                .findByMeetupIdAndStatus(meetup.getId(), AttendanceStatus.CONFIRMED);

        // TODO: Create friend suggestions between confirmed attendees
        // This could be implemented with a FriendSuggestionService
        log.info("Processing friend suggestions for {} confirmed attendees in meetup {}",
                confirmedAttendances.size(), meetup.getId());
    }

    /**
     * Update user reputation based on attendance status
     */
    private void updateReputation(User user, AttendanceStatus status) {
        // Reputation points:
        // CONFIRMED: +5 points
        // NO_SHOW: -10 points and increment noShowCount
        if (user.getProfile() == null) {
            return;
        }

        Double reputationScore = user.getProfile().getReputationScore();
        if (reputationScore == null) {
            reputationScore = 100.0;
        }

        double oldScore = reputationScore;

        switch (status) {
            case CONFIRMED:
                user.getProfile().setReputationScore(reputationScore + 5);
                break;
            case NO_SHOW:
                user.getProfile().setReputationScore(Math.max(0, reputationScore - 10));
                user.setNoShowCount((user.getNoShowCount() != null ? user.getNoShowCount() : 0) + 1);
                break;
            default:
                break;
        }

        userRepository.save(user);
        log.info("Updated reputation for user {}: {} -> {}", user.getId(), oldScore,
                user.getProfile().getReputationScore());
    }

    /**
     * Check if user is a participant of the meetup
     */
    private boolean isParticipant(Meetup meetup, User user) {
        // Check if user is the organizer
        if (meetup.getOrganizer().getId().equals(user.getId())) {
            return true;
        }

        // Check if user is in accepted participants
        return meetup.getAcceptedParticipants().stream()
                .anyMatch(p -> p.getId().equals(user.getId()));
    }

    /**
     * Get attendance status for a user in a meetup
     */
    public MeetupAttendance getAttendance(UUID meetupId, UUID userId) {
        return attendanceRepository.findByMeetupIdAndUserId(meetupId, userId)
                .orElse(null);
    }

    /**
     * Get all attendance records for a meetup
     */
    public List<MeetupAttendance> getMeetupAttendances(UUID meetupId) {
        return attendanceRepository.findByMeetupId(meetupId);
    }

    private Meetup getMeetup(UUID id) {
        return meetupRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Meetup not found: " + id));
    }

    private User getUser(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + id));
    }
}
