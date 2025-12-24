package com.fyn_monolithic.service.scheduler;

import com.fyn_monolithic.model.date.Meetup;
import com.fyn_monolithic.model.date.MeetupStatus;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.date.MeetupRepository;
import com.fyn_monolithic.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;

/**
 * Scheduled job to request confirmations 12-24h after meetups
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MeetupConfirmationJob {

    private final MeetupRepository meetupRepository;
    private final NotificationService notificationService;

    /**
     * Runs every hour to check for meetups needing confirmation
     */
    @Scheduled(cron = "0 15 * * * *") // Every hour at minute :15
    public void requestMeetupConfirmations() {
        log.info("Running meetup confirmation job");

        ZonedDateTime now = ZonedDateTime.now();
        ZonedDateTime twentyFourHoursAgo = now.minusHours(24);
        ZonedDateTime twelveHoursAgo = now.minusHours(12);

        // Find completed meetups that haven't been confirmed yet
        // scheduled 12-24h ago, status = MATCHED (not COMPLETED yet)
        List<Meetup> meetupsNeedingConfirmation = meetupRepository
                .findByStatusAndScheduledAtBetween(
                        MeetupStatus.MATCHED,
                        twentyFourHoursAgo,
                        twelveHoursAgo);

        log.info("Found {} meetups needing confirmation", meetupsNeedingConfirmation.size());

        for (Meetup meetup : meetupsNeedingConfirmation) {
            try {
                requestConfirmation(meetup);
            } catch (Exception e) {
                log.error("Failed to request confirmation for meetup {}: {}",
                        meetup.getId(), e.getMessage());
            }
        }
    }

    private void requestConfirmation(Meetup meetup) {
        // Only send if not already sent
        if (meetup.getConfirmationSentAt() != null) {
            return;
        }

        log.info("Requesting confirmation for meetup: {} that occurred at {}",
                meetup.getTitle(), meetup.getScheduledAt());

        // Send notification to organizer
        notificationService.notifyMeetupConfirmation(meetup.getOrganizer(), meetup);

        // Send notification to all accepted participants
        for (User participant : meetup.getAcceptedParticipants()) {
            notificationService.notifyMeetupConfirmation(participant, meetup);
        }

        // Update meetup status to WAITING_CONFIRMATION
        meetup.setStatus(MeetupStatus.WAITING_CONFIRMATION);
        meetup.setConfirmationSentAt(ZonedDateTime.now());
        meetupRepository.save(meetup);

        log.info("Confirmation request sent to organizer {} and {} participants",
                meetup.getOrganizer().getUsername(),
                meetup.getAcceptedParticipants().size());
    }

    /**
     * Auto-mark as NO_SHOW if no confirmation after deadline
     * Runs once per day
     */
    @Scheduled(cron = "0 0 2 * * *") // Daily at 2 AM
    public void autoMarkNoShow() {
        log.info("Running auto NO_SHOW job");

        ZonedDateTime now = ZonedDateTime.now();
        ZonedDateTime fortyEightHoursAgo = now.minusHours(48);

        // Find meetups scheduled 48+ hours ago still in WAITING_CONFIRMATION state
        List<Meetup> overdueConfirmation = meetupRepository
                .findByStatusAndScheduledAtBefore(MeetupStatus.WAITING_CONFIRMATION, fortyEightHoursAgo);

        log.info("Found {} meetups to auto-mark as NO_SHOW", overdueConfirmation.size());

        for (Meetup meetup : overdueConfirmation) {
            log.info("Auto-marking meetup {} as CANCELLED due to no confirmation", meetup.getId());

            // Mark status as cancelled due to no confirmation
            meetup.setStatus(MeetupStatus.CANCELLED);
            // TODO: Apply reputation penalty

            meetupRepository.save(meetup);
        }
    }
}
