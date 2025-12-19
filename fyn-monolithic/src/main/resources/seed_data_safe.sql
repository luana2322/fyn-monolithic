-- ============================================================================
-- SAFE IDEMPOTENT SEED DATA FOR AI EMBEDDING TESTING
-- ============================================================================
-- This script is SAFE to run multiple times
-- It respects all constraints and existing data
-- Focus: Vietnamese social/dating content for HuggingFace embeddings
-- ============================================================================

BEGIN;

-- ============================================================================
-- SECTION 1: USER_PROFILES (SAFE - only for users without profiles)
-- ============================================================================
-- Only create profiles for users that DON'T already have one
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
    CASE (ROW_NUMBER() OVER (ORDER BY u.created_at)) % 10
        WHEN 0 THEN 'Yêu du lịch và khám phá thế giới 🌏✈️'
        WHEN 1 THEN 'Coffee addict ☕ thích đọc sách 📚'
        WHEN 2 THEN 'Gym lover 💪 sống healthy'
        WHEN 3 THEN 'Foodie tìm kiếm quán ăn ngon 🍜'
        WHEN 4 THEN 'Developer & gamer 🎮💻'
        WHEN 5 THEN 'Photography enthusiast 📸'
        WHEN 6 THEN 'Yêu âm nhạc indie 🎵'
        WHEN 7 THEN 'Startup mindset 🚀'
        WHEN 8 THEN 'Yoga & meditation 🧘‍♀️'
        ELSE 'Tìm kiếm kết nối ý nghĩa ✨'
    END,
    0,
    NOW() - INTERVAL '20 days'
FROM users u
LEFT JOIN user_profiles up ON up.user_id = u.id
WHERE up.id IS NULL;  -- SAFE: only insert if profile doesn't exist

-- ============================================================================
-- SECTION 2: POSTS (AI Embedding Content - Vietnamese Social/Dating)
-- ============================================================================
-- Generate 100 diverse Vietnamese posts for embedding testing
INSERT INTO posts (
    id,
    author_id,
    content,
    visibility,
    created_at,
    like_count,
    comment_count,
    version
)
SELECT
    gen_random_uuid(),
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    content,
    'PUBLIC',
    NOW() - (floor(random() * 60)::INTEGER || ' days')::INTERVAL - (floor(random() * 24)::INTEGER || ' hours')::INTERVAL,
    0,
    0,
    0
FROM (
    SELECT unnest(ARRAY[
        -- Dating & Loneliness
        'Hôm nay cảm giác hơi cô đơn, muốn tìm người nói chuyện 😔',
        'Single life đôi khi cũng vui nhưng thiếu sự chia sẻ',
        'Ai muốn đi cafe cuối tuần này không nhỉ? ☕',
        'Tìm người cùng sở thích để kết nối',
        'Mới chia tay xong, cần thời gian để heal 💔',
        'Thích người có chiều sâu trong suy nghĩ',
        'T30 rồi mà vẫn FA, ai cũng vậy không? 😅',
        '
Yêu xa có vui không các bạn ơi?',
        'Weekend này ai rảnh đi bowling không? 🎳',
        'Thích người biết nấu ăn quá đi mất 😍🍳',
        
        -- Emotions & Daily Life
        'Hôm nay vui quá! Cuối cùng cũng xong deadline 🎉',
        'Mệt mỏi quá, cần một chuyến du lịch ngay 😫',
        'Thứ 2 buồn quá mọi người ơi 😢',
        'Cuộc sống đẹp lắm, hãy lạc quan lên! ☀️',
        'Stress công việc, cần uống bia thư giãn 🍺',
        'Sáng nay thức dậy cảm thấy tràn đầy năng lượng 💪',
        'Ai cũng có những ngày tồi tệ thôi',
        'Tối nay mưa to, ở nhà xem phim vậy 🌧️',
        'TGIF! Cuối tuần rồi các bạn! 🎊',
        'Hôm nay tâm trạng không ổn lắm...',
        
        -- Food & Travel
        'Phở sáng nay ngon không tưởng! 🍜❤️',
        'Ai biết quán bún bò Huế ngon ở Hà Nội không?',
        'Vừa về từ Đà Lạt, view đẹp muốn xỉu 😍🌲',
        'Weekend này đi Hạ Long nha! ⛵',
        'Bánh mì Sài Gòn không ai sánh được 🥖',
        'Cà phê sữa đá = happiness 😌☕',
        'Planning chuyến đi Phú Quốc tháng sau! 🏖️',
        'Lần đầu ăn sushi ngon vậy! 🍣',
        'Hội An đẹp quá trời quá đất 🏮',
        'Thèm ăn bún chả Hà Nội ghê 🤤',
        
        -- Hobbies & Fitness
        'Vừa hoàn thành marathon 21km! 🏃‍♂️',
        'Gaming all night, ai chơi VALORANT không? 🎮',
        'Học guitar được 3 tháng rồi 🎸',
        'Yoga buổi sáng là cách tốt nhất bắt đầu ngày 🧘',
        'Vẽ tranh thấy relax quá 🎨',
        'Ai làm handmade với mình không? ✂️',
        'Đọc xong quyển sách tuyệt vời! 📖✨',
        'Hôm nay luyện boxing, người mỏi 🥊',
        'Chụp ảnh street photography cực ghiền 📷',
        'Tối nay đi xem concert ai cùng không? 🎵',
        
        -- Work & Career
        'Lương tháng này về! Đi shopping thôi 💸',
        'Làm việc remote thoải mái nhưng cô đơn 💻',
        'Vừa pass phỏng vấn company mơ ước! 🎉',
        'Thứ 2 với meeting là một 😩',
        'Làm freelancer vui nhưng không stable',
        'Đang nghiền ngẫm chuyện lập startup 🚀',
        'Code cả ngày mà bug không hết 😤',
        'Được tăng lương rồi! 📈',
        'Project launch thành công! 👏',
        'Nghỉ phép 1 tuần, chill! 🏝️',
        
        -- Personal Growth & Reflection
        'Sống ở Hà Nội hay Sài Gòn tốt hơn? 🤔',
        'Thức khuya nhiều không tốt cho sức khỏe',
        'Tự nấu ăn tiết kiệm và healthy hơn',
        'Mọi người nghĩ sao về kết hôn trước 30?',
        'Sống tối giản giúp mình hạnh phúc hơn ✨',
        'Tập thể dục mỗi sáng là thói quen tốt! 🏃',
        'Đi du lịch một mình cũng tuyệt đấy 🌍',
        'Học tiếng Anh mỗi ngày 📚',
        'Muốn nuôi chó nhưng chưa sẵn sàng 🐕',
        'Thời tiết Sài Gòn nóng quá 🥵',
        
        -- Connection & Social
        'Ai muốn đi cafe cùng không? ☕',
        'Tối nay rảnh, chill ở nhà xem Netflix 📺',
        'Weekend này ai đi chơi không? 🎉',
        'Đang tìm người cùng sở thích photography 📸',
        'Happy hour! Ai đi uống bia? 🍻',
        'Tìm bạn đi leo núi cuối tuần! ⛰️',
        'Hôm nay tập vất vả nhưng tuyệt 💪',
        'Quán cơm tấm này ngon lắm 🍛',
        'Sài Gòn ban đêm đẹp vô cùng 🌃',
        'Ai thích nhạc indie không? 🎵',
        
        -- More varied content
        'Weekend đi Vũng Tàu ngắm biển 🌊',
        'Cần motivation thức dậy sớm 😅',
        'Tối nay đi chạy bộ công viên không? 🏃‍♀️',
        'Đọc sách mỗi ngày giúp grow nhiều 📖',
        'Ai chơi tennis với mình không? 🎾',
        'Hôm nay làm việc hiệu quả quá! 🚀',
        'Thèm phở Hà Nội, quán nào ngon? 🍜',
        'Mới về từ gym, người nhẹ hơn 🏋️',
        'Tìm người học tiếng Nhật cùng! 🇯🇵',
        'Ai thích đi bar tối thứ 6? 🍸',
        'Hôm nay cực kỳ productive! ✅',
        'Đang chill tại quán cafe yêu thích ☕❤️',
        'Tối nay karaoke nha! 🎤',
        'Muốn đi Nhật lắm, ai đã đi chưa? 🇯🇵',
        'Thứ 2 này năng lượng tốt! 💯',
        'Ai biết quán lẩu ngon giá hợp lý? 🍲',
        'Weekend đi picnic Ecopark! 🧺',
        'Hôm nay tâm trạng tốt vô cùng! 😊',
        'Đang nghiền ngẫm về cuộc sống... 🤔',
        'Tối nay xem phim kinh dị ai cùng? 👻',
        'Học piano được 6 tháng rồi! 🎹',
        'Ai thích chụp ảnh vintage? 📷',
        'Hôm nay chạy được 5km! 🏃',
        'Tìm người đi trekking Sapa tháng sau 🏔️',
        'Quán trà sữa mới này ngon lắm! 🧋',
        'Ai học marketing cùng mình? 📊',
        'Weekend này stay home relax 🛋️',
        'Đang tìm người cùng đam mê nhiếp ảnh',
        'Thích người có văn hóa đọc sách'
    ]) AS content
) t;

-- ============================================================================
-- SECTION 3: LIKES (SAFE - prevent duplicates with NOT EXISTS)
-- ============================================================================
-- Each user likes 5-10 random posts (not their own)
INSERT INTO post_likes (
    id,
    post_id,
    user_id,
    created_at,
    version
)
SELECT DISTINCT ON (p.id, u.id)
    gen_random_uuid(),
    p.id,
    u.id,
    NOW() - (floor(random() * 45)::INTEGER || ' days')::INTERVAL,
    0
FROM users u
CROSS JOIN LATERAL (
    SELECT p.id
    FROM posts p
    WHERE p.author_id != u.id  -- Don't like own posts
    AND NOT EXISTS (
        SELECT 1 FROM post_likes pl
        WHERE pl.post_id = p.id AND pl.user_id = u.id
    )  -- SAFE: skip if like already exists
    ORDER BY random()
    LIMIT (5 + floor(random() * 6)::INTEGER)  -- 5-10 likes per user
) p;

-- ============================================================================
-- SECTION 4: UPDATE LIKE COUNTS (Denormalized counter sync)
-- ============================================================================
UPDATE posts p
SET like_count = (
    SELECT COUNT(*)
    FROM post_likes pl
    WHERE pl.post_id = p.id
);

-- ============================================================================
-- SECTION 5: COMMENTS (Vietnamese conversational)
-- ============================================================================
-- Add 1-3 comments to random posts
INSERT INTO post_comments (
    id,
    post_id,
    author_id,
    content,
    created_at,
    version
)
SELECT
    gen_random_uuid(),
    p.id,
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    comment,
    NOW() - (floor(random() * 40)::INTEGER || ' days')::INTERVAL - (floor(random() * 24)::INTEGER || ' hours')::INTERVAL,
    0
FROM posts p
CROSS JOIN LATERAL (
    SELECT unnest(ARRAY[
        'Đồng cảm quá bạn ơi!',
        'Mình cũng nghĩ vậy',
        'Hay quá á!',
        'Đồng ý với bạn',
        'Mình cũng muốn thử',
        'Chính xác luôn!',
        'Chia sẻ hay lắm',
        'Cảm ơn đã share',
        'Mình cũng thích',
        'Quá tuyệt!',
        'Nghe hay ghê',
        'Mình cũng vậy',
        'Đỉnh quá!',
        'Muốn đi cùng',
        'Inbox mình nha',
        'Đi chung nha!',
        'Hay lắm bạn',
        'Thật không?',
        'Wow amazing!',
        'Chill vậy',
        'Buồn cười ghê',
        'Đồng cảm!',
        'Hay thật đó'
    ]) AS comment
    ORDER BY random()
    LIMIT (1 + floor(random() * 3)::INTEGER)  -- 1-3 comments per post
) comments
ORDER BY random()
LIMIT 200;  -- Total ~200 comments

-- ============================================================================
-- SECTION 6: UPDATE COMMENT COUNTS (Denormalized counter sync)
-- ============================================================================
UPDATE posts p
SET comment_count = (
    SELECT COUNT(*)
    FROM post_comments pc
    WHERE pc.post_id = p.id
);

COMMIT;

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
SELECT 
    'SEED DATA SUMMARY' as info,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM user_profiles) as profiles_created,
    (SELECT COUNT(*) FROM posts) as total_posts,
    (SELECT COUNT(*) FROM post_likes) as total_likes,
    (SELECT COUNT(*) FROM post_comments) as total_comments;

-- Verify each user has enough likes for AI recommendation (min 3)
SELECT 
    'USERS WITH SUFFICIENT LIKES (>=3)' as check_name,
    COUNT(*) as user_count
FROM (
    SELECT user_id, COUNT(*) as like_count
    FROM post_likes
    GROUP BY user_id
    HAVING COUNT(*) >= 3
) t;
