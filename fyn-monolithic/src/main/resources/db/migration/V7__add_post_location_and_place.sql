-- Add location and place tagging to posts table
-- Supports both GPS location (PostGIS POINT) and tagged places

-- Add location column using PostGIS geometry type
ALTER TABLE posts
    ADD COLUMN location GEOMETRY(Point, 4326);

-- Add place tagging columns
ALTER TABLE posts
    ADD COLUMN place_code VARCHAR(50),
    ADD COLUMN place_name VARCHAR(255);

-- Create spatial index on location for efficient queries
CREATE INDEX idx_posts_location ON posts USING GIST (location);

-- Create index on place_code for filtering posts by place
CREATE INDEX idx_posts_place_code ON posts (place_code);

-- Add check constraint to ensure mutual exclusivity
-- Either location OR place can be set, not both
ALTER TABLE posts
    ADD CONSTRAINT chk_posts_location_or_place
    CHECK (
        (location IS NULL AND place_code IS NULL AND place_name IS NULL) OR
        (location IS NOT NULL AND place_code IS NULL AND place_name IS NULL) OR
        (location IS NULL AND place_code IS NOT NULL AND place_name IS NOT NULL)
    );

-- Comments for documentation
COMMENT ON COLUMN posts.location IS 'GPS location as PostGIS POINT (latitude, longitude)';
COMMENT ON COLUMN posts.place_code IS 'Tagged place identifier (e.g., HANOI, HCMC)';
COMMENT ON COLUMN posts.place_name IS 'Human-readable place name for display';
