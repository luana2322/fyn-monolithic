-- Migration script for Group Chat and Attendance Confirmation features
-- Run this script against the PostgreSQL database

-- ============================================
-- 1. Update conversations table
-- ============================================

-- Add meetup_id column for GROUP_MEETUP conversations
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS meetup_id UUID REFERENCES meetups(id);

-- Add is_archived column for archiving group chats after meetup ends
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT FALSE;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_conversations_meetup_id ON conversations(meetup_id);

-- ============================================
-- 2. Update conversation_members table
-- ============================================

-- Add role column for member roles (ORGANIZER, ADMIN, MEMBER)
ALTER TABLE conversation_members ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'MEMBER';

-- Add joined_at timestamp
ALTER TABLE conversation_members ADD COLUMN IF NOT EXISTS joined_at TIMESTAMPTZ DEFAULT NOW();

-- Add left_at timestamp (null means still in group)
ALTER TABLE conversation_members ADD COLUMN IF NOT EXISTS left_at TIMESTAMPTZ;

-- ============================================
-- 3. Create meetup_attendance table
-- ============================================

CREATE TABLE IF NOT EXISTS meetup_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meetup_id UUID NOT NULL REFERENCES meetups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    confirmed_at TIMESTAMPTZ,
    feedback TEXT,
    rating DECIMAL(2,1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT uq_meetup_attendance UNIQUE (meetup_id, user_id)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_meetup_attendance_meetup_id ON meetup_attendance(meetup_id);
CREATE INDEX IF NOT EXISTS idx_meetup_attendance_user_id ON meetup_attendance(user_id);
CREATE INDEX IF NOT EXISTS idx_meetup_attendance_status ON meetup_attendance(status);

-- ============================================
-- 4. Update existing data (optional)
-- ============================================

-- Set default joined_at for existing conversation members
UPDATE conversation_members 
SET joined_at = created_at 
WHERE joined_at IS NULL;

-- Set default role for existing conversation members
UPDATE conversation_members 
SET role = 'MEMBER' 
WHERE role IS NULL;

-- ============================================
-- 5. Update conversations type constraint
-- ============================================

-- Drop the existing type constraint (if exists)
ALTER TABLE conversations DROP CONSTRAINT IF EXISTS conversations_type_check;

-- Add new constraint with all valid types
ALTER TABLE conversations ADD CONSTRAINT conversations_type_check 
    CHECK (type IN ('DIRECT', 'GROUP', 'GROUP_MEETUP', 'FRIENDS_GROUP'));
