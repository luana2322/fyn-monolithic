-- Add order_index column to post_media table for media ordering
-- Step 1: Add column as nullable first
ALTER TABLE post_media ADD COLUMN IF NOT EXISTS order_index INTEGER;

-- Step 2: Update existing rows to have default value 0
UPDATE post_media SET order_index = 0 WHERE order_index IS NULL;

-- Step 3: Add NOT NULL constraint
ALTER TABLE post_media ALTER COLUMN order_index SET NOT NULL;

-- Step 4: Set default for future inserts
ALTER TABLE post_media ALTER COLUMN order_index SET DEFAULT 0;

-- Create index for efficient ordering queries
CREATE INDEX IF NOT EXISTS idx_post_media_order ON post_media(post_id, order_index);
