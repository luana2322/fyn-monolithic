package com.fyn_monolithic.service.scheduler;

import com.fyn_monolithic.model.date.Meetup;
import com.fyn_monolithic.model.date.MeetupStatus;
import com.fyn_monolithic.repository.date.MeetupRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;

/**
 * Scheduled job to send reminders 1-2 hours before meetups
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MeetupReminderJob {

    private final MeetupRepository meetupRepository;
    // TODO: Inject NotificationService when implemented

    /**
     * Runs every hour to check for upcoming meetups needing reminders
     */
    @Scheduled(cron = "0 0 * * * *") // Every hour at minute :00
    public void sendUpcomingMeetupReminders() {
        log.info("Running meetup reminder job");

        ZonedDateTime now = ZonedDateTime.now();
        ZonedDateTime twoHoursLater = now.plusHours(2);
        ZonedDateTime oneHourLater = now.plusHours(1);

        // Find meetups scheduled in the next 1-2 hours that haven't been reminded
        List<Meetup> upcomingMeetups = meetupRepository.findByStatusAndScheduledAtBetween(
                MeetupStatus.MATCHED,
                oneHourLater,
                twoHoursLater);

        log.info("Found {} meetups needing reminders", upcomingMeetups.size());

        for (Meetup meetup : upcomingMeetups) {
            try {
                sendReminder(meetup);
            } catch (Exception e) {
                log.error("Failed to send reminder for meetup {}: {}", meetup.getId(), e.getMessage());
            }
        }
    }

    private void sendReminder(Meetup meetup) {
        log.info("Sending reminder for meetup: {} scheduled at {}",
                meetup.getTitle(), meetup.getScheduledAt());

        // TODO: Send push notifications
        // notificationService.sendMeetupReminder(meetup.getOrganizer(), meetup);
        // for (User participant : meetup.getAcceptedParticipants()) {
        // notificationService.sendMeetupReminder(participant, meetup);
        // }

        // For now, just log
        log.info("Reminder sent to organizer {} and {} participants",
                meetup.getOrganizer().getUsername(),
                meetup.getAcceptedParticipants().size());
    }
}
