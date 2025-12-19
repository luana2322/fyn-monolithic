BEGIN;

-- ============================================================================
-- SAMPLE DATA FOR AI EMBEDDING & RECOMMENDATION TESTING
-- Fixed v2: users.version + user_profiles.version
-- ============================================================================
-- Date: 2025-12-19
-- Domain: Social / Dating / Lifestyle
-- Language: Vietnamese
-- ============================================================================

-- =========================
-- USERS
-- =========================
INSERT INTO users (
    id,
    email,
    username,
    password_hash,
    full_name,
    status,
    version,
    created_at
) VALUES
(gen_random_uuid(), 'minh.nguyen@example.com', 'minhnguyen',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Nguyễn Văn Minh', 'ACTIVE', 0, NOW() - INTERVAL '45 days'),

(gen_random_uuid(), 'lan.tran@example.com', 'lantran',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Trần Thị Lan', 'ACTIVE', 0, NOW() - INTERVAL '42 days'),

(gen_random_uuid(), 'huy.le@example.com', 'huyle',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Lê Quốc Huy', 'ACTIVE', 0, NOW() - INTERVAL '40 days'),

(gen_random_uuid(), 'mai.pham@example.com', 'maipham',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Phạm Thùy Mai', 'ACTIVE', 0, NOW() - INTERVAL '38 days'),

(gen_random_uuid(), 'dat.vo@example.com', 'datvo',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Võ Minh Đạt', 'ACTIVE', 0, NOW() - INTERVAL '36 days'),

(gen_random_uuid(), 'linh.nguyen@example.com', 'linhnguyen',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Nguyễn Khánh Linh', 'ACTIVE', 0, NOW() - INTERVAL '30 days'),

(gen_random_uuid(), 'phong.tran@example.com', 'phongtran',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Trần Đức Phong', 'ACTIVE', 0, NOW() - INTERVAL '28 days'),

(gen_random_uuid(), 'thu.le@example.com', 'thule',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Lê Thu Phương', 'ACTIVE', 0, NOW() - INTERVAL '26 days'),

(gen_random_uuid(), 'quan.nguyen@example.com', 'quannguyen',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Nguyễn Trung Quân', 'ACTIVE', 0, NOW() - INTERVAL '16 days'),

(gen_random_uuid(), 'phuong.tran@example.com', 'phuongtran',
 '$2a$10$N9qo8uLOickgx2ZMRZoMye.IVI1LRfW1Ck8pAyXKX8F0K7h2tD0La',
 'Trần Minh Phượng', 'ACTIVE', 0, NOW() - INTERVAL '30 minutes');

-- =========================
-- USER PROFILES (FIXED)
-- =========================
INSERT INTO user_profiles (
    id,
    user_id,
    bio,
    version,
    created_at
)
SELECT
    gen_random_uuid(),
    u.id,
    'Yêu du lịch, thích cafe và kết nối bạn mới ☕🌏',
    0,
    NOW() - INTERVAL '30 days'
FROM users u;

-- =========================
-- POSTS (CORE DATA FOR EMBEDDING)
-- =========================
INSERT INTO posts (
    id,
    author_id,
    content,
    visibility,
    created_at,
    like_count,
    comment_count
)
SELECT
    gen_random_uuid(),
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    content,
    'PUBLIC',
    NOW() - (floor(random() * 60) || ' days')::INTERVAL,
    0,
    0
FROM (
    SELECT unnest(ARRAY[
        'Hôm nay cảm giác hơi cô đơn, muốn tìm người nói chuyện 😔',
        'Cuối tuần này ai rảnh đi cafe không? ☕',
        'Single life cũng vui mà, đúng không mọi người?',
        'Mới tập gym được 1 tháng, thấy khỏe hơn hẳn 💪',
        'Stress quá, cần một chuyến du lịch gấp 🌴',
        'Thích người nói chuyện có chiều sâu',
        'Sài Gòn ban đêm thật đẹp 🌃',
        'Đang tìm người cùng sở thích chụp ảnh 📸',
        'Cuộc sống đôi khi chỉ cần chậm lại một chút',
        'Muốn học thêm kỹ năng mới trong năm nay'
    ]) AS content
) t,
generate_series(1, 40);

-- =========================
-- LIKES
-- =========================
INSERT INTO post_likes (id, post_id, user_id, created_at)
SELECT
    gen_random_uuid(),
    p.id,
    u.id,
    NOW() - (floor(random() * 30) || ' days')::INTERVAL
FROM posts p
JOIN users u ON u.id <> p.author_id
ORDER BY random()
LIMIT 300
ON CONFLICT DO NOTHING;

UPDATE posts p
SET like_count = (
    SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id
);

-- =========================
-- COMMENTS
-- =========================
INSERT INTO post_comments (id, post_id, author_id, content, created_at)
SELECT
    gen_random_uuid(),
    p.id,
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    comment,
    NOW() - (floor(random() * 20) || ' days')::INTERVAL
FROM posts p,
unnest(ARRAY[
    'Đồng cảm ghê',
    'Hay quá bạn ơi',
    'Mình cũng vậy',
    'Nghe thích thật',
    'Chuẩn luôn'
]) AS comment
ORDER BY random()
LIMIT 200;

UPDATE posts p
SET comment_count = (
    SELECT COUNT(*) FROM post_comments pc WHERE pc.post_id = p.id
);

COMMIT;
