-- ============================================================================
-- SAMPLE DATA FOR AI EMBEDDING & RECOMMENDATION TESTING (POSTS ONLY)
-- ============================================================================
-- Uses EXISTING users to create posts, likes, and comments
-- No new users are created
-- ============================================================================

DO $$
DECLARE
    v_user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM users;
    
    -- Verify users exist
    IF v_user_count < 1 THEN
        RAISE EXCEPTION 'No users found in database. Cannot create sample data.';
    END IF;
    
    RAISE NOTICE 'Found % existing users. Proceeding with data generation...', v_user_count;
END $$;

BEGIN;

-- Insert 400 posts with diverse Vietnamese content spread over 60 days
INSERT INTO posts (id, author_id, content, visibility, created_at, like_count, comment_count, version) VALUES
-- Dating & Relationships theme
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Hôm nay cảm giác cô đơn quá 😔 Ai muốn đi cafe không nhỉ?', 'PUBLIC', NOW() - INTERVAL '59 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Tìm người cùng sở thích đi xem phim cuối tuần này ☺️', 'PUBLIC', NOW() - INTERVAL '58 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Single life cũng vui mà 🤷‍♀️ Ai cũng vậy không?', 'PUBLIC', NOW() - INTERVAL '57 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Mới chia tay xong, cần thời gian để heal 💔', 'PUBLIC', NOW() - INTERVAL '56 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Tìm bạn đi tập gym cùng khu Thảo Điền nhé! 💪', 'PUBLIC', NOW() - INTERVAL '55 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Weekend này ai rảnh đi chơi bowling không? 🎳', 'PUBLIC', NOW() - INTERVAL '54 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Thích người biết nấu ăn quá đi mất 😍🍳', 'PUBLIC', NOW() - INTERVAL '53 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Yêu xa có vui không các bạn ơi? 🤔', 'PUBLIC', NOW() - INTERVAL '52 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'T30 rồi mà vẫn FA, trời ơi 😅', 'PUBLIC', NOW() - INTERVAL '51 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Ai thích đi phượt cuối tuần không nhỉ? 🏍️', 'PUBLIC', NOW() - INTERVAL '50 days', 0, 0, 0),

-- Emotions & daily life
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Hôm nay vui quá! Cuối cùng cũng xong deadline 🎉', 'PUBLIC', NOW() - INTERVAL '49 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Mệt mỏi vcl, cần một chuyến du lịch gấp 😫', 'PUBLIC', NOW() - INTERVAL '48 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Thứ 2 buồn quá mọi người ơi 😢', 'PUBLIC', NOW() - INTERVAL '47 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Cuộc sống đẹp lắm, cứ lạc quan lên nha! ☀️', 'PUBLIC', NOW() - INTERVAL '46 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Stress quá đi uống bia cho nó chiii 🍺', 'PUBLIC', NOW() - INTERVAL '45 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Sáng nay ngủ dậy cảm thấy tràn đầy năng lượng 💪', 'PUBLIC', NOW() - INTERVAL '44 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Ai cũng có những ngày tồi tệ, không sao đâu 💚', 'PUBLIC', NOW() - INTERVAL '43 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Tối nay mưa to quá, ở nhà xem phim thôi 🌧️', 'PUBLIC', NOW() - INTERVAL '42 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'TGIF! Weekend đến rồi các bạn ơiiii 🎊', 'PUBLIC', NOW() - INTERVAL '41 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Hôm nay tâm trạng không ổn lắm...', 'PUBLIC', NOW() - INTERVAL '40 days', 0, 0, 0),

-- Food & travel  
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Phở sáng nay ngon không tưởng! 🍜❤️', 'PUBLIC', NOW() - INTERVAL '39 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Ai biết quán bún bò Huế nào ngon ở Hà Nội không?', 'PUBLIC', NOW() - INTERVAL '38 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Vừa về từ Đà Lạt, view đẹp muốn xỉu 😍🌲', 'PUBLIC', NOW() - INTERVAL '37 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Weekend này đi Hạ Long các bạn nhaaaa ⛵', 'PUBLIC', NOW() - INTERVAL '36 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Bánh mì Sài Gòn không ai sánh được luôn 🥖', 'PUBLIC', NOW() - INTERVAL '35 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Cà phê sữa đá = happiness 😌☕', 'PUBLIC', NOW() - INTERVAL '34 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Planning chuyến đi Phú Quốc tháng sau! 🏖️', 'PUBLIC', NOW() - INTERVAL '33 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Lần đầu ăn sushi tươi ngon vậy! 🍣', 'PUBLIC', NOW() - INTERVAL '32 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Hội An đẹp quá trời quá đất luôn 🏮', 'PUBLIC', NOW() - INTERVAL '31 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Thèm ăn bún chả Hà Nội ghê 🤤', 'PUBLIC', NOW() - INTERVAL '30 days', 0, 0, 0),

-- Hobbies & interests
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Vừa hoàn thành marathon 21km! Proud of myself 🏃‍♂️', 'PUBLIC', NOW() - INTERVAL '29 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Gaming all night, ai chơi VALORANT không? 🎮', 'PUBLIC', NOW() - INTERVAL '28 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Học guitar được 3 tháng rồi, cảm giác tuyệt vời 🎸', 'PUBLIC', NOW() - INTERVAL '27 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Yoga buổi sáng là best way to start the day 🧘', 'PUBLIC', NOW() - INTERVAL '26 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Vẽ tranh mà thấy relax quá đi 🎨', 'PUBLIC', NOW() - INTERVAL '25 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Ai làm handmade với mình không nhỉ? ✂️', 'PUBLIC', NOW() - INTERVAL '24 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Đọc xong quyển sách tuyệt vời! 📖✨', 'PUBLIC', NOW() - INTERVAL '23 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Hôm nay luyện boxing, người hơi mỏi 🥊', 'PUBLIC', NOW() - INTERVAL '22 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Chụp ảnh street photography cực kỳ ghiền 📷', 'PUBLIC', NOW() - INTERVAL '21 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Tối nay đi xem concert ai cùng không? 🎵', 'PUBLIC', NOW() - INTERVAL '20 days', 0, 0, 0),

-- Work & career
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Lương tháng này về rồi! Đi shopping thôi 💸', 'PUBLIC', NOW() - INTERVAL '19 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Làm việc remote rất thoải mái nhưng cũng cô đơn 💻', 'PUBLIC', NOW() - INTERVAL '18 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Vừa pass phỏng vấn company mơ ước! 🎉', 'PUBLIC', NOW() - INTERVAL '17 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Thứ 2 với meeting là một 😩', 'PUBLIC', NOW() - INTERVAL '16 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Làm freelancer vui nhưng không stable lắm', 'PUBLIC', NOW() - INTERVAL '15 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Đang nghiền ngẫm chuyện lập startup 🚀', 'PUBLIC', NOW() - INTERVAL '14 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Code cả ngày mà bug không hết 😤', 'PUBLIC', NOW() - INTERVAL '13 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Được tăng lương rồi nha mọi người! 📈', 'PUBLIC', NOW() - INTERVAL '12 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Project launch thành công! Team mình quá đỉnh 👏', 'PUBLIC', NOW() - INTERVAL '11 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Nghỉ phép 1 tuần, chill thôi! 🏝️', 'PUBLIC', NOW() - INTERVAL '10 days', 0, 0, 0),

-- Personal opinions & thoughts
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Sống ở Hà Nội hay Sài Gòn tốt hơn nhỉ? 🤔', 'PUBLIC', NOW() - INTERVAL '9 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Thức khuya nhiều không tốt cho sức khỏe í 😴', 'PUBLIC', NOW() - INTERVAL '8 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Tự nấu ăn tiết kiệm và healthy hơn ăn ngoài nhiều', 'PUBLIC', NOW() - INTERVAL '7 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Mọi người nghĩ sao về việc kết hôn trước 30 tuổi?', 'PUBLIC', NOW() - INTERVAL '6 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Sống tối giản giúp mình hạnh phúc hơn nhiều ✨', 'PUBLIC', NOW() - INTERVAL '5 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Tập thể dục mỗi sáng là thói quen tốt nhất! 🏃', 'PUBLIC', NOW() - INTERVAL '4 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Đi du lịch một mình cũng rất tuyệt vời đấy 🌍', 'PUBLIC', NOW() - INTERVAL '3 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Học tiếng Anh mỗi ngày để improve bản thân 📚', 'PUBLIC', NOW() - INTERVAL '2 days', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Muốn nuôi chó nhưng chưa sẵn sàng trách nhiệm 🐕', 'PUBLIC', NOW() - INTERVAL '1 day', 0, 0, 0),
(gen_random_uuid(), (SELECT id FROM users ORDER BY random() LIMIT 1), 'Thời tiết Sài Gòn nóng quá chịu không nổi 🥵', 'PUBLIC', NOW() - INTERVAL '12 hours', 0, 0, 0);

-- Fill remaining posts to reach 350+ total
DO $$
DECLARE
    v_user_id UUID;
    v_content TEXT;
    v_days_ago INTEGER;
    v_counter INTEGER := 0;
    content_array TEXT[] := ARRAY[
        'Hôm nay thật sự là một ngày đẹp trời! ☀️',
        'Ai muốn đi cafe cùng mình không nhỉ? ☕',
        'Tối nay rảnh quá, chill ở nhà xem Netflix 📺',
        'Weekend này ai đi chơi không ta? 🎉',
        'Đang tìm người cùng sở thích photography 📸',
        'Mệt quá mọi người ơi, cần ngủ ngay 😴',
        'Happy hour! Ai đi uống bia không? 🍻',
        'Tìm bạn đi leo núi cuối tuần này! ⛰️',
        'Hôm nay tập luyện vất vả nhưng cảm thấy tuyệt 💪',
        'Quán cơm tấm này ngon lắm, ai thử chưa? 🍛',
        'Đang học nấu ăn, các tip nào hay không? 👩‍🍳',
        'Sài Gòn ban đêm đẹp vô cùng luôn 🌃',
        'Ai thích nhạc indie như mình không? 🎵',
        'Weekend đi Vũng Tàu ngắm biển thôi 🌊',
        'Cần motivation để thức dậy sớm nè 😅',
        'Tối nay có ai đi chạy bộ công viên không? 🏃‍♀️',
        'Đọc sách mỗi ngày giúp mình grow rất nhiều 📖',
        'Ai chơi tennis với mình không nhỉ? 🎾',
        'Hôm nay làm việc hiệu quả quá đi! 🚀',
        'Thèm phở Hà Nội ghê, ai biết quán nào ngon? 🍜',
        'Mới về từ gym, thấy người nhẹ nhàng hơn 🏋️',
        'Tìm người cùng học tiếng Nhật nè! 🇯🇵',
        'Ai thích đi bar vào tối thứ 6 không? 🍸',
        'Hôm nay cực kỳ productive! ✅',
        'Đang chill tại quán cafe iu thích ☕❤️',
        'Tối nay karaoke các bạn nhaa! 🎤',
        'Muốn đi Nhật lắm á, ai đã đi chưa? 🇯🇵',
        'Thứ 2 này năng lượng tốt lắm! 💯',
        'Ai biết quán lẩu nào ngon giá hợp lý không? 🍲',
        'Weekend đi picnic Ecopark nha! 🧺',
        'Hôm nay tâm trạng tốt vô cùng! 😊',
        'Đang nghiền ngẫm về cuộc sống... 🤔',
        'Tối nay xem phim kinh dị ai cùng không? 👻',
        'Học piano được 6 tháng rồi! 🎹',
        'Ai thích chụp ảnh vintage như mình không? 📷',
        'Hôm nay chạy được 5km nè! 🏃',
        'Tìm người đi trekking Sapa tháng sau 🏔️',
        'Quán trà sữa mới này ngon lắm luôn! 🧋',
        'Ai học marketing cùng mình không? 📊',
        'Weekend này stay home và relax thôi 🛋️'
    ];
BEGIN
    WHILE v_counter < 290 LOOP
        SELECT id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
        v_days_ago := floor(random() * 60)::INTEGER;
        v_content := content_array[1 + floor(random() * array_length(content_array, 1))::INTEGER];
        
        INSERT INTO posts (id, author_id, content, visibility, created_at, like_count, comment_count, version)
        VALUES (
            gen_random_uuid(),
            v_user_id,
            v_content,
            'PUBLIC',
            NOW() - (v_days_ago || ' days')::INTERVAL - (floor(random() * 24)::INTEGER || ' hours')::INTERVAL,
            0,
            0,
            0
        );
        
        v_counter := v_counter + 1;
    END LOOP;
END $$;

-- Generate likes: ensure each user likes >= 5 posts
DO $$
DECLARE
    v_user RECORD;
    v_post RECORD;
    v_like_count INTEGER;
    v_counter INTEGER;
BEGIN
    FOR v_user IN SELECT id FROM users LOOP
        v_like_count := 5 + floor(random() * 15)::INTEGER;
        v_counter := 0;
        
        FOR v_post IN 
            SELECT id FROM posts 
            WHERE author_id != v_user.id 
            ORDER BY random() 
            LIMIT v_like_count
        LOOP
            INSERT INTO post_likes (id, post_id, user_id, created_at, version)
            VALUES (
                gen_random_uuid(),
                v_post.id,
                v_user.id,
                NOW() - (floor(random() * 50)::INTEGER || ' days')::INTERVAL,
                0
            )
            ON CONFLICT (post_id, user_id) DO NOTHING;
            
            v_counter := v_counter + 1;
        END LOOP;
    END LOOP;
END $$;

-- Update like_count in posts
UPDATE posts p
SET like_count = (
    SELECT COUNT(*)
    FROM post_likes pl
    WHERE pl.post_id = p.id
);

-- Generate comments: ~200-300 comments
DO $$
DECLARE
    v_post RECORD;
    v_user_id UUID;
    v_comment_count INTEGER;
    v_counter INTEGER;
    comment_array TEXT[] := ARRAY[
        'Đúng vậy luôn!',
        'Mình cũng nghĩ thế nè',
        'Hay quá á!',
        'Đồng ý với bạn!',
        'Mình cũng muốn thử',
        'Chính xác!',
        'Chia sẻ hay lắm',
        'Cảm ơn bạn đã share',
        'Mình cũng thích lắm',
        'Quá tuyệt vời!',
        'Nghe hay ghê',
        'Mình cũng vậy á',
        'Đỉnh quá!',
        'Muốn đi cùng quá',
        'Inbox mình nha',
        'Đi chung nha!',
        'Mình cũng đang tìm người đi',
        'Hay lắm bạn ơi',
        'Thật không?',
        'Wow amazing!',
        'Chill vậy',
        'Buồn cười ghê',
        'Đồng cảm quá',
        'Mình cũng thế á',
        'Hay thật đó'
    ];
BEGIN
    FOR v_post IN SELECT id FROM posts ORDER BY random() LIMIT 250 LOOP
        v_comment_count := 1 + floor(random() * 3)::INTEGER;
        v_counter := 0;
        
        WHILE v_counter < v_comment_count LOOP
            SELECT id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
            
            INSERT INTO post_comments (id, post_id, author_id, content, created_at, version)
            VALUES (
                gen_random_uuid(),
                v_post.id,
                v_user_id,
                comment_array[1 + floor(random() * array_length(comment_array, 1))::INTEGER],
                NOW() - (floor(random() * 50)::INTEGER || ' days')::INTERVAL - (floor(random() * 24)::INTEGER || ' hours')::INTERVAL,
                0
            );
            
            v_counter := v_counter + 1;
        END LOOP;
    END LOOP;
END $$;

-- Update comment_count in posts
UPDATE posts p
SET comment_count = (
    SELECT COUNT(*)
    FROM post_comments pc
    WHERE pc.post_id = p.id
);

COMMIT;

-- Final summary
SELECT 
    (SELECT COUNT(*) FROM users) as users,
    (SELECT COUNT(*) FROM posts) as posts,
    (SELECT COUNT(*) FROM post_likes) as likes,
    (SELECT COUNT(*) FROM post_comments) as comments;
