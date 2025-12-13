-- =============================================================================
-- BASE SCHEMA (From existing system)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(32) UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(120),
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    bio VARCHAR(512),
    website VARCHAR(255),
    location VARCHAR(255),
    avatar_object_key VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    is_private BOOLEAN NOT NULL DEFAULT FALSE,
    allow_messages BOOLEAN NOT NULL DEFAULT TRUE,
    push_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    email_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_followers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    muted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT uq_follower UNIQUE (user_id, follower_id)
);

CREATE TABLE IF NOT EXISTS user_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token VARCHAR(512) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    ip_address VARCHAR(64),
    user_agent VARCHAR(255),
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_login_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ip_address VARCHAR(64),
    user_agent VARCHAR(255),
    success BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    visibility VARCHAR(20) NOT NULL,
    comment_count BIGINT NOT NULL DEFAULT 0,
    like_count BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS post_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    object_key VARCHAR(255) NOT NULL,
    media_type VARCHAR(30) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT uq_post_like UNIQUE (post_id, user_id)
);

CREATE TABLE IF NOT EXISTS post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    content VARCHAR(1024) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL,
    title VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS conversation_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT uq_member UNIQUE (conversation_id, member_id)
);

-- Note: Replaced by chat_messages in V2, but kept for legacy
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    reaction VARCHAR(10),
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS message_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    object_key VARCHAR(255) NOT NULL,
    media_type VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

-- Note: Dropping legacy notifications to replace with new schema
DROP TABLE IF EXISTS notifications;

CREATE TABLE IF NOT EXISTS hashtags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag VARCHAR(120) NOT NULL UNIQUE,
    usage_count BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS post_hashtags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    hashtag_id UUID NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT uq_post_hashtag UNIQUE (post_id, hashtag_id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id VARCHAR(255),
    action VARCHAR(255) NOT NULL,
    resource VARCHAR(255) NOT NULL,
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS file_storage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_key VARCHAR(255) NOT NULL UNIQUE,
    bucket VARCHAR(120) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    content_type VARCHAR(120),
    size_bytes BIGINT NOT NULL,
    media_type VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 0
);

-- =============================================================================
-- SECTION 1: ENUMS & TYPES (V2)
-- =============================================================================

CREATE TYPE connection_type AS ENUM (
    'friend', 'romantic', 'activity_partner', 'study_partner', 'tutor', 'mentor', 
    'mentee', 'colleague', 'business', 'roommate', 'acquaintance', 'service_provider'
);

CREATE TYPE connection_status AS ENUM ('pending', 'accepted', 'rejected', 'blocked', 'expired');
CREATE TYPE group_type AS ENUM ('sport', 'study', 'hangout', 'gaming', 'travel', 'hobby', 'professional', 'support', 'community', 'other');
CREATE TYPE group_visibility AS ENUM ('public', 'private', 'event_based', 'invite_only');
CREATE TYPE member_role AS ENUM ('owner', 'admin', 'moderator', 'member', 'pending');
CREATE TYPE event_status AS ENUM ('draft', 'open', 'waiting_list', 'full', 'ongoing', 'completed', 'cancelled', 'expired');
CREATE TYPE event_visibility AS ENUM ('public', 'friends_only', 'group_only', 'invite_only');
CREATE TYPE activity_type AS ENUM ('coffee', 'breakfast', 'brunch', 'lunch', 'dinner', 'drinks', 'sports', 'gym', 'hiking', 'cycling', 'running', 'swimming', 'movie', 'concert', 'theater', 'museum', 'exhibition', 'study', 'tutoring', 'workshop', 'seminar', 'conference', 'gaming', 'board_games', 'esports', 'travel', 'road_trip', 'camping', 'networking', 'meetup', 'coworking', 'volunteer', 'charity', 'party', 'celebration', 'other');
CREATE TYPE participant_status AS ENUM ('pending', 'approved', 'rejected', 'waitlisted', 'cancelled', 'attended', 'no_show');
CREATE TYPE recurrence_frequency AS ENUM ('daily', 'weekly', 'biweekly', 'monthly', 'custom');
CREATE TYPE report_reason AS ENUM ('inappropriate_content', 'harassment', 'spam', 'fake_profile', 'scam', 'violence', 'hate_speech', 'impersonation', 'underage', 'other');
CREATE TYPE report_status AS ENUM ('pending', 'reviewing', 'resolved', 'dismissed', 'escalated');
CREATE TYPE review_context AS ENUM ('event', 'connection', 'group', 'service');
CREATE TYPE verification_type AS ENUM ('phone', 'email', 'government_id', 'social', 'photo');

-- ============================================================================
-- SECTION 2: USER TABLES EXTENDED
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_profiles_extended (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender VARCHAR(20),
    gender_identity VARCHAR(50),
    pronouns VARCHAR(20),
    looking_for VARCHAR(50)[],
    relationship_status VARCHAR(30),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_city VARCHAR(100),
    location_district VARCHAR(100),
    location_country VARCHAR(100) DEFAULT 'Vietnam',
    location_approximate BOOLEAN DEFAULT true,
    max_distance_km INTEGER DEFAULT 50,
    preferred_age_min INTEGER DEFAULT 18,
    preferred_age_max INTEGER DEFAULT 99,
    preferred_genders VARCHAR(20)[],
    available_days VARCHAR(10)[],
    available_time_slots JSONB,
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    personality_type VARCHAR(10),
    interests TEXT[],
    languages VARCHAR(50)[],
    occupation VARCHAR(100),
    company VARCHAR(100),
    education VARCHAR(150),
    education_level VARCHAR(50),
    smoking VARCHAR(20),
    drinking VARCHAR(20),
    diet VARCHAR(30),
    exercise_frequency VARCHAR(20),
    pets VARCHAR(50)[],
    reputation_score DECIMAL(3,2) DEFAULT 5.00 CHECK (reputation_score >= 0 AND reputation_score <= 5),
    total_reviews INTEGER DEFAULT 0,
    total_events_attended INTEGER DEFAULT 0,
    total_events_created INTEGER DEFAULT 0,
    response_rate DECIMAL(5,2) DEFAULT 100.00,
    avg_response_time_minutes INTEGER,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    verification_level INTEGER DEFAULT 0,
    profile_completeness INTEGER DEFAULT 0 CHECK (profile_completeness >= 0 AND profile_completeness <= 100),
    last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_online BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    verification_type verification_type NOT NULL,
    verification_data JSONB,
    verified_at TIMESTAMP,
    expires_at TIMESTAMP,
    is_valid BOOLEAN DEFAULT true,
    verified_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, verification_type)
);

CREATE TABLE IF NOT EXISTS user_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    caption TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    relationship VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_location ON user_profiles_extended USING GIST (ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326));
CREATE INDEX IF NOT EXISTS idx_user_interests ON user_profiles_extended USING GIN(interests);
CREATE INDEX IF NOT EXISTS idx_user_looking_for ON user_profiles_extended USING GIN(looking_for);
CREATE INDEX IF NOT EXISTS idx_user_last_active ON user_profiles_extended(last_active_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_age ON user_profiles_extended(date_of_birth);

-- ============================================================================
-- SECTION 3: CONNECTION SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS connection_type_metadata (
    connection_type connection_type PRIMARY KEY,
    requires_mutual_consent BOOLEAN DEFAULT true,
    supports_group BOOLEAN DEFAULT false,
    is_business_related BOOLEAN DEFAULT false,
    max_pending_days INTEGER DEFAULT 30,
    allows_intro_message BOOLEAN DEFAULT true,
    display_name_en VARCHAR(50),
    display_name_vi VARCHAR(50)
);

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
('service_provider', false, false, true, 30, true, 'Service Provider', 'Nhà cung cấp')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    connection_type connection_type NOT NULL,
    status connection_status DEFAULT 'pending',
    match_score DECIMAL(5,2),
    matched_interests TEXT[],
    match_source VARCHAR(50),
    intro_message TEXT,
    response_message TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    expires_at TIMESTAMP,
    requester_follows_receiver BOOLEAN DEFAULT true,
    receiver_follows_requester BOOLEAN DEFAULT false,
    UNIQUE(requester_id, receiver_id, connection_type),
    CHECK (requester_id != receiver_id)
);

CREATE INDEX IF NOT EXISTS idx_connections_requester ON connections(requester_id, status);
CREATE INDEX IF NOT EXISTS idx_connections_receiver ON connections(receiver_id, status);
CREATE INDEX IF NOT EXISTS idx_connections_type_status ON connections(connection_type, status);
CREATE INDEX IF NOT EXISTS idx_connections_expires ON connections(expires_at) WHERE status = 'pending';

-- ============================================================================
-- SECTION 4: GROUP SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    description TEXT,
    cover_image_url VARCHAR(500),
    icon_url VARCHAR(200),
    group_type group_type NOT NULL,
    visibility group_visibility DEFAULT 'public',
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(200),
    rules TEXT[],
    welcome_message TEXT,
    max_members INTEGER DEFAULT 1000,
    requires_approval BOOLEAN DEFAULT false,
    min_age INTEGER DEFAULT 18,
    allowed_genders VARCHAR(20)[],
    min_reputation_score DECIMAL(3,2),
    min_events_attended INTEGER DEFAULT 0,
    member_count INTEGER DEFAULT 0,
    active_member_count INTEGER DEFAULT 0,
    total_events INTEGER DEFAULT 0,
    chat_enabled BOOLEAN DEFAULT true,
    chat_room_id UUID,
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    notifications_enabled BOOLEAN DEFAULT true,
    is_muted BOOLEAN DEFAULT false,
    nickname VARCHAR(50),
    last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    messages_count INTEGER DEFAULT 0,
    events_attended INTEGER DEFAULT 0,
    UNIQUE(group_id, user_id)
);

CREATE TABLE IF NOT EXISTS group_join_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    message TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    responded_by UUID REFERENCES users(id),
    response_message TEXT,
    UNIQUE(group_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_group_members_user ON group_members(user_id, role);
CREATE INDEX IF NOT EXISTS idx_group_members_group ON group_members(group_id, role);

-- ============================================================================
-- SECTION 5: EVENT SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200),
    description TEXT,
    cover_image_url VARCHAR(500),
    activity_type activity_type NOT NULL,
    visibility event_visibility DEFAULT 'public',
    status event_status DEFAULT 'draft',
    is_online BOOLEAN DEFAULT false,
    online_meeting_url VARCHAR(500),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(200),
    location_address TEXT,
    location_place_id VARCHAR(100),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    duration_minutes INTEGER,
    min_participants INTEGER DEFAULT 2,
    max_participants INTEGER NOT NULL,
    current_participants INTEGER DEFAULT 0,
    waitlist_count INTEGER DEFAULT 0,
    requires_approval BOOLEAN DEFAULT true,
    allow_waitlist BOOLEAN DEFAULT true,
    auto_approve_verified BOOLEAN DEFAULT false,
    join_deadline_hours INTEGER,
    age_min INTEGER DEFAULT 18,
    age_max INTEGER DEFAULT 99,
    gender_preference VARCHAR(20),
    min_reputation_score DECIMAL(3,2),
    required_verifications verification_type[],
    is_recurring BOOLEAN DEFAULT false,
    recurrence_frequency recurrence_frequency,
    recurrence_rule TEXT,
    recurrence_days VARCHAR(10)[],
    recurrence_end_date DATE,
    recurrence_count INTEGER,
    parent_event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    chat_enabled BOOLEAN DEFAULT true,
    chat_room_id UUID,
    is_paid BOOLEAN DEFAULT false,
    price_amount DECIMAL(10,2),
    price_currency VARCHAR(3) DEFAULT 'VND',
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS event_occurrences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_number INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    status event_status DEFAULT 'open',
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    waitlist_count INTEGER DEFAULT 0,
    override_fields JSONB,
    chat_room_id UUID,
    is_cancelled BOOLEAN DEFAULT false,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, occurrence_number)
);

CREATE TABLE IF NOT EXISTS event_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_id UUID REFERENCES event_occurrences(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status participant_status DEFAULT 'pending',
    intro_message TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    responded_by UUID REFERENCES users(id),
    response_message TEXT,
    proposed_alternative_time TIMESTAMP,
    alternative_message TEXT,
    waitlist_position INTEGER,
    promoted_from_waitlist_at TIMESTAMP,
    checked_in_at TIMESTAMP,
    checked_out_at TIMESTAMP,
    check_in_location_lat DECIMAL(10, 8),
    check_in_location_lng DECIMAL(11, 8),
    recurring_signup_type VARCHAR(20),
    UNIQUE(event_id, occurrence_id, user_id)
);

CREATE TABLE IF NOT EXISTS event_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    occurrence_id UUID REFERENCES event_occurrences(id) ON DELETE CASCADE,
    invited_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invited_by UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    message TEXT,
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    UNIQUE(event_id, occurrence_id, invited_user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_location ON events USING GIST (ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326)) WHERE location_lat IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_event_time ON events(start_time, status) WHERE NOT is_recurring;
CREATE INDEX IF NOT EXISTS idx_participants_user ON event_participants(user_id, status);

-- ============================================================================
-- SECTION 6: REVIEW SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    context_type review_context NOT NULL,
    context_id UUID,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    punctuality_rating INTEGER,
    communication_rating INTEGER,
    friendliness_rating INTEGER,
    respectfulness_rating INTEGER,
    feedback TEXT,
    tags VARCHAR(50)[],
    photo_urls TEXT[],
    is_public BOOLEAN DEFAULT true,
    is_anonymous BOOLEAN DEFAULT false,
    is_flagged BOOLEAN DEFAULT false,
    is_hidden BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(reviewer_id, reviewed_user_id, context_type, context_id)
);

CREATE TABLE IF NOT EXISTS review_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL UNIQUE REFERENCES reviews(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pending_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    context_type review_context NOT NULL,
    context_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    reminder_sent_at TIMESTAMP,
    UNIQUE(reviewer_id, reviewed_user_id, context_type, context_id)
);

-- ============================================================================
-- SECTION 7: SAFETY SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(blocker_id, blocked_id)
);

CREATE TABLE IF NOT EXISTS user_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reported_user_id UUID NOT NULL REFERENCES users(id),
    reason report_reason NOT NULL,
    description TEXT,
    evidence_urls TEXT[],
    context_type VARCHAR(50),
    context_id UUID,
    status report_status DEFAULT 'pending',
    priority INTEGER DEFAULT 0,
    assigned_to UUID,
    reviewed_at TIMESTAMP,
    reviewed_by UUID REFERENCES users(id),
    resolution_notes TEXT,
    action_taken VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS content_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
    content_type VARCHAR(50) NOT NULL,
    content_id UUID NOT NULL,
    reason report_reason NOT NULL,
    description TEXT,
    status report_status DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS safety_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_accuracy DECIMAL(10, 2),
    checkin_type VARCHAR(20),
    is_sos BOOLEAN DEFAULT false,
    sos_message TEXT,
    emergency_contacts_notified BOOLEAN DEFAULT false,
    notified_at TIMESTAMP,
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS moderation_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,
    action_reason TEXT,
    duration_hours INTEGER,
    expires_at TIMESTAMP,
    performed_by UUID REFERENCES users(id),
    related_report_id UUID REFERENCES user_reports(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SECTION 8: MATCHING SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS match_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_b_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    overall_score DECIMAL(5,2) NOT NULL,
    location_score DECIMAL(5,2),
    interest_score DECIMAL(5,2),
    availability_score DECIMAL(5,2),
    personality_score DECIMAL(5,2),
    activity_pref_score DECIMAL(5,2),
    age_score DECIMAL(5,2),
    social_score DECIMAL(5,2),
    reputation_score DECIMAL(5,2),
    activity_score DECIMAL(5,2),
    match_reasons TEXT[],
    common_interests TEXT[],
    mutual_friends_count INTEGER DEFAULT 0,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_valid BOOLEAN DEFAULT true,
    UNIQUE(user_a_id, user_b_id)
);

CREATE TABLE IF NOT EXISTS swipe_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(10) NOT NULL,
    context VARCHAR(50),
    is_undone BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_user_id, context)
);

CREATE TABLE IF NOT EXISTS user_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id UUID,
    metadata JSONB,
    session_id VARCHAR(100),
    device_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ai_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    suggestion_type VARCHAR(50),
    target_id UUID,
    content TEXT,
    confidence_score DECIMAL(5,2),
    is_shown BOOLEAN DEFAULT false,
    is_used BOOLEAN DEFAULT false,
    user_feedback VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

-- ============================================================================
-- SECTION 9: CHAT SYSTEM V2
-- ============================================================================

CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_type VARCHAR(20) NOT NULL,
    name VARCHAR(100),
    description TEXT,
    avatar_url VARCHAR(500),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    is_muted_all BOOLEAN DEFAULT false,
    slow_mode_seconds INTEGER,
    message_count INTEGER DEFAULT 0,
    member_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat_room_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member',
    is_muted BOOLEAN DEFAULT false,
    muted_until TIMESTAMP,
    notifications_enabled BOOLEAN DEFAULT true,
    last_read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_message_id UUID,
    unread_count INTEGER DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(room_id, user_id)
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text',
    media_urls TEXT[],
    media_thumbnails TEXT[],
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(200),
    reply_to_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    thread_id UUID,
    reactions JSONB,
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_room ON chat_messages(room_id, created_at DESC);

-- ============================================================================
-- SECTION 10: NOTIFICATIONS V2
-- ============================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200),
    body TEXT,
    action_type VARCHAR(50),
    action_data JSONB,
    related_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    related_event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    related_group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    is_pushed BOOLEAN DEFAULT false,
    pushed_at TIMESTAMP,
    group_key VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_v2 ON notifications(user_id, is_read, created_at DESC);

-- ============================================================================
-- SECTION 11: STATS
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    total_connections INTEGER DEFAULT 0,
    friends_count INTEGER DEFAULT 0,
    romantic_connections INTEGER DEFAULT 0,
    activity_partners INTEGER DEFAULT 0,
    events_created INTEGER DEFAULT 0,
    events_joined INTEGER DEFAULT 0,
    events_completed INTEGER DEFAULT 0,
    events_cancelled INTEGER DEFAULT 0,
    events_no_show INTEGER DEFAULT 0,
    groups_joined INTEGER DEFAULT 0,
    groups_created INTEGER DEFAULT 0,
    reviews_given INTEGER DEFAULT 0,
    reviews_received INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    reports_received INTEGER DEFAULT 0,
    blocks_received INTEGER DEFAULT 0,
    warnings_received INTEGER DEFAULT 0,
    profile_views INTEGER DEFAULT 0,
    messages_sent INTEGER DEFAULT 0,
    match_rate DECIMAL(5,2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SECTION 12: FUNCTIONS & TRIGGERS
-- ============================================================================

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

DROP TRIGGER IF EXISTS trg_update_reputation ON reviews;
CREATE TRIGGER trg_update_reputation
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_user_reputation();

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

DROP TRIGGER IF EXISTS trg_update_event_participants ON event_participants;
CREATE TRIGGER trg_update_event_participants
AFTER INSERT OR UPDATE OR DELETE ON event_participants
FOR EACH ROW EXECUTE FUNCTION update_event_participant_count();
