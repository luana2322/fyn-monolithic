package com.fyn_monolithic.model.notification;

public enum NotificationType {
    FOLLOW,
    LIKE,
    COMMENT,
    MESSAGE,
    SYSTEM,
    MEETUP_CONFIRMATION, // Request to confirm meetup outcome
    MEETUP_REMINDER, // Upcoming meetup reminder
    MEETUP_MATCH // When someone applies/accepts meetup
}
