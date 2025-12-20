-- V12: Add embedded date information to connections table for simplified dating flow
-- This replaces the complex date_plans marketplace with mandatory dates per match

-- Add date fields directly to connections table
ALTER TABLE connections 
ADD COLUMN IF NOT EXISTS date_scheduled_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS date_description TEXT,
ADD COLUMN IF NOT EXISTS date_location_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS date_location_address TEXT,
ADD COLUMN IF NOT EXISTS date_latitude DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS date_longitude DECIMAL(11, 8),
ADD COLUMN IF NOT EXISTS date_created_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS date_status VARCHAR(20) DEFAULT 'PENDING',
ADD COLUMN IF NOT EXISTS feedback_status VARCHAR(20) DEFAULT 'PENDING';

-- Add no_show_count to users for reputation tracking
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS no_show_count INTEGER DEFAULT 0;

-- Create index for scheduled date notifications (12-24h after date)
CREATE INDEX IF NOT EXISTS idx_conn_date_scheduled 
ON connections(date_scheduled_at, feedback_status) 
WHERE date_scheduled_at IS NOT NULL;

-- Create index for date status queries
CREATE INDEX IF NOT EXISTS idx_conn_date_status 
ON connections(date_status) 
WHERE date_status IS NOT NULL;

-- Create date_feedback table for post-date accountability
CREATE TABLE IF NOT EXISTS date_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    connection_id UUID NOT NULL REFERENCES connections(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    did_meet BOOLEAN NOT NULL,
    no_show_reason VARCHAR(50), -- 'partner_no_show', 'cancelled', 'other'
    rating VARCHAR(20), -- 'good', 'neutral', 'bad' 
    feedback_text TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- One feedback per user per connection
    UNIQUE(connection_id, user_id),
    
    -- Feedback validation: if met, must have rating; if didn't meet, must have reason
    CONSTRAINT check_feedback_validity CHECK (
        (did_meet = true AND rating IS NOT NULL) OR
        (did_meet = false AND no_show_reason IS NOT NULL)
    )
);

-- Create indexes for feedback queries
CREATE INDEX IF NOT EXISTS idx_feedback_connection ON date_feedback(connection_id);
CREATE INDEX IF NOT EXISTS idx_feedback_user ON date_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_submitted ON date_feedback(submitted_at);

-- Add comment explaining the simplified flow
COMMENT ON TABLE date_feedback IS 'Post-date feedback for accountability. Sent 12-24h after date_scheduled_at.';
COMMENT ON COLUMN connections.date_scheduled_at IS 'Mandatory date time for each match (part of simplified flow)';
COMMENT ON COLUMN connections.feedback_status IS 'PENDING, REQUESTED, COMPLETED - tracks post-date feedback collection';
