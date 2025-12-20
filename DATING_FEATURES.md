# 💕 Tài Liệu Chức Năng Dating - Fyn App

## 📋 Mục Lục
1. [Tổng Quan](#tổng-quan)
2. [Hệ Thống Swipe & Matching](#hệ-thống-swipe--matching)
3. [AI Recommendations](#ai-recommendations)
4. [Date Planning](#date-planning)
5. [Meetup System](#meetup-system)
6. [Video Call Integration](#video-call-integration)
7. [API Endpoints](#api-endpoints)
8. [Database Schema](#database-schema)
9. [Frontend Implementation](#frontend-implementation)

---

## 1. Tổng Quan

Fyn là ứng dụng hẹn hò và kết nối xã hội với các tính năng dating hiện đại:

### Công Nghệ Sử Dụng
**Backend:**
- Spring Boot 3.5.7 (Java 21)
- PostgreSQL với PostGIS (location-based features)
- HuggingFace AI (smart matching)
- WebSocket (real-time communication)
- MinIO (object storage)

**Frontend:**
- Flutter 3.x
- Riverpod (state management)
- GoRouter (navigation)
- WebRTC (video calls)

---

## 2. Hệ Thống Swipe & Matching

### 2.1. Cơ Chế Hoạt Động

#### A. Swipe Types
```java
enum SwipeType {
    LIKE,       // Thích người này
    DISLIKE,    // Không thích
    SUPERLIKE   // Thích đặc biệt (có thể tốn phí)
}
```

#### B. Quy Trình Match (Mutual Matching)

```
Bước 1: User A swipes RIGHT (LIKE) on User B
  ↓
  Lưu SwipeAction vào DB: {actor: A, target: B, type: LIKE}
  Kiểm tra: B đã LIKE A chưa? → NO
  → Response: {isMatch: false}

Bước 2: User B swipes RIGHT (LIKE) on User A
  ↓
  Lưu SwipeAction vào DB: {actor: B, target: A, type: LIKE}
  Kiểm tra: A đã LIKE B chưa? → YES ✅
  → Tạo Connection: {requester: B, receiver: A, status: ACCEPTED}
  → Response: {isMatch: true, message: "It's a match! 🎉"}

Kết quả:
  - Cả A và B thấy nhau trong tab "Matches"
  - Có thể chat với nhau
  - Có thể tạo date plan
```

### 2.2. API Endpoints

#### Discover Profiles
```http
GET /api/v1/matches/discover?page=0&size=20&connectionType=DATING
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "uuid",
        "username": "username",
        "fullName": "Nguyễn Văn A",
        "age": 25,
        "bio": "Mô tả bản thân...",
        "avatarUrl": "https://minio-url/avatar.jpg",
        "photos": ["photo1.jpg", "photo2.jpg"],
        "interests": ["Du lịch", "Âm nhạc", "Thể thao"],
        "distance": 5.2,  // km
        "matchScore": 0.85  // AI-based compatibility
      }
    ],
    "totalElements": 100,
    "page": 0,
    "size": 20
  }
}
```

**Logic Lọc:**
- Loại trừ chính mình
- Loại trừ người đã swipe (để không lặp lại)
- Loại trừ người bị block
- Sắp xếp theo: AI match score, distance, hoặc random

#### Swipe Action
```http
POST /api/v1/matches/swipe
Content-Type: application/json
Authorization: Bearer <token>

{
  "targetUserId": "uuid",
  "swipeType": "LIKE"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "isMatch": true,
    "match": {
      "id": "match-uuid",
      "user": {
        "id": "uuid",
        "username": "matched_user",
        "avatarUrl": "...",
        "fullName": "Trần Thị B"
      },
      "matchedAt": "2024-12-20T10:30:00Z",
      "matchScore": 0.85
    }
  }
}
```

#### Get Matches
```http
GET /api/v1/matches?status=matched&page=0&size=20
Authorization: Bearer <token>
```

**Filters:**
- `matched` - ACCEPTED connections (đã match)
- `completed` - COMPLETED (đã hoàn thành cuộc hẹn)
- `cancelled` - CANCELLED (đã hủy)
- `noshow` - NO_SHOW (không xuất hiện)

#### Undo Last Swipe
```http
DELETE /api/v1/matches/swipe/undo
Authorization: Bearer <token>
```

**Logic:**
1. Tìm SwipeAction gần nhất của user
2. Xóa SwipeAction đó
3. Nếu đã tạo match → Xóa luôn Connection
4. Profile sẽ xuất hiện lại trong discover

### 2.3. Match Management

#### Cancel Match
```http
PATCH /api/v1/matches/{matchId}/cancel
Authorization: Bearer <token>
```

#### Complete Match
```http
PATCH /api/v1/matches/{matchId}/complete
Authorization: Bearer <token>
```

#### Report No-Show
```http
PATCH /api/v1/matches/{matchId}/no-show
Authorization: Bearer <token>
```

**Penalty System:**
- Khi user bị report no-show: `-10 reputation score`
- Reputation score thấp → Xuất hiện ít hơn trong discover

#### Block Match
```http
PATCH /api/v1/matches/{matchId}/block
Authorization: Bearer <token>
```

---

## 3. AI Recommendations

### 3.1. HuggingFace Embedding Service

**Model:** `sentence-transformers/all-MiniLM-L6-v2`
- Tạo vector 384 chiều từ text
- Sử dụng để tính toán độ tương đồng giữa users

#### Code Logic
```java
@Service
public class HuggingFaceEmbeddingService {
    
    /**
     * Generate embedding for user profile
     * Combines: bio + interests + location
     */
    public float[] getEmbedding(String text) {
        // POST to HuggingFace API: /models/{model}/pipeline/feature-extraction
        // Returns: 384-dimensional float array
    }
    
    /**
     * Batch generate embeddings
     */
    public List<float[]> getEmbeddings(List<String> texts) {
        // Batch processing for efficiency
    }
}
```

### 3.2. AI Recommendation Logic

```java
// Tính match score giữa 2 users
float matchScore = calculateCosineSimilarity(
    userA.profileEmbedding,  // [384 floats]
    userB.profileEmbedding   // [384 floats]
);

// matchScore = 0.0 → 1.0
// 0.0: Hoàn toàn khác biệt
// 1.0: Rất giống nhau
```

### 3.3. Profile Embedding Generation

**Khi nào tạo embedding:**
- User đăng ký mới
- User cập nhật profile (bio, interests)
- Chạy background job định kỳ

**Text input cho embedding:**
```
Bio: "Tôi thích du lịch, đọc sách và khám phá món ăn mới"
Interests: ["Du lịch", "Đọc sách", "Ẩm thực", "Nhiếp ảnh"]
Location: "Hà Nội"

→ Combined: "Du lịch Đọc sách Ẩm thực Nhiếp ảnh. Tôi thích du lịch, đọc 
            sách và khám phá món ăn mới. Location: Hà Nội"
```

---

## 4. Date Planning

### 4.1. Tạo Date Plan

Date Plan là kế hoạch hẹn hò có thể:
- **Private:** Chỉ giữa 2 người đã match
- **Public:** Công khai để nhiều người propose tham gia

#### Create Date
```http
POST /api/v1/dates
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Cafe Sáng Cuối Tuần",
  "description": "Cùng nhau uống cafe và trò chuyện",
  "location": "The Coffee House, Hai Bà Trưng, Hà Nội",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "scheduledAt": "2024-12-25T09:00:00+07:00",
  "type": "PUBLIC",  // hoặc "PRIVATE"
  "connectionType": "DATING",
  "participantLimit": 2
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "date-uuid",
    "owner": {
      "id": "uuid",
      "username": "owner_user",
      "avatarUrl": "..."
    },
    "title": "Cafe Sáng Cuối Tuần",
    "location": "The Coffee House...",
    "scheduledAt": "2024-12-25T09:00:00+07:00",
    "status": "PENDING",
    "proposalCount": 0,
    "type": "PUBLIC"
  }
}
```

### 4.2. Date Statuses

```java
enum DateStatus {
    PENDING,      // Chờ người tham gia/chấp nhận
    CONFIRMED,    // Đã xác nhận
    COMPLETED,    // Đã hoàn thành
    CANCELLED     // Đã hủy
}
```

### 4.3. Public Date Marketplace

#### Browse Public Dates
```http
GET /api/v1/dates/public?type=DATING&page=0&size=20
Authorization: Bearer <token>
```

**Response:** Danh sách date plans công khai

#### Send Proposal
```http
POST /api/v1/dates/{dateId}/proposals
Content-Type: application/json
Authorization: Bearer <token>

{
  "message": "Hi! Mình cũng rất thích cafe. Có thể tham gia không?"
}
```

#### Get Proposals (Owner Only)
```http
GET /api/v1/dates/{dateId}/proposals
Authorization: Bearer <token>
```

#### Accept/Reject Proposal
```http
POST /api/v1/dates/proposals/{proposalId}/accept
POST /api/v1/dates/proposals/{proposalId}/reject
Authorization: Bearer <token>
```

**Acceptance Flow:**
```
1. User A tạo public date
2. User B, C, D gửi proposals
3. User A xem proposals → chọn User B
4. User A accept proposal của B
   → DateStatus = CONFIRMED
   → Tự động tạo Connection giữa A & B (nếu chưa có)
5. User C, D proposals tự động bị reject
```

### 4.4. My Dates
```http
GET /api/v1/dates/my?status=PENDING&page=0&size=20
Authorization: Bearer <token>
```

**Filters:**
- `PENDING` - Đang chờ
- `CONFIRMED` - Đã xác nhận
- `COMPLETED` - Đã hoàn thành
- `CANCELLED` - Đã hủy

### 4.5. Cancel/Complete Date
```http
PATCH /api/v1/dates/{dateId}/cancel
PATCH /api/v1/dates/{dateId}/complete
Authorization: Bearer <token>
```

---

## 5. Meetup System

Meetup là buổi gặp mặt nhóm (group dating):

### 5.1. Create Meetup
```http
POST /api/v1/meetups
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Hiking Trip - Tam Đảo",
  "description": "Cùng leo núi và khám phá thiên nhiên",
  "category": "OUTDOOR",
  "location": "Tam Đảo, Vĩnh Phúc",
  "latitude": 21.4619,
  "longitude": 105.6394,
  "scheduledAt": "2024-12-30T07:00:00+07:00",
  "maxParticipants": 10
}
```

### 5.2. Meetup Categories
- `OUTDOOR` - Ngoài trời (hiking, picnic)
- `FOOD` - Ẩm thực (food tours, cooking)
- `SPORTS` - Thể thao (badminton, football)
- `CULTURE` - Văn hóa (museum, concerts)
- `SOCIAL` - Xã hội (language exchange, networking)

### 5.3. Meetup Statuses
```java
enum MeetupStatus {
    OPEN,       // Đang mở đăng ký
    FULL,       // Đã đủ người
    CANCELLED,  // Đã hủy
    COMPLETED   // Đã hoàn thành
}
```

### 5.4. Browse Meetups
```http
GET /api/v1/meetups?category=OUTDOOR&page=0&size=20
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "meetup-uuid",
        "title": "Hiking Trip - Tam Đảo",
        "category": "OUTDOOR",
        "location": "Tam Đảo, Vĩnh Phúc",
        "scheduledAt": "2024-12-30T07:00:00+07:00",
        "maxParticipants": 10,
        "participantCount": 7,
        "spotsLeft": 3,
        "status": "OPEN",
        "organizer": {
          "id": "uuid",
          "username": "organizer",
          "avatarUrl": "..."
        },
        "participants": [
          {"id": "...", "username": "user1", "avatarUrl": "..."},
          {"id": "...", "username": "user2", "avatarUrl": "..."}
        ]
      }
    ]
  }
}
```

### 5.5. Join/Leave Meetup
```http
POST /api/v1/meetups/{meetupId}/join
DELETE /api/v1/meetups/{meetupId}/leave
Authorization: Bearer <token>
```

**Auto Status Update:**
- Khi đủ người (participantCount == maxParticipants) → status = FULL
- Khi có người leave → status = OPEN (nếu đang FULL)

### 5.6. Cancel Meetup (Organizer Only)
```http
DELETE /api/v1/meetups/{meetupId}
Authorization: Bearer <token>
```

---

## 6. Video Call Integration

### 6.1. Technology Stack
- **WebRTC** - Peer-to-peer video/audio
- **Firebase Firestore** - Signaling server
- **STUN/TURN** - NAT traversal

### 6.2. Call Flow
```
User A                    Firebase Firestore              User B
  |                                                          |
  |--Create Call Offer----→                                 |
  |  (ICE candidates)                                        |
  |                                                          |
  |                        ←----Listen for Call-------------→|
  |                                                          |
  |                        ←----Send Answer-----------------→|
  |                            (ICE candidates)              |
  |                                                          |
  |←-----------------WebRTC P2P Connection-----------------→|
  |                     (Direct video/audio)                 |
```

### 6.3. Frontend Implementation
```dart
// Start video call
final callService = ref.read(videoCallServiceProvider);
await callService.makeCall(
  callerId: currentUserId,
  receiverId: matchedUserId,
);

// Navigate to call screen
context.push('/video-call/${callId}');
```

---

## 7. API Endpoints Summary

### Matching
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/matches/discover` | Lấy danh sách profiles để swipe |
| POST | `/api/v1/matches/swipe` | Swipe LIKE/DISLIKE/SUPERLIKE |
| DELETE | `/api/v1/matches/swipe/undo` | Undo swipe gần nhất |
| GET | `/api/v1/matches` | Lấy danh sách matches |
| PATCH | `/api/v1/matches/{id}/cancel` | Hủy match |
| PATCH | `/api/v1/matches/{id}/complete` | Hoàn thành match |
| PATCH | `/api/v1/matches/{id}/no-show` | Report no-show |
| PATCH | `/api/v1/matches/{id}/block` | Block user |

### Date Planning
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/dates` | Tạo date plan mới |
| GET | `/api/v1/dates/public` | Browse public dates |
| GET | `/api/v1/dates/my` | Lấy date plans của mình |
| GET | `/api/v1/dates/{id}` | Chi tiết date |
| PATCH | `/api/v1/dates/{id}/cancel` | Hủy date |
| PATCH | `/api/v1/dates/{id}/complete` | Hoàn thành date |
| POST | `/api/v1/dates/{id}/proposals` | Gửi proposal |
| GET | `/api/v1/dates/{id}/proposals` | Xem proposals (owner) |
| POST | `/api/v1/dates/proposals/{id}/accept` | Chấp nhận proposal |
| POST | `/api/v1/dates/proposals/{id}/reject` | Từ chối proposal |

### Meetups
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/meetups` | Tạo meetup |
| GET | `/api/v1/meetups` | Browse meetups |
| GET | `/api/v1/meetups/{id}` | Chi tiết meetup |
| POST | `/api/v1/meetups/{id}/join` | Tham gia meetup |
| DELETE | `/api/v1/meetups/{id}/leave` | Rời meetup |
| DELETE | `/api/v1/meetups/{id}` | Hủy meetup (organizer) |

---

## 8. Database Schema

### swipe_actions
```sql
CREATE TABLE swipe_actions (
    id UUID PRIMARY KEY,
    actor_id UUID NOT NULL REFERENCES users(id),
    target_id UUID NOT NULL REFERENCES users(id),
    action_type VARCHAR(20) NOT NULL, -- LIKE, DISLIKE, SUPERLIKE
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(actor_id, target_id)  -- Mỗi user chỉ swipe 1 lần
);

CREATE INDEX idx_swipe_target ON swipe_actions(target_id, action_type);
CREATE INDEX idx_swipe_actor ON swipe_actions(actor_id, created_at DESC);
```

### connections
```sql
CREATE TABLE connections (
    id UUID PRIMARY KEY,
    requester_id UUID NOT NULL REFERENCES users(id),
    receiver_id UUID NOT NULL REFERENCES users(id),
    connection_type VARCHAR(20) NOT NULL,  -- FRIEND, DATING
    status VARCHAR(20) NOT NULL,           -- ACCEPTED, CANCELLED, COMPLETED, NO_SHOW
    match_source VARCHAR(20),              -- SWIPE, MANUAL
    match_score DECIMAL(3,2),              -- AI match score (0.00 - 1.00)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(requester_id, receiver_id)
);

CREATE INDEX idx_conn_requester ON connections(requester_id, status);
CREATE INDEX idx_conn_receiver ON connections(receiver_id, status);
```

### date_plans
```sql
CREATE TABLE date_plans (
    id UUID PRIMARY KEY,
    owner_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(500),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    type VARCHAR(20) NOT NULL,             -- PUBLIC, PRIVATE
    connection_type VARCHAR(20) NOT NULL,  -- DATING, FRIEND
    participant_limit INTEGER DEFAULT 2,
    status VARCHAR(20) NOT NULL,           -- PENDING, CONFIRMED, COMPLETED, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_date_status ON date_plans(status, scheduled_at);
CREATE INDEX idx_date_owner ON date_plans(owner_id);
```

### date_proposals
```sql
CREATE TABLE date_proposals (
    id UUID PRIMARY KEY,
    date_id UUID NOT NULL REFERENCES date_plans(id),
    proposer_id UUID NOT NULL REFERENCES users(id),
    message TEXT,
    status VARCHAR(20) NOT NULL,  -- PENDING, ACCEPTED, REJECTED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(date_id, proposer_id)
);
```

### meetups
```sql
CREATE TABLE meetups (
    id UUID PRIMARY KEY,
    organizer_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,  -- OUTDOOR, FOOD, SPORTS, CULTURE, SOCIAL
    location VARCHAR(500),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    max_participants INTEGER DEFAULT 10,
    status VARCHAR(20) NOT NULL,    -- OPEN, FULL, CANCELLED, COMPLETED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_meetup_status ON meetups(status, scheduled_at);
CREATE INDEX idx_meetup_category ON meetups(category, status);
```

### meetup_participants
```sql
CREATE TABLE meetup_participants (
    meetup_id UUID NOT NULL REFERENCES meetups(id),
    user_id UUID NOT NULL REFERENCES users(id),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    PRIMARY KEY (meetup_id, user_id)
);
```

---

## 9. Frontend Implementation

### 9.1. Discover Screen (Swipe Cards)

**File:** `lib/features/connections/presentation/screens/discover_screen.dart`

**State Management:**
```dart
final discoverProvider = StateNotifierProvider<DiscoverNotifier, DiscoverState>(
  (ref) => DiscoverNotifier(ref.read(matchRepositoryProvider))
);

class DiscoverState {
  final List<UserProfile> profiles;
  final bool isLoading;
  final String? error;
  final int currentIndex;
}
```

**Swipe Logic:**
```dart
void onSwipe(SwipeDirection direction, UserProfile profile) {
  SwipeType type = direction == SwipeDirection.right 
      ? SwipeType.LIKE 
      : SwipeType.DISLIKE;
  
  // API call
  final result = await matchRepository.swipe(
    targetUserId: profile.id,
    swipeType: type,
  );
  
  if (result.isMatch) {
    // Show "It's a Match!" dialog
    showMatchDialog(context, profile);
  }
  
  // Load next profile
  state = state.copyWith(currentIndex: state.currentIndex + 1);
}
```

### 9.2. Matches Screen

**File:** `lib/features/connections/presentation/screens/matches_screen.dart`

**Filters:**
```dart
enum MatchFilter {
  all,
  matched,      // ACCEPTED
  completed,    // COMPLETED
  cancelled,    // CANCELLED
  noShow        // NO_SHOW
}
```

**Match Actions:**
```dart
void onCancelMatch(String matchId) async {
  await matchRepository.cancelMatch(matchId);
  _refreshMatches();
}

void onCompleteMatch(String matchId) async {
  await matchRepository.completeMatch(matchId);
  _refreshMatches();
}

void onReportNoShow(String matchId) async {
  await matchRepository.reportNoShow(matchId);
  _showPenaltyInfo();
}
```

### 9.3. Swipe Card Component

**File:** `lib/features/connections/presentation/widgets/swipe_card.dart`

**Features:**
- Smooth drag animations
- Auto-swipe on threshold
- Photo gallery swipe
- Info overlay
- Action buttons (like, dislike, superlike)

### 9.4. Video Call Screen

**File:** `lib/features/video_call/presentation/screens/video_call_screen.dart`

**WebRTC Setup:**
```dart
// Initialize RTCPeerConnection
final pc = await createPeerConnection(configuration);

// Add local stream
final localStream = await navigator.mediaDevices.getUserMedia({
  'audio': true,
  'video': {'facingMode': 'user'}
});
pc.addStream(localStream);

// Listen for remote stream
pc.onAddStream = (stream) {
  setState(() => remoteStream = stream);
};

// Handle ICE candidates
pc.onIceCandidate = (candidate) {
  firestore.collection('calls/$callId/candidates').add(candidate.toMap());
};
```

---

## 10. Tính Năng Nổi Bật

### ✅ Đã Hoàn Thành
1. **Swipe Matching** - Kiểu Tinder với AI recommendations
2. **Undo Swipe** - Hoàn tác swipe gần nhất
3. **Match Management** - Cancel, Complete, Report No-Show
4. **Date Planning** - Public/Private date plans với proposal system
5. **Meetup Groups** - Group dating với nhiều categories
6. **Video Calls** - 1-on-1 WebRTC calls
7. **Real-time Chat** - WebSocket messaging
8. **Location-based** - PostGIS để tìm người gần
9. **AI Matching** - HuggingFace embeddings
10. **Penalty System** - Reputation score cho no-shows

### 🚧 Có Thể Mở Rộng
1. **Verified Profiles** - Badge xác thực
2. **Premium Features** - Unlimited swipes, superlike
3. **Advanced Filters** - Age, distance, interests
4. **Story Reactions** - React vào story của match
5. **Voice Messages** - Tin nhắn thoại trong chat
6. **Live Streaming** - Group livestream trong meetup
7. **Gamification** - Points, badges, leaderboard
8. **Safety Features** - Photo verification, background check

---

## 11. Performance & Scalability

### Indexing Strategy
- Composite indexes cho queries phức tạp
- GiST index cho PostGIS location queries
- B-tree index cho UUID lookups

### Caching
- Redis cache cho:
  - User profiles (TTL: 1 hour)
  - Match results (TTL: 5 minutes)
  - AI embeddings (persistent)

### Pagination
- Tất cả list endpoints đều support pagination
- Default: page=0, size=20
- Max size: 100

---

## 📞 Liên Hệ & Đóng Góp

File này được tạo để document tất cả các tính năng Dating trong Fyn App.
Mọi thắc mắc hoặc đóng góp vui lòng tạo issue hoặc pull request.

**Ngày tạo:** 2024-12-20
**Phiên bản:** 1.0
