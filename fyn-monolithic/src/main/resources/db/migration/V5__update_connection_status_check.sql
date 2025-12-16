-- Update connections status check constraint to include new status values
ALTER TABLE connections DROP CONSTRAINT IF EXISTS connections_status_check;

ALTER TABLE connections ADD CONSTRAINT connections_status_check 
CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'BLOCKED', 'EXPIRED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'));
