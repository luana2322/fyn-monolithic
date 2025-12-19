-- Test insert one user to debug
INSERT INTO users (id, email, username, password_hash, full_name, status, created_at) VALUES
(gen_random_uuid(), 'test1@example.com', 'testuser1', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La', 'Test User 1', 'ACTIVE', NOW());

-- Check if user_settings is required
SELECT * FROM users WHERE email = 'test1@example.com';
