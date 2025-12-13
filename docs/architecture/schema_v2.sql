-- =============================================================================
-- FYN SOCIAL CONNECTION APP - COMPLETE DATABASE SCHEMA V2
-- PostgreSQL with PostGIS extension
-- =============================================================================
-- Run: CREATE EXTENSION IF NOT EXISTS postgis;
-- Run: CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- =============================================================================

-- ============================================================================
-- SECTION 1: ENUMS & TYPES
-- ============================================================================

-- Connection types with metadata
CREATE TYPE connection_type AS ENUM (
    'friend',              -- Mutual friendship
    'romantic',            -- Dating/romantic interest
    'activity_partner',    -- Hobby/activity buddy
    'study_partner',       -- Learning together
    'tutor',               -- Teaching relationship
    'mentor',              -- Long-term guidance
    'mentee',              -- Being mentored
    'colleague',           -- Professional contact
    'business',            -- Business networking
    'roommate',            -- Housing/housemate
    'acquaintance',        -- Light connection
    'service_provider'     -- Business offering services
);

CREATE TYPE connection_status AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'blocked',
    'expired'              -- Auto-expire after X days if no response
);

CREATE TYPE group_type AS ENUM (
    'sport', 'study', 'hangout', 'gaming', 'travel',
    'hobby', 'professional', 'support', 'community', 'other'
);

CREATE TYPE group_visibility AS ENUM ('public', 'private', 'event_based', 'invite_only');

CREATE TYPE member_role AS ENUM ('owner', 'admin', 'moderator', 'member', 'pending');

CREATE TYPE event_status AS ENUM (
    'draft',         -- Not published yet
    'open',          -- Accepting participants
    'waiting_list',  -- Full but accepting waitlist
    'full',          -- Capacity reached, no waitlist
    'ongoing',       -- Event in progress
    'completed',     -- Successfully finished
    'cancelled',     -- Cancelled by owner
    'expired'        -- Past start time, never started
);

CREATE TYPE event_visibility AS ENUM ('public', 'friends_only', 'group_only', 'invite_only');

CREATE TYPE activity_type AS ENUM (
    'coffee', 'breakfast', 'brunch', 'lunch', 'dinner', 'drinks',
    'sports', 'gym', 'hiking', 'cycling', 'running', 'swimming',
    'movie', 'concert', 'theater', 'museum', 'exhibition',
    'study', 'tutoring', 'workshop', 'seminar', 'conference',
    'gaming', 'board_games', 'esports',
    'travel', 'road_trip', 'camping',
    'networking', 'meetup', 'coworking',
    'volunteer', 'charity',
    'party', 'celebration',
    'other'
);

CREATE TYPE participant_status AS ENUM (
    'pending',      -- Awaiting approval
    'approved',     -- Approved to attend
    'rejected',     -- Request rejected
    'waitlisted',   -- On waiting list
    'cancelled',    -- User cancelled
    'attended',     -- Confirmed attendance
    'no_show'       -- Did not attend
);

CREATE TYPE recurrence_frequency AS ENUM (
    'daily', 'weekly', 'biweekly', 'monthly', 'custom'
);

CREATE TYPE report_reason AS ENUM (
    'inappropriate_content', 'harassment', 'spam', 'fake_profile',
    'scam', 'violence', 'hate_speech', 'impersonation', 'underage', 'other'
);

CREATE TYPE report_status AS ENUM ('pending', 'reviewing', 'resolved', 'dismissed', 'escalated');

CREATE TYPE review_context AS ENUM ('event', 'connection', 'group', 'service');

CREATE TYPE verification_type AS ENUM ('phone', 'email', 'government_id', 'social', 'photo');

-- ============================================================================
-- SECTION 2: USER TABLES
-- ============================================================================

-- Extended user profile for matching (references existing users table)
CREATE TABLE user_profiles_extended (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Demographics
    date_of_birth DATE,
    gender VARCHAR(20),                    -- male, female, non_binary, prefer_not_say
    gender_identity VARCHAR(50),           -- More specific if needed
    pronouns VARCHAR(20),
    
    -- What user is looking for
    looking_for VARCHAR(50)[],             -- ['dating', 'friendship', 'activity_partner', 'networking']
    relationship_status VARCHAR(30),       -- single, taken, open, prefer_not_say
    
    -- Location (with privacy)
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_city VARCHAR(100),
    location_district VARCHAR(100),
    location_country VARCHAR(100) DEFAULT 'Vietnam',
    location_approximate BOOLEAN DEFAULT true,  -- Hide exact location
    max_distance_km INTEGER DEFAULT 50,
    
    -- Matching preferences
    preferred_age_min INTEGER DEFAULT 18,
    preferred_age_max INTEGER DEFAULT 99,
    preferred_genders VARCHAR(20)[],
    
    -- Availability (for matching by time)
    available_days VARCHAR(10)[],          -- ['monday', 'tuesday', ...]
    available_time_slots JSONB,            -- {"morning": true, "afternoon": false, "evening": true, "night": false}
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    
    -- Personality & Interests
    personality_type VARCHAR(10),          -- MBTI: INTJ, ENFP, etc.
    interests TEXT[],                      -- ['photography', 'hiking', 'coffee', 'gaming']
    languages VARCHAR(50)[],               -- ['Vietnamese', 'English', 'Japanese']
    occupation VARCHAR(100),
    company VARCHAR(100),
    education VARCHAR(150),
    education_level VARCHAR(50),           -- high_school, bachelor, master, phd
    
    -- Lifestyle
    smoking VARCHAR(20),                   -- never, sometimes, regularly
    drinking VARCHAR(20),
    diet VARCHAR(30),                      -- vegan, vegetarian, halal, etc.
    exercise_frequency VARCHAR(20),        -- daily, weekly, rarely
    pets VARCHAR(50)[],
    
    -- Reputation & Trust
    reputation_score DECIMAL(3,2) DEFAULT 5.00 CHECK (reputation_score >= 0 AND reputation_score <= 5),
    total_reviews INTEGER DEFAULT 0,
    total_events_attended INTEGER DEFAULT 0,
    total_events_created INTEGER DEFAULT 0,
    response_rate DECIMAL(5,2) DEFAULT 100.00,   -- % of messages responded to
    avg_response_time_minutes INTEGER,
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    verification_level INTEGER DEFAULT 0,  -- 0=none, 1=email, 2=phone, 3=id
    
    -- Profile completeness
    profile_completeness INTEGER DEFAULT 0 CHECK (profile_completeness >= 0 AND profile_completeness <= 100),
    
    -- Activity
    last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_online BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verification records
CREATE TABLE user_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    verification_type verification_type NOT NULL,
    verification_data JSONB,               -- Encrypted/hashed verification info
    verified_at TIMESTAMP,
    expires_at TIMESTAMP,
    is_valid BOOLEAN DEFAULT true,
    verified_by VARCHAR(50),               -- 'system', 'manual', 'provider_name'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, verification_type)
);

-- User photos (separate from main profile)
CREATE TABLE user_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,     -- Photo verification
    caption TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Emergency contacts for safety features
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    relationship VARCHAR(50),              -- friend, family, other
    is_primary BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for user_profiles_extended
CREATE INDEX idx_user_location ON user_profiles_extended 
    USING GIST (ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326));
CREATE INDEX idx_user_interests ON user_profiles_extended USING GIN(interests);
CREATE INDEX idx_user_looking_for ON user_profiles_extended USING GIN(looking_for);
CREATE INDEX idx_user_last_active ON user_profiles_extended(last_active_at DESC);
CREATE INDEX idx_user_age ON user_profiles_extended(date_of_birth);

-- ============================================================================
-- SECTION 3: CONNECTION SYSTEM
-- ============================================================================

-- Connection type metadata (for business logic)
CREATE TABLE connection_type_metadata (
    connection_type connection_type PRIMARY KEY,
    requires_mutual_consent BOOLEAN DEFAULT true,
    supports_group BOOLEAN DEFAULT false,
    is_business_related BOOLEAN DEFAULT false,
    max_pending_days INTEGER DEFAULT 30,
    allows_intro_message BOOLEAN DEFAULT true,
    display_name_en VARCHAR(50),
    display_name_vi VARCHAR(50)
);

-- Seed connection type metadata
INSERT INTO connection_type_metadata VALUES
('friend', true, false, false, 30, true, 'Friend', 'Bạn bè'),
('romantic', true, false, false, 7, true, 'Romantic Interest', 'Hẹn hò'),
('activity_partner', true, true, false, 14, true, 'Activity Partner', 'Bạn hoạt động'),
('study_partner', true, true, false, 14, true, 'Study Partner', 'Bạn học'),
('tutor', false, false, false, 30, true, 'Tutor', 'Gia sư'),
('mentor', true, false, true, 30, true, 'Mentor', 'Người hướng dẫn'),
('mentee', true, false, true, 30, true, 'Mentee', 'Học viên'),
('colleague', true, false, true, 30, true, 'Colleague', 'Đồng nghiệp'),
('business', true, false, true, 30, true, 'Business Contact', 'Đối tác kinh doanh'),
('roommate', true, true, false, 14, true, 'Roommate', 'Bạn cùng phòng'),
('acquaintance', true, false, false, 7, false, 'Acquaintance', 'Quen biết'),
('service_provider', false, false, true, 30, true, 'Service Provider', 'Nhà cung cấp');

-- Connections table
CREATE TABLE connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    connection_type connection_type NOT NULL,
    status connection_status DEFAULT 'pending',
    
    -- Matching metadata
    match_score DECIMAL(5,2),              -- 0-100 compatibility score
    matched_interests TEXT[],
    match_source VARCHAR(50),              -- 'swipe', 'event', 'group', 'ai_suggestion', 'search'
    
    -- Communication
    intro_message TEXT,
    response_message TEXT,
    
    -- Timestamps
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    expires_at TIMESTAMP,                  -- Auto-expire pending requests
    
    -- Mutual follow tracking
    requester_follows_receiver BOOLEAN DEFAULT true,
    receiver_follows_requester BOOLEAN DEFAULT false,
    
    UNIQUE(requester_id, receiver_id, connection_type),
    CHECK (requester_id != receiver_id)
);

-- Indexes for connections
CREATE INDEX idx_connections_requester ON connections(requester_id, status);
CREATE INDEX idx_connections_receiver ON connections(receiver_id, status);
CREATE INDEX idx_connections_type_status ON connections(connection_type, status);
CREATE INDEX idx_connections_expires ON connections(expires_at) WHERE status = 'pending';

-- ============================================================================
-- SECTION 4: GROUP SYSTEM
-- ============================================================================

CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,              -- URL-friendly name
    description TEXT,
    cover_image_url VARCHAR(500),
    icon_url VARCHAR(200),
    
    group_type group_type NOT NULL,
    visibility group_visibility DEFAULT 'public',
    
    -- Location (optional)
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(200),
    
    -- Rules & Settings
    rules TEXT[],
    welcome_message TEXT,
    max_members INTEGER DEFAULT 1000,
    requires_approval BOOLEAN DEFAULT false,
    min_age INTEGER DEFAULT 18,
    allowed_genders VARCHAR(20)[],         -- NULL = all
    
    -- Activity requirements
    min_reputation_score DECIMAL(3,2),
    min_events_attended INTEGER DEFAULT 0,
    
    -- Stats (denormalized for performance)
    member_count INTEGER DEFAULT 0,
    active_member_count INTEGER DEFAULT 0,
    total_events INTEGER DEFAULT 0,
    
    -- Chat
    chat_enabled BOOLEAN DEFAULT true,
    chat_room_id UUID,
    
    -- Metadata
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    
    -- Membership details
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    
    -- Member settings
    notifications_enabled BOOLEAN DEFAULT true,
    is_muted BOOLEAN DEFAULT false,
    nickname VARCHAR(50),                  -- Display name within group
    
    -- Activity
    last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    messages_count INTEGER DEFAULT 0,
    events_attended INTEGER DEFAULT 0,
    
    UNIQUE(group_id, user_id)
);

-- Group join requests (for private groups)
CREATE TABLE group_join_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',  -- pending, approved, rejected
    message TEXT,
    
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    responded_by UUID REFERENCES users(id),
    response_message TEXT,
    
    UNIQUE(group_id, user_id)
);

-- Indexes for groups
CREATE INDEX idx_group_type ON groups(group_type, visibility);
CREATE INDEX idx_group_location ON groups 
    USING GIST (ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326))
    WHERE location_lat IS NOT NULL;
CREATE INDEX idx_group_members_user ON group_members(user_id, role);
CREATE INDEX idx_group_members_group ON group_members(group_id, role);

-- ============================================================================
-- SECTION 5: EVENT SYSTEM WITH RECURRING EVENTS
-- ============================================================================

-- Main events table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200),
    description TEXT,
    cover_image_url VARCHAR(500),
    
    activity_type activity_type NOT NULL,
    visibility event_visibility DEFAULT 'public',
    status event_status DEFAULT 'draft',
    
    -- Location (required for in-person events)
    is_online BOOLEAN DEFAULT false,
    online_meeting_url VARCHAR(500),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(200),
    location_address TEXT,
    location_place_id VARCHAR(100),        -- Google Places ID
    
    -- Timing (for non-recurring or template)
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    duration_minutes INTEGER,
    
    -- Capacity
    min_participants INTEGER DEFAULT 2,
    max_participants INTEGER NOT NULL,
    current_participants INTEGER DEFAULT 0,
    waitlist_count INTEGER DEFAULT 0,
    
    -- Join settings
    requires_approval BOOLEAN DEFAULT true,
    allow_waitlist BOOLEAN DEFAULT true,
    auto_approve_verified BOOLEAN DEFAULT false,
    join_deadline_hours INTEGER,           -- Hours before start to stop accepting
    
    -- Participant requirements
    age_min INTEGER DEFAULT 18,
    age_max INTEGER DEFAULT 99,
    gender_preference VARCHAR(20),         -- NULL = any
    min_reputation_score DECIMAL(3,2),
    required_verifications verification_type[],
    
    -- Recurring event fields
    is_recurring BOOLEAN DEFAULT false,
    recurrence_frequency recurrence_frequency,
    recurrence_rule TEXT,                  -- iCalendar RRULE string
    recurrence_days VARCHAR(10)[],         -- For weekly: ['monday', 'wednesday', 'friday']
    recurrence_end_date DATE,
    recurrence_count INTEGER,              -- End after N occurrences
    parent_event_id UUID REFERENCES events(id) ON DELETE SET NULL,  -- Link to template
    
    -- Relationships
    group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    
    -- Chat
    chat_enabled BOOLEAN DEFAULT true,
    chat_room_id UUID,
    
    -- Cost (if applicable)
    is_paid BOOLEAN DEFAULT false,
    price_amount DECIMAL(10,2),
    price_currency VARCHAR(3) DEFAULT 'VND',
    
    -- Metadata
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event occurrences (for recurring events)
CREATE TABLE event_occurrences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_number INTEGER NOT NULL,    -- 1, 2, 3...
    
    -- Timing (can override parent)
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    
    -- Status (independent per occurrence)
    status event_status DEFAULT 'open',
    
    -- Capacity (independent per occurrence)
    max_participants INTEGER,              -- NULL = use parent
    current_participants INTEGER DEFAULT 0,
    waitlist_count INTEGER DEFAULT 0,
    
    -- Overrides (JSON for any fields that differ from parent)
    override_fields JSONB,                 -- {"location_name": "Different Venue", "max_participants": 10}
    
    -- Chat (separate per occurrence if needed)
    chat_room_id UUID,
    
    -- Cancellation
    is_cancelled BOOLEAN DEFAULT false,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(event_id, occurrence_number)
);

-- Event participants (links to occurrence for recurring events)
CREATE TABLE event_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_id UUID REFERENCES event_occurrences(id) ON DELETE CASCADE,  -- NULL for non-recurring
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status participant_status DEFAULT 'pending',
    
    -- Join request details
    intro_message TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    responded_by UUID REFERENCES users(id),
    response_message TEXT,
    
    -- Alternative proposal (from owner)
    proposed_alternative_time TIMESTAMP,
    alternative_message TEXT,
    
    -- Waitlist
    waitlist_position INTEGER,
    promoted_from_waitlist_at TIMESTAMP,
    
    -- Attendance tracking
    checked_in_at TIMESTAMP,
    checked_out_at TIMESTAMP,
    check_in_location_lat DECIMAL(10, 8),
    check_in_location_lng DECIMAL(11, 8),
    
    -- For recurring: track which occurrences user signed up for
    recurring_signup_type VARCHAR(20),     -- 'all', 'single', 'range'
    
    UNIQUE(event_id, occurrence_id, user_id)
);

-- Event invitations (for invite-only or friends-only)
CREATE TABLE event_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_id UUID REFERENCES event_occurrences(id) ON DELETE CASCADE,
    invited_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invited_by UUID NOT NULL REFERENCES users(id),
    
    status VARCHAR(20) DEFAULT 'pending',  -- pending, accepted, declined
    message TEXT,
    
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    
    UNIQUE(event_id, occurrence_id, invited_user_id)
);

-- Indexes for events
CREATE INDEX idx_event_location ON events 
    USING GIST (ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326))
    WHERE location_lat IS NOT NULL;
CREATE INDEX idx_event_time ON events(start_time, status) WHERE NOT is_recurring;
CREATE INDEX idx_event_activity ON events(activity_type, visibility, status);
CREATE INDEX idx_event_group ON events(group_id) WHERE group_id IS NOT NULL;
CREATE INDEX idx_event_creator ON events(created_by);
CREATE INDEX idx_event_recurring ON events(is_recurring, parent_event_id);

CREATE INDEX idx_occurrence_event ON event_occurrences(event_id, start_time);
CREATE INDEX idx_occurrence_status ON event_occurrences(status, start_time);

CREATE INDEX idx_participants_event ON event_participants(event_id, status);
CREATE INDEX idx_participants_user ON event_participants(user_id, status);
CREATE INDEX idx_participants_occurrence ON event_participants(occurrence_id, status);

-- ============================================================================
-- SECTION 6: REVIEW & REPUTATION SYSTEM
-- ============================================================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Context
    context_type review_context NOT NULL,
    context_id UUID,                       -- event_id, connection_id, or group_id
    
    -- Rating
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    
    -- Detailed ratings (optional)
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    friendliness_rating INTEGER CHECK (friendliness_rating >= 1 AND friendliness_rating <= 5),
    respectfulness_rating INTEGER CHECK (respectfulness_rating >= 1 AND respectfulness_rating <= 5),
    
    -- Feedback
    feedback TEXT,
    tags VARCHAR(50)[],                    -- ['friendly', 'professional', 'fun', 'respectful', 'punctual']
    
    -- Photos (optional)
    photo_urls TEXT[],
    
    -- Visibility
    is_public BOOLEAN DEFAULT true,
    is_anonymous BOOLEAN DEFAULT false,
    
    -- Moderation
    is_flagged BOOLEAN DEFAULT false,
    is_hidden BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(reviewer_id, reviewed_user_id, context_type, context_id)
);

-- Review responses (user can respond to review)
CREATE TABLE review_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL UNIQUE REFERENCES reviews(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pending reviews (track what reviews users need to give)
CREATE TABLE pending_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    context_type review_context NOT NULL,
    context_id UUID NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,                  -- Auto-expire after X days
    reminder_sent_at TIMESTAMP,
    
    UNIQUE(reviewer_id, reviewed_user_id, context_type, context_id)
);

-- Indexes
CREATE INDEX idx_reviews_user ON reviews(reviewed_user_id, rating);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);
CREATE INDEX idx_reviews_context ON reviews(context_type, context_id);
CREATE INDEX idx_pending_reviews ON pending_reviews(reviewer_id, expires_at);

-- ============================================================================
-- SECTION 7: SAFETY & MODERATION
-- ============================================================================

-- User blocks
CREATE TABLE user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(blocker_id, blocked_id)
);

-- User reports
CREATE TABLE user_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reported_user_id UUID NOT NULL REFERENCES users(id),
    
    reason report_reason NOT NULL,
    description TEXT,
    evidence_urls TEXT[],
    
    -- Context (where did the incident happen)
    context_type VARCHAR(50),              -- 'chat', 'event', 'profile', 'group'
    context_id UUID,
    
    -- Moderation
    status report_status DEFAULT 'pending',
    priority INTEGER DEFAULT 0,            -- Higher = more urgent
    assigned_to UUID,                      -- Moderator
    
    reviewed_at TIMESTAMP,
    reviewed_by UUID REFERENCES users(id),
    resolution_notes TEXT,
    action_taken VARCHAR(100),             -- 'warning', 'temp_ban', 'permanent_ban', 'dismissed'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Content reports (for events, groups, messages)
CREATE TABLE content_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    content_type VARCHAR(50) NOT NULL,     -- 'event', 'group', 'message', 'photo'
    content_id UUID NOT NULL,
    
    reason report_reason NOT NULL,
    description TEXT,
    
    status report_status DEFAULT 'pending',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Safety check-ins
CREATE TABLE safety_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_accuracy DECIMAL(10, 2),      -- meters
    
    checkin_type VARCHAR(20),              -- 'arriving', 'ongoing', 'leaving', 'sos'
    is_sos BOOLEAN DEFAULT false,
    sos_message TEXT,
    
    -- Emergency response
    emergency_contacts_notified BOOLEAN DEFAULT false,
    notified_at TIMESTAMP,
    responded_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Moderation actions log
CREATE TABLE moderation_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,      -- 'warning', 'mute', 'temp_ban', 'permanent_ban', 'unmute', 'unban'
    action_reason TEXT,
    
    duration_hours INTEGER,                -- For temp bans
    expires_at TIMESTAMP,
    
    performed_by UUID REFERENCES users(id),
    related_report_id UUID REFERENCES user_reports(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON user_blocks(blocked_id);
CREATE INDEX idx_reports_status ON user_reports(status, priority DESC);
CREATE INDEX idx_reports_user ON user_reports(reported_user_id);
CREATE INDEX idx_safety_user ON safety_checkins(user_id, created_at DESC);
CREATE INDEX idx_safety_sos ON safety_checkins(is_sos, created_at) WHERE is_sos = true;

-- ============================================================================
-- SECTION 8: MATCHING & AI DATA
-- ============================================================================

-- Precomputed match scores for faster discovery
CREATE TABLE match_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_b_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Overall score
    overall_score DECIMAL(5,2) NOT NULL,   -- 0-100
    
    -- Component scores
    location_score DECIMAL(5,2),
    interest_score DECIMAL(5,2),
    availability_score DECIMAL(5,2),
    personality_score DECIMAL(5,2),
    activity_pref_score DECIMAL(5,2),
    age_score DECIMAL(5,2),
    social_score DECIMAL(5,2),             -- Mutual friends, etc.
    reputation_score DECIMAL(5,2),
    activity_score DECIMAL(5,2),           -- Response rate, recent activity
    
    -- Match reasons for UI
    match_reasons TEXT[],
    common_interests TEXT[],
    mutual_friends_count INTEGER DEFAULT 0,
    
    -- Validity
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_valid BOOLEAN DEFAULT true,
    
    UNIQUE(user_a_id, user_b_id)
);

-- User embeddings for AI-based matching
CREATE TABLE user_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Bio/profile embedding
    profile_embedding VECTOR(1536),        -- OpenAI embedding dimension
    interests_embedding VECTOR(1536),
    
    -- Last updated
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    model_version VARCHAR(50)
);

-- Swipe actions (for matching flow)
CREATE TABLE swipe_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    action VARCHAR(10) NOT NULL,           -- 'like', 'pass', 'super_like'
    context VARCHAR(50),                   -- 'dating', 'friendship', 'activity'
    
    -- Undo support
    is_undone BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, target_user_id, context)
);

-- User activity for recommendations
CREATE TABLE user_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    action_type VARCHAR(50) NOT NULL,      -- 'view_profile', 'like', 'message', 'join_event', 'create_event'
    target_type VARCHAR(50),               -- 'user', 'event', 'group'
    target_id UUID,
    
    metadata JSONB,
    session_id VARCHAR(100),
    device_type VARCHAR(20),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AI-generated suggestions cache
CREATE TABLE ai_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    suggestion_type VARCHAR(50),           -- 'icebreaker', 'event', 'person', 'group'
    target_id UUID,                        -- Can be user_id, event_id, group_id
    
    content TEXT,                          -- AI-generated content
    confidence_score DECIMAL(5,2),
    
    -- Interaction tracking
    is_shown BOOLEAN DEFAULT false,
    is_used BOOLEAN DEFAULT false,
    user_feedback VARCHAR(20),             -- 'positive', 'negative', 'neutral'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_match_scores_user ON match_scores(user_a_id, overall_score DESC) WHERE is_valid = true;
CREATE INDEX idx_match_scores_expires ON match_scores(expires_at) WHERE is_valid = true;
CREATE INDEX idx_swipe_user ON swipe_actions(user_id, created_at DESC);
CREATE INDEX idx_swipe_match ON swipe_actions(target_user_id, user_id, action);
CREATE INDEX idx_activity_user ON user_activity_logs(user_id, action_type, created_at DESC);
CREATE INDEX idx_suggestions_user ON ai_suggestions(user_id, suggestion_type, created_at DESC);

-- Enable pgvector for embeddings (if using)
-- CREATE EXTENSION IF NOT EXISTS vector;
-- CREATE INDEX idx_user_embeddings ON user_embeddings USING ivfflat (profile_embedding vector_cosine_ops);

-- ============================================================================
-- SECTION 9: CHAT SYSTEM (EXTENDED)
-- ============================================================================

-- Chat rooms (supports private, group, event, and group chats)
CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    room_type VARCHAR(20) NOT NULL,        -- 'direct', 'group', 'event', 'community'
    name VARCHAR(100),                     -- For group/event chats
    description TEXT,
    avatar_url VARCHAR(500),
    
    -- Links
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
    
    -- Settings
    is_active BOOLEAN DEFAULT true,
    is_muted_all BOOLEAN DEFAULT false,
    slow_mode_seconds INTEGER,             -- Throttle messages
    
    -- Stats
    message_count INTEGER DEFAULT 0,
    member_count INTEGER DEFAULT 0,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat room members
CREATE TABLE chat_room_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    role VARCHAR(20) DEFAULT 'member',     -- 'admin', 'moderator', 'member'
    
    -- Settings
    is_muted BOOLEAN DEFAULT false,
    muted_until TIMESTAMP,
    notifications_enabled BOOLEAN DEFAULT true,
    
    -- Read tracking
    last_read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_message_id UUID,
    unread_count INTEGER DEFAULT 0,
    
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(room_id, user_id)
);

-- Chat messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text',  -- 'text', 'image', 'video', 'audio', 'file', 'location', 'system'
    
    -- Media
    media_urls TEXT[],
    media_thumbnails TEXT[],
    
    -- Location sharing
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(200),
    
    -- Reply/thread
    reply_to_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    thread_id UUID,                        -- For threaded conversations
    
    -- Reactions
    reactions JSONB,                       -- {"❤️": ["user_id1", "user_id2"], "👍": ["user_id3"]}
    
    -- Status
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    
    -- Metadata
    metadata JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for chat
CREATE INDEX idx_chat_room_event ON chat_rooms(event_id) WHERE event_id IS NOT NULL;
CREATE INDEX idx_chat_room_group ON chat_rooms(group_id) WHERE group_id IS NOT NULL;
CREATE INDEX idx_chat_members_user ON chat_room_members(user_id);
CREATE INDEX idx_chat_members_room ON chat_room_members(room_id, last_read_at);
CREATE INDEX idx_chat_messages_room ON chat_messages(room_id, created_at DESC);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id, created_at DESC);

-- ============================================================================
-- SECTION 10: NOTIFICATIONS
-- ============================================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    notification_type VARCHAR(50) NOT NULL,  -- 'connection_request', 'event_invite', 'message', 'review', etc.
    title VARCHAR(200),
    body TEXT,
    
    -- Action
    action_type VARCHAR(50),               -- 'open_profile', 'open_event', 'open_chat'
    action_data JSONB,                     -- {"user_id": "...", "event_id": "..."}
    
    -- Related entities
    related_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    related_event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    related_group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    
    -- Status
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    is_pushed BOOLEAN DEFAULT false,
    pushed_at TIMESTAMP,
    
    -- Grouping
    group_key VARCHAR(100),                -- For collapsing similar notifications
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(notification_type, created_at DESC);

-- ============================================================================
-- SECTION 11: ANALYTICS & HISTORY
-- ============================================================================

-- User stats (aggregated, updated periodically)
CREATE TABLE user_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Connections
    total_connections INTEGER DEFAULT 0,
    friends_count INTEGER DEFAULT 0,
    romantic_connections INTEGER DEFAULT 0,
    activity_partners INTEGER DEFAULT 0,
    
    -- Events
    events_created INTEGER DEFAULT 0,
    events_joined INTEGER DEFAULT 0,
    events_completed INTEGER DEFAULT 0,
    events_cancelled INTEGER DEFAULT 0,
    events_no_show INTEGER DEFAULT 0,
    
    -- Groups
    groups_joined INTEGER DEFAULT 0,
    groups_created INTEGER DEFAULT 0,
    
    -- Reviews
    reviews_given INTEGER DEFAULT 0,
    reviews_received INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    
    -- Safety
    reports_received INTEGER DEFAULT 0,
    blocks_received INTEGER DEFAULT 0,
    warnings_received INTEGER DEFAULT 0,
    
    -- Engagement
    profile_views INTEGER DEFAULT 0,
    messages_sent INTEGER DEFAULT 0,
    match_rate DECIMAL(5,2),               -- % of likes that became mutual
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_stats ON user_stats(user_id);

-- ============================================================================
-- SECTION 12: HELPER FUNCTIONS
-- ============================================================================

-- Function to calculate distance between two points (in km)
CREATE OR REPLACE FUNCTION calculate_distance_km(
    lat1 DECIMAL, lng1 DECIMAL, lat2 DECIMAL, lng2 DECIMAL
) RETURNS DECIMAL AS $$
BEGIN
    RETURN ST_DistanceSphere(
        ST_SetSRID(ST_MakePoint(lng1, lat1), 4326),
        ST_SetSRID(ST_MakePoint(lng2, lat2), 4326)
    ) / 1000.0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to generate event occurrences
CREATE OR REPLACE FUNCTION generate_event_occurrences(
    p_event_id UUID,
    p_days_ahead INTEGER DEFAULT 60
) RETURNS INTEGER AS $$
DECLARE
    v_event RECORD;
    v_current_date DATE;
    v_end_date DATE;
    v_occurrence_count INTEGER := 0;
    v_next_occurrence TIMESTAMP;
BEGIN
    SELECT * INTO v_event FROM events WHERE id = p_event_id AND is_recurring = true;
    
    IF NOT FOUND THEN
        RETURN 0;
    END IF;
    
    v_current_date := CURRENT_DATE;
    v_end_date := LEAST(
        COALESCE(v_event.recurrence_end_date, v_current_date + INTERVAL '1 year'),
        v_current_date + p_days_ahead * INTERVAL '1 day'
    );
    
    -- Generate occurrences based on recurrence rule
    -- (Simplified - in production, use proper RRULE parsing)
    WHILE v_current_date <= v_end_date AND (v_event.recurrence_count IS NULL OR v_occurrence_count < v_event.recurrence_count) LOOP
        -- Check if this day matches recurrence pattern
        IF v_event.recurrence_frequency = 'daily' OR 
           (v_event.recurrence_frequency = 'weekly' AND LOWER(TO_CHAR(v_current_date, 'day')) = ANY(v_event.recurrence_days)) THEN
            
            v_next_occurrence := v_current_date + v_event.start_time::TIME;
            
            -- Insert occurrence if not exists
            INSERT INTO event_occurrences (event_id, occurrence_number, start_time, end_time, status)
            VALUES (
                p_event_id, 
                v_occurrence_count + 1, 
                v_next_occurrence,
                v_next_occurrence + (v_event.duration_minutes || ' minutes')::INTERVAL,
                'open'
            )
            ON CONFLICT (event_id, occurrence_number) DO NOTHING;
            
            v_occurrence_count := v_occurrence_count + 1;
        END IF;
        
        v_current_date := v_current_date + INTERVAL '1 day';
    END LOOP;
    
    RETURN v_occurrence_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update user stats on review
CREATE OR REPLACE FUNCTION update_user_reputation()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_profiles_extended
    SET 
        reputation_score = (
            SELECT COALESCE(AVG(rating), 5.0)
            FROM reviews
            WHERE reviewed_user_id = NEW.reviewed_user_id AND NOT is_hidden
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews
            WHERE reviewed_user_id = NEW.reviewed_user_id AND NOT is_hidden
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.reviewed_user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_reputation
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_user_reputation();

-- Trigger to update event participant count
CREATE OR REPLACE FUNCTION update_event_participant_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE events
    SET 
        current_participants = (
            SELECT COUNT(*)
            FROM event_participants
            WHERE event_id = COALESCE(NEW.event_id, OLD.event_id) AND status = 'approved'
        ),
        waitlist_count = (
            SELECT COUNT(*)
            FROM event_participants
            WHERE event_id = COALESCE(NEW.event_id, OLD.event_id) AND status = 'waitlisted'
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.event_id, OLD.event_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_event_participants
AFTER INSERT OR UPDATE OR DELETE ON event_participants
FOR EACH ROW EXECUTE FUNCTION update_event_participant_count();
