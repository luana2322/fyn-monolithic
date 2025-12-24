package com.fyn_monolithic.model.message;

public enum ConversationType {
    DIRECT, // 1-on-1 chat between two users
    GROUP, // Legacy - kept for backward compatibility
    GROUP_MEETUP, // Group chat for meetup (auto-created when meetup has accepted members)
    FRIENDS_GROUP // User-created friend group chat
}
