-- Add status to posts
ALTER TABLE posts ADD COLUMN status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL;

-- Add role to users
ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'USER' NOT NULL;

-- Create post_reports table
CREATE TABLE post_reports (
    id UUID PRIMARY KEY,
    post_id UUID NOT NULL,
    reporter_id UUID NOT NULL,
    reason VARCHAR(50) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'PENDING' NOT NULL,
    moderation_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 0 NOT NULL,
    CONSTRAINT fk_report_post FOREIGN KEY (post_id) REFERENCES posts(id),
    CONSTRAINT fk_report_reporter FOREIGN KEY (reporter_id) REFERENCES users(id)
);

-- Create admin_action_logs table
CREATE TABLE admin_action_logs (
    id UUID PRIMARY KEY,
    admin_id UUID NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    target_id UUID NOT NULL,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    version BIGINT DEFAULT 0 NOT NULL,
    CONSTRAINT fk_admin_action_admin FOREIGN KEY (admin_id) REFERENCES users(id)
);

-- Add indexes
CREATE INDEX idx_post_reports_post_id ON post_reports(post_id);
CREATE INDEX idx_post_reports_status ON post_reports(status);
CREATE INDEX idx_admin_action_logs_admin_id ON admin_action_logs(admin_id);
CREATE INDEX idx_admin_action_logs_target_id ON admin_action_logs(target_id);
