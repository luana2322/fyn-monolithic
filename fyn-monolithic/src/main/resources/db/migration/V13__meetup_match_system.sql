-- V13: Meetup Match System
-- Add meet type, expiration, confirmation fields, and match table

-- Add new columns to meetups table
ALTER TABLE meetups ADD COLUMN IF NOT EXISTS meet_type VARCHAR(20) NOT NULL DEFAULT 'GROUP';
ALTER TABLE meetups ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE meetups ADD COLUMN IF NOT EXISTS confirmation_status VARCHAR(20) DEFAULT 'NONE';
ALTER TABLE meetups ADD COLUMN IF NOT EXISTS organizer_confirmed BOOLEAN DEFAULT FALSE;
ALTER TABLE meetups ADD COLUMN IF NOT EXISTS participant_confirmed BOOLEAN DEFAULT FALSE;
ALTER TABLE meetups ADD COLUMN IF NOT EXISTS confirmation_sent_at TIMESTAMP WITH TIME ZONE;

-- Expand status column to accommodate new statuses
ALTER TABLE meetups ALTER COLUMN status TYPE VARCHAR(30);

-- Create meetup_matches table for match/application system
CREATE TABLE IF NOT EXISTS meetup_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meetup_id UUID NOT NULL REFERENCES meetups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    conversation_id UUID REFERENCES conversations(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(meetup_id, user_id)
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_meetup_match_meetup ON meetup_matches(meetup_id, status);
CREATE INDEX IF NOT EXISTS idx_meetup_match_user ON meetup_matches(user_id, status);
CREATE INDEX IF NOT EXISTS idx_meetup_lat_lng ON meetups(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_meetup_status_scheduled ON meetups(status, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_meetup_expires_at ON meetups(expires_at) WHERE expires_at IS NOT NULL;

-- Add reputation fields to users table if they don't exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_meets_completed INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_meets_cancelled INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_no_shows INTEGER DEFAULT 0;

-- Update existing meetups to have proper status
UPDATE meetups SET status = 'OPEN' WHERE status NOT IN ('OPEN', 'MATCHED', 'WAITING_CONFIRMATION', 'COMPLETED', 'CANCELLED', 'EXPIRED');
