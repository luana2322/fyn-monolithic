-- Add reputation_score to user_profiles table
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS reputation_score DOUBLE PRECISION DEFAULT 100.0;

-- Update any existing profiles with default reputation
UPDATE user_profiles SET reputation_score = 100.0 WHERE reputation_score IS NULL;
