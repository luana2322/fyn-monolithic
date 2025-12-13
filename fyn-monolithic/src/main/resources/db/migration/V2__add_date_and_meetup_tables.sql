-- V2: Create DatePlan, DateProposal, and Meetup tables for connection features

-- Create date_plans table
CREATE TABLE IF NOT EXISTS date_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    partner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    place_type VARCHAR(50) NOT NULL DEFAULT 'OTHER',
    place_name VARCHAR(255),
    place_address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INT DEFAULT 120,
    is_public BOOLEAN DEFAULT false,
    status VARCHAR(50) NOT NULL DEFAULT 'OPEN',
    connection_type VARCHAR(50) NOT NULL DEFAULT 'DATING',
    max_proposals INT DEFAULT 10,
    proposal_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for date_plans
CREATE INDEX IF NOT EXISTS idx_date_plans_owner ON date_plans(owner_id);
CREATE INDEX IF NOT EXISTS idx_date_plans_status ON date_plans(status);
CREATE INDEX IF NOT EXISTS idx_date_plans_is_public ON date_plans(is_public);
CREATE INDEX IF NOT EXISTS idx_date_plans_scheduled_at ON date_plans(scheduled_at);

-- Create date_proposals table
CREATE TABLE IF NOT EXISTS date_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date_id UUID NOT NULL REFERENCES date_plans(id) ON DELETE CASCADE,
    proposer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT,
    proposed_time TIMESTAMPTZ,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(date_id, proposer_id)
);

-- Create indexes for date_proposals
CREATE INDEX IF NOT EXISTS idx_date_proposals_date ON date_proposals(date_id);
CREATE INDEX IF NOT EXISTS idx_date_proposals_proposer ON date_proposals(proposer_id);
CREATE INDEX IF NOT EXISTS idx_date_proposals_status ON date_proposals(status);

-- Create meetups table
CREATE TABLE IF NOT EXISTS meetups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INT DEFAULT 120,
    max_participants INT DEFAULT 10,
    status VARCHAR(50) NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for meetups
CREATE INDEX IF NOT EXISTS idx_meetups_organizer ON meetups(organizer_id);
CREATE INDEX IF NOT EXISTS idx_meetups_category ON meetups(category);
CREATE INDEX IF NOT EXISTS idx_meetups_status ON meetups(status);
CREATE INDEX IF NOT EXISTS idx_meetups_scheduled_at ON meetups(scheduled_at);

-- Create meetup_participants junction table
CREATE TABLE IF NOT EXISTS meetup_participants (
    meetup_id UUID NOT NULL REFERENCES meetups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (meetup_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_meetup_participants_user ON meetup_participants(user_id);
