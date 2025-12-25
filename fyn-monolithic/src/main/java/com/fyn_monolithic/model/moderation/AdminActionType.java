package com.fyn_monolithic.model.moderation;

/**
 * Types of actions an admin can perform
 */
public enum AdminActionType {
    HIDE_POST,
    DELETE_POST,
    RESTORE_POST,
    MARK_REPORT_VALID,
    MARK_REPORT_INVALID
}
