# 📍 Vị Trí Chức Năng Chat trong Dự Án FYN

## 🎯 Tổng Quan

Chức năng chat (messaging) đã được implement đầy đủ trong cả **Backend (Spring Boot)** và **Frontend (Flutter)**.

---

## 🔧 BACKEND - Spring Boot

### 📂 Cấu trúc thư mục

```
fyn-monolithic/src/main/java/com/fyn_monolithic/
├── controller/message/
│   ├── ConversationController.java      # API tạo và list conversations
│   └── MessageController.java           # API gửi và nhận messages
├── service/message/
│   ├── ConversationService.java         # Logic xử lý conversations
│   └── MessageService.java              # Logic xử lý messages
├── model/message/
│   ├── Conversation.java                # Entity conversation
│   ├── ConversationMember.java          # Entity thành viên
│   ├── Message.java                     # Entity message
│   └── MessageMedia.java                # Entity media trong message
├── dto/request/message/
│   ├── CreateConversationRequest.java   # Request tạo conversation
│   └── SendMessageRequest.java          # Request gửi message
└── dto/response/message/
    ├── ConversationResponse.java        # Response conversation
    └── MessageResponse.java             # Response message
```

### 🌐 API Endpoints

**Conversations**
- `POST /api/conversations` - Tạo conversation mới
- `GET /api/conversations` - Lấy danh sách conversations

**Messages**  
- `POST /api/conversations/{conversationId}/messages` - Gửi message
- `GET /api/conversations/{conversationId}/messages` - Lấy messages

### 💾 Database Schema

**Table: `conversations`**
- `id` (UUID)
- `type` (VARCHAR) - DIRECT hoặc GROUP
- `title` (VARCHAR) - Tên nhóm (optional)
- `created_at`, `updated_at`

**Table: `conversation_members`**
- `id` (UUID)
- `conversation_id` (FK)
- `member_id` (FK to users)
- `is_admin` (BOOLEAN)

**Table: `messages`**
- `id` (UUID)
- `conversation_id` (FK)
- `sender_id` (FK to users)
- `content` (TEXT)
- `status` (VARCHAR) - SENT, DELIVERED, READ
- `created_at`, `updated_at`

**Table: `message_media`**
- `id` (UUID)
- `message_id` (FK)
- `object_key` (VARCHAR) - MinIO key
- `media_type` (VARCHAR)

---

## 📱 FRONTEND - Flutter

### 📂 Cấu trúc thư mục

```
fyn-flutter-app/lib/features/message/
├── data/
│   ├── models/
│   │   ├── conversation_model.dart      # Model conversation
│   │   ├── conversation_type.dart       # Enum DIRECT/GROUP
│   │   ├── message_model.dart           # Model message
│   │   ├── message_status.dart          # Enum SENT/DELIVERED/READ
│   │   ├── send_message_request.dart    # Request DTO
│   │   └── create_conversation_request.dart
│   └── repositories/
│       └── message_repository.dart      # API calls
├── domain/
│   └── message_service.dart             # Business logic
└── presentation/
    ├── providers/
    │   └── message_provider.dart        # State management (Riverpod)
    └── screens/
        ├── chat_list_screen.dart        # Màn hình danh sách chat
        ├── chat_detail_screen.dart      # Màn hình chi tiết chat
        └── select_user_to_chat_screen.dart  # Chọn user để chat
```

### 🗺️ Routing

Trong file [`app_config.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/config/app_config.dart#L92-L95):

```dart
GoRoute(
  path: '/chat',
  name: 'chat',
  builder: (context, state) => const ChatListScreen(),
),
```

**Cách truy cập:**
```dart
// Navigation
context.push('/chat');

// Hoặc
context.pushNamed('chat');
```

### 🎨 UI Screens

#### 1️⃣ ChatListScreen
**File:** [`chat_list_screen.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/presentation/screens/chat_list_screen.dart)

**Chức năng:**
- Hiển thị danh sách conversations
- Pull to refresh
- Hiển thị avatar, tên, message preview
- Tap để vào chat detail
- Button tạo chat mới

**Widgets chính:**
- `_ChatListScreenState` - State chính
- `_ConversationListItem` - Item trong list
- `SelectUserToChatScreen` - Màn hình chọn user

#### 2️⃣ ChatDetailScreen  
**File:** [`chat_detail_screen.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/presentation/screens/chat_detail_screen.dart)

**Chức năng:**
- Hiển thị messages theo conversation
- Gửi text message
- Gửi hình ảnh (image picker)
- Auto scroll to bottom
- Message bubbles (người gửi/nhận khác màu)
- Hiển thị avatar, timestamp

**Widgets chính:**
- `_ChatDetailScreenState` - State chính
- `_MessageBubble` - Bubble message
- Input area với TextField và buttons

---

## 🚀 Cách Sử Dụng

### Từ Backend

1. **Tạo conversation**
```bash
curl -X POST http://localhost:8080/api/conversations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "memberIds": ["user-id-1", "user-id-2"],
    "type": "DIRECT"
  }'
```

2. **Gửi message**
```bash
curl -X POST http://localhost:8080/api/conversations/{conversationId}/messages \
  -H "Authorization: Bearer <token>" \
  -F 'payload={"content":"Hello!"}' \
  -F 'media=@image.jpg'
```

### Từ Flutter App

1. **Mở danh sách chat**
   - Tap icon chat trên bottom navigation
   - Hoặc: `context.push('/chat')`

2. **Tạo chat mới**
   - Tap button "+" trên ChatListScreen
   - Chọn user từ danh sách
   - Conversation tự động tạo

3. **Gửi message**
   - Nhập text vào TextField
   - Tap send button
   - Hoặc tap image icon để gửi ảnh

---

## 🔄 State Management

Sử dụng **Riverpod** providers:

```dart
// Provider cho danh sách conversations
final conversationListProvider = 
  StateNotifierProvider<ConversationListNotifier, ConversationListState>(...);

// Provider cho messages trong conversation
final messageProvider = 
  StateNotifierProvider.family<MessageNotifier, MessageState, String>(...);

// Provider cho user search
final userSearchProvider = 
  FutureProvider.family<List<UserResponse>, String>(...);
```

---

## 🎯 Tính năng đã có

### ✅ Backend
- [x] Tạo conversation (DIRECT, GROUP)
- [x] Lấy danh sách conversations
- [x] Gửi text message
- [x] Gửi message với media (hình ảnh)
- [x] Lấy messages theo conversation
- [x] Pagination cho messages
- [x] Message status (SENT, DELIVERED, READ)
- [x] Conversation members management

### ✅ Frontend
- [x] Màn hình danh sách chat
- [x] Màn hình chi tiết chat
- [x] Chọn user để chat mới
- [x] Gửi text message
- [x] Gửi hình ảnh
- [x] Hiển thị message bubbles
- [x] Auto scroll to bottom
- [x] Pull to refresh
- [x] Loading states
- [x] Error handling

---

## 🚧 Tính năng có thể thêm (Optional)

### Backend
- [ ] Real-time với WebSocket
- [ ] Typing indicators
- [ ] Read receipts
- [ ] Delete messages
- [ ] Edit messages
- [ ] Message reactions (emoji)
- [ ] Push notifications

### Frontend  
- [ ] Real-time messaging (WebSocket)
- [ ] Typing indicator animation
- [ ] Online/offline status
- [ ] Message search
- [ ] Voice messages
- [ ] Video messages
- [ ] File sharing
- [ ] Group chat management UI
- [ ] Message reactions UI

---

## 📞 Navigation Flow

```
Feed/Profile/Anywhere
    ↓
[Tap Chat Icon]
    ↓
ChatListScreen (/chat)
    ↓
[Tap Conversation] ──────→ [Tap + Button]
    ↓                           ↓
ChatDetailScreen        SelectUserToChatScreen
    ↓                           ↓
[Send messages]         [Select user]
    ↑                           ↓
    └──────── [Auto create conversation]
```

---

## 💡 Tips

### Debugging
- Check backend logs: Messages API calls
- Check Flutter logs: `debugPrint()` trong providers
- Verify token authentication
- Check MinIO for uploaded media

### Performance
- Messages được cache trong Riverpod state
- Conversations được lazy load
- Media được load qua MinIO presigned URLs

### Testing
1. Tạo 2 accounts
2. Login với account 1
3. Tạo conversation với account 2  
4. Gửi messages qua lại
5. Upload hình ảnh
6. Verify trong database

---

## 📚 Files Quan Trọng

| Component | Backend | Frontend |
|-----------|---------|----------|
| **Controllers** | [`ConversationController.java`](file:///d:/fyn-monolithic/fyn-monolithic/src/main/java/com/fyn_monolithic/controller/message/ConversationController.java)<br>[`MessageController.java`](file:///d:/fyn-monolithic/fyn-monolithic/src/main/java/com/fyn_monolithic/controller/message/MessageController.java) | - |
| **Services** | [`ConversationService.java`](file:///d:/fyn-monolithic/fyn-monolithic/src/main/java/com/fyn_monolithic/service/message/ConversationService.java)<br>[`MessageService.java`](file:///d:/fyn-monolithic/fyn-monolithic/src/main/java/com/fyn_monolithic/service/message/MessageService.java) | [`message_service.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/domain/message_service.dart) |
| **UI Screens** | - | [`chat_list_screen.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/presentation/screens/chat_list_screen.dart)<br>[`chat_detail_screen.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/presentation/screens/chat_detail_screen.dart) |
| **State** | - | [`message_provider.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/presentation/providers/message_provider.dart) |
| **Routing** | - | [`app_config.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/config/app_config.dart#L92-L95) |

---

## ✨ Kết Luận

Chức năng chat đã được implement **đầy đủ** và **sẵn sàng sử dụng**!

**Vị trí chính:**
- 🔹 **Backend**: `/api/conversations` và `/api/conversations/{id}/messages`
- 🔹 **Frontend**: `/chat` route → `ChatListScreen` và `ChatDetailScreen`

**Để test:**
1. Run backend: `mvn spring-boot:run`
2. Run frontend: `flutter run -d chrome`
3. Login và tap icon chat
4. Select user và bắt đầu chat!
