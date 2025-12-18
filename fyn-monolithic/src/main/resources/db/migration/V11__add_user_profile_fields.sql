-- Add user profile fields for enhanced search and filtering
-- Adds gender, date of birth, and education level

-- Add gender column
ALTER TABLE user_profiles
ADD COLUMN gender VARCHAR(20);

-- Add date of birth column
ALTER TABLE user_profiles
ADD COLUMN date_of_birth DATE;

-- Add education level column
ALTER TABLE user_profiles
ADD COLUMN education_level VARCHAR(50);

-- Create index for search performance
CREATE INDEX idx_user_profiles_gender ON user_profiles(gender);
CREATE INDEX idx_user_profiles_date_of_birth ON user_profiles(date_of_birth);

-- Add comments for documentation
COMMENT ON COLUMN user_profiles.gender IS 'User gender: MALE, FEMALE, OTHER, PREFER_NOT_TO_SAY';
COMMENT ON COLUMN user_profiles.date_of_birth IS 'User date of birth for age calculation';
COMMENT ON COLUMN user_profiles.education_level IS 'Education level: HIGH_SCHOOL, COLLEGE, UNIVERSITY, GRADUATE, OTHER';
