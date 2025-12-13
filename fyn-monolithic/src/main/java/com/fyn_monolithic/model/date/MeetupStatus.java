package com.fyn_monolithic.model.date;

/**
 * Status for group meetups
 */
public enum MeetupStatus {
    OPEN, // Open for participants
    FULL, // Max participants reached
    ONGOING, // Currently happening
    COMPLETED, // Finished
    CANCELLED // Organizer cancelled
}
