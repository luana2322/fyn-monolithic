-- Migration script to add reaction column to messages table
-- Run this if the messages table already exists without the reaction column

ALTER TABLE messages ADD COLUMN IF NOT EXISTS reaction VARCHAR(10);

