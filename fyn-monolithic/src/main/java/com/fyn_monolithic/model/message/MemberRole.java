package com.fyn_monolithic.model.message;

/**
 * Role of a member in a conversation group
 */
public enum MemberRole {
    ORGANIZER, // Meetup creator (for GROUP_MEETUP)
    ADMIN, // Group admin (for FRIENDS_GROUP)
    MEMBER // Regular member
}
