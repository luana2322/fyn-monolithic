# Fyn - Dating & Social Connection App

A full-stack dating and social connection application with a **Spring Boot** backend and **Flutter** mobile/web frontend.

## 🏗️ Project Structure

```
fyn-monolithic/
├── fyn-monolithic/         # Backend (Spring Boot / Java)
│   └── src/main/java/com/fyn_monolithic/
│       ├── config/         # App configuration (Security, WebSocket, MinIO, etc.)
│       ├── controller/     # REST API controllers
│       ├── dto/            # Data Transfer Objects (request/response)
│       ├── exception/      # Custom exceptions & handlers
│       ├── mapper/         # Entity-DTO mappers
│       ├── model/          # JPA entities
│       ├── repository/     # Data access layer (JPA repositories)
│       ├── security/       # JWT auth, user details
│       ├── service/        # Business logic
│       └── util/           # Utility classes
│
├── fyn-flutter-app/        # Frontend (Flutter / Dart)
│   └── lib/
│       ├── config/         # App configuration
│       ├── core/           # Network client, utilities
│       ├── features/       # Feature modules
│       │   ├── auth/       # Authentication (login, register)
│       │   ├── connections/# Matching & swiping (Tinder-like)
│       │   ├── events/     # Events management
│       │   ├── message/    # Real-time chat
│       │   ├── notification/# Push notifications
│       │   ├── post/       # Social feed / posts
│       │   ├── search/     # User search
│       │   ├── story/      # Stories (24h content)
│       │   ├── user/       # Profile management
│       │   └── video_call/ # 1-on-1 video calls
│       ├── shared/         # Shared widgets & providers
│       └── theme/          # App theme & styling
│
└── docs/                   # Documentation
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **🔐 Authentication** | JWT-based login/register with refresh tokens |
| **💕 Matching** | Tinder-like swipe cards (like/dislike/superlike) |
| **💬 Messaging** | Real-time chat via WebSocket |
| **📹 Video Call** | 1-on-1 video calls (WebRTC) |
| **📝 Posts** | Social feed with likes, comments |
| **📖 Stories** | 24-hour ephemeral content |
| **🎉 Events** | Create and join events |
| **🔍 Search** | Find users by interests, location |
| **🔔 Notifications** | Push notifications |
| **👤 Profiles** | User profiles with photos, bio, interests |

---

## 🛠️ Tech Stack

### Backend
- **Java 17** + **Spring Boot 3**
- **PostgreSQL** (with PostGIS for location)
- **MinIO** (S3-compatible object storage)
- **WebSocket** (STOMP for real-time messaging)
- **JWT** (authentication)
- **Flyway** (database migrations)
- **Docker Compose** (local development)

### Frontend
- **Flutter 3** (Dart)
- **Riverpod** (state management)
- **GoRouter** (navigation)
- **Dio** (HTTP client)
- **WebSocket** (real-time)

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 17+
- Flutter SDK 3.x

### Backend

```bash
# Start infrastructure (PostgreSQL, MinIO, Redis)
cd fyn-monolithic
docker-compose up -d

# Run the backend
./gradlew bootRun
```

Backend runs at: `http://localhost:8080`

### Frontend

```bash
cd fyn-flutter-app

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android
```

---

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | Login |
| POST | `/api/v1/auth/refresh` | Refresh token |

### Matching
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/matches/discover` | Get profiles to swipe |
| POST | `/api/v1/matches/swipe` | Like/dislike/superlike |
| GET | `/api/v1/matches` | Get user's matches |
| PATCH | `/api/v1/matches/{id}/block` | Block a match |
| PATCH | `/api/v1/matches/{id}/cancel` | Cancel a match |
| PATCH | `/api/v1/matches/{id}/complete` | Complete a match |
| PATCH | `/api/v1/matches/{id}/no-show` | Report no-show |

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users/me` | Get current user |
| PUT | `/api/v1/users/profile` | Update profile |
| POST | `/api/v1/users/avatar` | Upload avatar |

### Messages
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/conversations` | List conversations |
| GET | `/api/v1/conversations/{id}/messages` | Get messages |
| POST | `/api/v1/conversations/{id}/messages` | Send message |

### Posts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/posts` | Get feed |
| POST | `/api/v1/posts` | Create post |
| POST | `/api/v1/posts/{id}/like` | Like post |
| POST | `/api/v1/posts/{id}/comments` | Comment on post |

### Stories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/stories` | Get stories |
| POST | `/api/v1/stories` | Create story |

---

## 🗄️ Database Schema

Key entities:
- **users** - User accounts
- **user_profiles** - Extended profile data
- **connections** - Matches between users
- **swipe_actions** - Swipe history (like/dislike)
- **conversations** - Chat threads
- **messages** - Chat messages
- **posts** - Social feed posts
- **stories** - Ephemeral stories
- **events** - Events

---

## 📁 Key Files

### Backend
| File | Description |
|------|-------------|
| `MatchingController.java` | Match/swipe REST endpoints |
| `MatchingService.java` | Matching business logic |
| `Connection.java` | Connection entity (matches) |
| `MessageController.java` | Chat endpoints |
| `WebSocketConfig.java` | WebSocket configuration |

### Frontend
| File | Description |
|------|-------------|
| `discover_screen.dart` | Swipe cards UI |
| `matches_screen.dart` | Matches list |
| `match_model.dart` | Match data model |
| `match_repository.dart` | API calls for matching |
| `discover_provider.dart` | State management (Riverpod) |
| `chat_screen.dart` | Chat UI |

---

## � QUY TRÌNH TẠO MATCH (Matching Process)

### Tổng Quan
Hệ thống matching của Fyn hoạt động dựa trên cơ chế **swipe hai chiều** (mutual like). Match chỉ được tạo khi **cả hai người dùng đều thích nhau**.

---

### Bước 1: Khám Phá Người Dùng (User Discovery)

**Frontend:**
```dart
// User A mở màn hình Discover
GET /api/v1/matches/discover?page=0&size=20
```

**Backend Logic:**
```java
// MatchingService.getDiscoverProfiles()
1. Lấy danh sách tất cả người dùng đã swipe (liked/disliked)
2. Loại trừ:
   - Chính mình
   - Người đã swipe rồi (để không hiện lại)
   - Người bị block
3. Trả về danh sách profiles khả dụng
```

**Kết quả:** User A thấy User B trong danh sách discover

---

### Bước 2: User A Swipe Phải (Like) User B

**Frontend:**
```dart
// User A swipe phải trên User B
POST /api/v1/matches/swipe
{
  "targetUserId": "user-b-id",
  "swipeType": "LIKE"
}
```

**Backend Logic:**
```java
// MatchingService.swipe()

// B2.1: Kiểm tra hợp lệ
if (actorId.equals(targetId)) 
    throw "Cannot swipe on yourself"

// B2.2: Kiểm tra đã swipe chưa
if (swipeActionRepository.existsByActorIdAndTargetId(A, B))
    return false; // Đã swipe rồi

// B2.3: Lưu SwipeAction vào database
SwipeAction action = new SwipeAction();
action.setActor(User A);
action.setTarget(User B);
action.setActionType(LIKE);
swipeActionRepository.save(action);

// B2.4: Kiểm tra mutual like
boolean isMatch = swipeActionRepository.existsByActorIdAndTargetIdAndActionType(
    B, A, LIKE  // Kiểm tra B đã like A chưa?
);

if (isMatch) {
    _createMatch(A, B);  // Tạo match!
    return true;
} else {
    return false;  // Chưa match, chờ B swipe
}
```

**Database Changes:**
```sql
-- Bảng swipe_actions thêm 1 record mới
INSERT INTO swipe_actions (id, actor_id, target_id, action_type, created_at)
VALUES ('uuid', 'user-a-id', 'user-b-id', 'LIKE', NOW());
```

**Kết quả:** 
- ✅ SwipeAction được lưu
- ❌ Chưa có Connection (vì B chưa like A)
- 📱 User A nhận response: `{ "isMatch": false, "message": "Swipe recorded" }`

---

### Bước 3: User B Khám Phá User A

**Frontend:**
```dart
// User B mở màn hình Discover
GET /api/v1/matches/discover?page=0&size=20
```

**Backend:** User A xuất hiện trong danh sách của User B

---

### Bước 4: User B Swipe Phải (Like) User A ⭐

**Frontend:**
```dart
// User B swipe phải trên User A
POST /api/v1/matches/swipe
{
  "targetUserId": "user-a-id",
  "swipeType": "LIKE"
}
```

**Backend Logic:**
```java
// MatchingService.swipe()

// B4.1: Lưu SwipeAction
SwipeAction action = new SwipeAction();
action.setActor(User B);
action.setTarget(User A);
action.setActionType(LIKE);
swipeActionRepository.save(action);

// B4.2: Kiểm tra mutual like
boolean isMatch = swipeActionRepository.existsByActorIdAndTargetIdAndActionType(
    A, B, LIKE  // ✅ TRUE - A đã like B rồi!
);

if (isMatch) {
    _createMatch(B, A);  // 🎉 TẠO MATCH!
    return true;
}
```

**Backend - Tạo Connection:**
```java
// MatchingService._createMatch()

// B4.3: Kiểm tra Connection đã tồn tại chưa
if (connectionExists(A, B)) return;

// B4.4: Tạo Connection mới
Connection connection = new Connection();
connection.setRequester(User B);  // Người swipe sau
connection.setReceiver(User A);
connection.setConnectionType(FRIEND);
connection.setStatus(ACCEPTED);      // ⭐ Trạng thái ACCEPTED
connection.setMatchSource("SWIPE");  // ⭐ Nguồn từ swipe
connectionRepository.save(connection);
```

**Database Changes:**
```sql
-- Bảng swipe_actions: Thêm record thứ 2
INSERT INTO swipe_actions (id, actor_id, target_id, action_type, created_at)
VALUES ('uuid2', 'user-b-id', 'user-a-id', 'LIKE', NOW());

-- Bảng connections: Tạo match mới
INSERT INTO connections (
    id, 
    requester_id,   -- User B (người swipe sau)
    receiver_id,    -- User A
    connection_type,
    status,         -- ACCEPTED
    match_source,   -- SWIPE
    created_at
) VALUES (
    'uuid3',
    'user-b-id',
    'user-a-id',
    'FRIEND',
    'ACCEPTED',
    'SWIPE',
    NOW()
);
```

**Kết quả:**
- 📱 User B nhận response: `{ "isMatch": true, "message": "It's a match!" }`
- 🎉 UI hiển thị popup "It's a Match!"

---

### Bước 5: Xem Danh Sách Matches

**Frontend:**
```dart
// Cả User A và User B mở tab Matches
GET /api/v1/matches?status=matched&page=0&size=20
```

**Backend Logic:**
```java
// MatchingService.getMatches()

// B5.1: Lấy tất cả connections của user
List<Connection> allConnections = connectionRepository.findByUserIdWithUsers(userId);

// B5.2: Lọc connections
matches = allConnections.stream()
    .filter(c -> c.getStatus() == ACCEPTED)        // ✅ Chỉ lấy ACCEPTED
    .filter(c -> c.getMatchSource().equals("SWIPE")) // ✅ Chỉ lấy từ swipe
    .map(c -> getOtherUser(c, userId))             // Lấy user còn lại
    .collect(toList());

return matches;
```

**Kết quả:**
- ✅ User A thấy User B trong tab Matches
- ✅ User B thấy User A trong tab Matches
- 💬 Cả hai có thể chat với nhau
- 📅 Cả hai có thể tạo date plan

---

### Sơ Đồ Tổng Quan

```
User A                Database              User B
  |                                           |
  |--GET /discover--->                        |
  |<---[User B]-------                        |
  |                                           |
  |--POST /swipe----->                        |
  |  (LIKE User B)                            |
  |                   [swipe_actions]         |
  |                   + A likes B             |
  |<--{isMatch:false}-                        |
  |                                           |
  |                                    <---GET /discover---|
  |                                    ---[User A]-------->|
  |                                           |
  |                                    <---POST /swipe-----|
  |                                       (LIKE User A)
  |                   [swipe_actions]         |
  |                   + B likes A             |
  |                   CHECK: A likes B? ✅    |
  |                   [connections]           |
  |                   + CREATE MATCH          |
  |                   ---{isMatch:true}------>|
  |                                           |
  |                   🎉 IT'S A MATCH! 🎉     |
  |                                           |
  |--GET /matches---->                        |
  |<---[User B]-------                        |
  |                                    <---GET /matches----|
  |                                    ---[User A]-------->|
```

---

### Các Trường Hợp Đặc Biệt

#### 1. Swipe DISLIKE
```java
// Nếu User A swipe DISLIKE trên User B
swipeType = DISLIKE
→ Lưu SwipeAction nhưng KHÔNG kiểm tra match
→ User B sẽ không xuất hiện lại cho User A
→ Có thể undo bằng tính năng "Swipe Undo"
```

#### 2. Swipe SUPERLIKE
```java
// Giống LIKE nhưng đặc biệt hơn
swipeType = SUPERLIKE
→ Lưu SwipeAction với type SUPERLIKE
→ Vẫn kiểm tra mutual like (SUPERLIKE hoặc LIKE đều OK)
→ Có thể tạo match với cả LIKE và SUPERLIKE
```

#### 3. Undo Swipe
```java
// User có thể undo swipe gần nhất
DELETE /api/v1/matches/swipe/undo

→ Xóa SwipeAction gần nhất
→ Nếu đã tạo match, xóa luôn Connection
→ Profile sẽ xuất hiện lại trong discover
```

---

### Database Schema

**swipe_actions:**
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| actor_id | UUID | Người swipe |
| target_id | UUID | Người bị swipe |
| action_type | ENUM | LIKE, DISLIKE, SUPERLIKE |
| created_at | TIMESTAMP | Thời gian swipe |

**connections:**
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| requester_id | UUID | Người gửi request (swipe sau) |
| receiver_id | UUID | Người nhận request |
| status | ENUM | **ACCEPTED** = có match |
| match_source | VARCHAR | **SWIPE** = từ swipe |
| connection_type | ENUM | FRIEND, DATING, etc. |
| created_at | TIMESTAMP | Thời gian tạo match |

---

### API Endpoints Chi Tiết

| Method | Endpoint | Request Body | Response | Mô tả |
|--------|----------|--------------|----------|-------|
| GET | `/api/v1/matches/discover` | - | `{ profiles: [...] }` | Lấy danh sách profiles để swipe |
| POST | `/api/v1/matches/swipe` | `{ targetUserId, swipeType }` | `{ isMatch: bool }` | Swipe trên user |
| DELETE | `/api/v1/matches/swipe/undo` | - | `{ success: bool }` | Undo swipe gần nhất |
| GET | `/api/v1/matches` | Query: `status` | `{ matches: [...] }` | Lấy danh sách matches |

---

## �📄 License

Private project. All rights reserved.
