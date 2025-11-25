# API Documentation cho Flutter Frontend

## Thông tin cơ bản

- **Base URL**: `http://localhost:8080` (development) hoặc cấu hình theo môi trường
- **Port**: `8080`
- **Authentication**: JWT Bearer Token
- **Content-Type**: `application/json` (trừ upload file: `multipart/form-data`)

## Authentication

### Cơ chế xác thực
- Sử dụng JWT (JSON Web Token)
- Token được gửi trong header: `Authorization: Bearer <access_token>`
- Access token hết hạn sau 24 giờ (86400000ms)
- Refresh token hết hạn sau 7 ngày (604800000ms)

### Endpoints không cần authentication
- `/api/auth/**` - Tất cả các endpoint authentication
- `/health` - Health check
- `/actuator/**` - Actuator endpoints

### Endpoints cần authentication
- Tất cả các endpoint khác đều yêu cầu JWT token

---

## API Endpoints

### 1. Authentication APIs

#### 1.1. Đăng ký
```
POST /api/auth/register
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "phone": "+84901234567",
  "username": "username",
  "password": "password123",
  "fullName": "Full Name"
}
```

**Validation:**
- `email`: Required, valid email format
- `phone`: Optional, E.164 format (8-15 digits)
- `username`: Required, 3-30 characters
- `password`: Required, 8-128 characters
- `fullName`: Optional, max 120 characters

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "expiresIn": 86400000,
    "user": {
      "id": "uuid",
      "username": "username",
      "email": "user@example.com",
      "phone": "+84901234567",
      "fullName": "Full Name",
      "status": "ACTIVE",
      "profile": {
        "bio": null,
        "website": null,
        "location": null,
        "avatarUrl": null,
        "isPrivate": false
      }
    }
  }
}
```

#### 1.2. Đăng nhập
```
POST /api/auth/login
Content-Type: application/json
```

**Request Body:**
```json
{
  "identifier": "username_or_email",
  "password": "password123"
}
```

**Response:** Giống như đăng ký

#### 1.3. Refresh Token
```
POST /api/auth/refresh
Content-Type: application/json
```

**Request Body:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "new_access_token",
    "refreshToken": "new_refresh_token",
    "expiresIn": 86400000
  }
}
```

#### 1.4. Đăng xuất
```
POST /api/auth/logout
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Logged out"
}
```

### 2. Password Management APIs

#### 2.1. Đổi mật khẩu
```
POST /api/auth/password/change
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "currentPassword": "old_password",
  "newPassword": "new_password"
}
```

#### 2.2. Quên mật khẩu
```
POST /api/auth/password/forgot
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent"
}
```

#### 2.3. Xác thực OTP
```
POST /api/auth/password/verify-otp
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified"
}
```

### 3. User APIs

#### 3.1. Lấy thông tin user hiện tại
```
GET /api/users/me
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "username",
    "email": "user@example.com",
    "phone": "+84901234567",
    "fullName": "Full Name",
    "status": "ACTIVE",
    "profile": {
      "bio": "Bio text",
      "website": "https://website.com",
      "location": "Location",
      "avatarUrl": "https://minio-url/avatar.jpg",
      "isPrivate": false
    }
  }
}
```

#### 3.2. Lấy thông tin user theo ID
```
GET /api/users/{userId}
Authorization: Bearer <token>
```

#### 3.3. Lấy thông tin user theo username
```
GET /api/users/username/{username}
Authorization: Bearer <token>
```

### 4. Profile APIs

#### 4.1. Cập nhật profile
```
PUT /api/users/profile
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "fullName": "New Full Name",
  "bio": "Bio text",
  "website": "https://website.com",
  "location": "Location",
  "isPrivate": false
}
```

#### 4.2. Đổi avatar
```
POST /api/users/profile/avatar
Content-Type: multipart/form-data
Authorization: Bearer <token>
```

**Request:**
- Form data với key: `file`
- File: Image file (max 50MB)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "username",
    ...
    "profile": {
      "avatarUrl": "https://minio-url/new-avatar.jpg",
      ...
    }
  }
}
```

### 5. Follower APIs

#### 5.1. Follow user
```
POST /api/users/{userId}/follow
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Followed user"
}
```

#### 5.2. Unfollow user
```
DELETE /api/users/{userId}/follow
Authorization: Bearer <token>
```

#### 5.3. Lấy danh sách followers
```
GET /api/users/{userId}/followers?page=0&size=20
Authorization: Bearer <token>
```

**Query Parameters:**
- `page`: Số trang (default: 0)
- `size`: Số items mỗi trang (default: 20)

**Response:**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "uuid",
        "username": "follower_username",
        ...
      }
    ],
    "totalElements": 100,
    "totalPages": 5,
    "page": 0,
    "size": 20
  }
}
```

#### 5.4. Lấy danh sách following
```
GET /api/users/{userId}/following?page=0&size=20
Authorization: Bearer <token>
```

### 6. Post APIs

#### 6.1. Tạo post
```
POST /api/posts
Content-Type: multipart/form-data
Authorization: Bearer <token>
```

**Request:**
- Form data:
  - `payload`: JSON string của CreatePostRequest
  - `media`: (Optional) List of files

**CreatePostRequest JSON:**
```json
{
  "content": "Post content here",
  "hashtags": ["tag1", "tag2"],
  "mentionUsernames": ["username1", "username2"],
  "visibility": "PUBLIC"
}
```

**Visibility values:** `PUBLIC`, `FOLLOWERS`, `PRIVATE`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "author": {
      "id": "uuid",
      "username": "username",
      ...
    },
    "content": "Post content here",
    "visibility": "PUBLIC",
    "likeCount": 0,
    "commentCount": 0,
    "createdAt": "2024-01-01T00:00:00Z",
    "media": [
      {
        "objectKey": "key",
        "mediaUrl": "https://minio-url/media.jpg",
        "mediaType": "IMAGE",
        "description": null
      }
    ]
  }
}
```

#### 6.2. Lấy feed
```
GET /api/posts/feed?page=0&size=10
Authorization: Bearer <token>
```

**Query Parameters:**
- `page`: Số trang (default: 0)
- `size`: Số items mỗi trang (default: 10)

#### 6.3. Lấy posts của user
```
GET /api/posts/user/{userId}?page=0&size=10
Authorization: Bearer <token>
```

#### 6.4. Xóa post
```
DELETE /api/posts/{postId}
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Post deleted"
}
```

### 7. Like APIs

#### 7.1. Like post
```
POST /api/posts/{postId}/likes
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Post liked"
}
```

#### 7.2. Unlike post
```
DELETE /api/posts/{postId}/likes
Authorization: Bearer <token>
```

### 8. Comment APIs

#### 8.1. Thêm comment
```
POST /api/posts/{postId}/comments
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "content": "Comment content",
  "parentId": "uuid" // Optional, for reply
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "parentId": null,
    "author": {
      "id": "uuid",
      "username": "username",
      ...
    },
    "content": "Comment content",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

#### 8.2. Lấy danh sách comments
```
GET /api/posts/{postId}/comments
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "parentId": null,
      "author": {...},
      "content": "Comment",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### 8.3. Xóa comment
```
DELETE /api/posts/{postId}/comments/{commentId}
Authorization: Bearer <token>
```

### 9. Message APIs

#### 9.1. Tạo conversation
```
POST /api/conversations
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "memberIds": ["uuid1", "uuid2"],
  "type": "DIRECT" // or "GROUP"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "type": "DIRECT",
    "title": null,
    "memberIds": ["uuid1", "uuid2"],
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### 9.2. Lấy danh sách conversations
```
GET /api/conversations
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "type": "DIRECT",
      ...
    }
  ]
}
```

#### 9.3. Gửi message
```
POST /api/conversations/{conversationId}/messages
Content-Type: multipart/form-data
Authorization: Bearer <token>
```

**Request:**
- Form data:
  - `payload`: JSON string của SendMessageRequest
  - `media`: (Optional) File

**SendMessageRequest JSON:**
```json
{
  "content": "Message content"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "conversationId": "uuid",
    "senderId": "uuid",
    "content": "Message content",
    "status": "SENT",
    "createdAt": "2024-01-01T00:00:00Z",
    "mediaUrl": "https://minio-url/media.jpg" // or null
  }
}
```

#### 9.4. Lấy messages
```
GET /api/conversations/{conversationId}/messages?page=0&size=50
Authorization: Bearer <token>
```

**Query Parameters:**
- `page`: Số trang (default: 0)
- `size`: Số items mỗi trang (default: 50)

### 10. Notification APIs

#### 10.1. Lấy danh sách notifications
```
GET /api/notifications?page=0&size=20
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
        "type": "LIKE",
        "status": "UNREAD",
        "message": "User liked your post",
        "referenceId": "uuid",
        "createdAt": "2024-01-01T00:00:00Z"
      }
    ],
    "totalElements": 50,
    "totalPages": 3,
    "page": 0,
    "size": 20
  }
}
```

**Notification Types:** `FOLLOW`, `LIKE`, `COMMENT`, `MESSAGE`, `SYSTEM`
**Notification Status:** `READ`, `UNREAD`

#### 10.2. Đánh dấu đã đọc
```
POST /api/notifications/{notificationId}/read
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

### 11. Search APIs

#### 11.1. Tìm kiếm theo hashtag
```
GET /api/search/hashtags?tag=hashtag
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "author": {...},
      "content": "Post with #hashtag",
      ...
    }
  ]
}
```

---

## Enum Values

### PostVisibility
- `PUBLIC` - Công khai
- `FOLLOWERS` - Chỉ người follow
- `PRIVATE` - Riêng tư

### UserStatus
- `PENDING_VERIFICATION` - Đang chờ xác thực
- `ACTIVE` - Hoạt động
- `SUSPENDED` - Bị tạm khóa
- `DEACTIVATED` - Đã vô hiệu hóa

### MessageStatus
- `SENT` - Đã gửi
- `DELIVERED` - Đã giao
- `READ` - Đã đọc

### NotificationType
- `FOLLOW` - Follow
- `LIKE` - Like
- `COMMENT` - Comment
- `MESSAGE` - Message
- `SYSTEM` - Hệ thống

### NotificationStatus
- `UNREAD` - Chưa đọc
- `READ` - Đã đọc

### ConversationType
- `DIRECT` - Tin nhắn trực tiếp
- `GROUP` - Nhóm

### MediaType
- `IMAGE` - Hình ảnh
- `VIDEO` - Video
- `AUDIO` - Âm thanh
- `FILE` - File

---

## Error Response Format

Tất cả các lỗi đều trả về format:

```json
{
  "success": false,
  "message": "Error message",
  "data": null
}
```

**HTTP Status Codes:**
- `200`: Success
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (missing/invalid token)
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

---

## Lưu ý cho Flutter Development

### 1. HTTP Client
Sử dụng `http` hoặc `dio` package:
```yaml
dependencies:
  dio: ^5.0.0
  # hoặc
  http: ^1.0.0
```

### 2. JWT Token Storage
Lưu token vào secure storage:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

### 3. Multipart Upload
Khi upload file, sử dụng `FormData` với Dio:
```dart
FormData formData = FormData.fromMap({
  'payload': jsonEncode(requestData),
  'media': await MultipartFile.fromFile(filePath),
});
```

### 4. Interceptor cho JWT
Tự động thêm token vào header:
```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    String? token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

### 5. Error Handling
Xử lý các trường hợp:
- Token hết hạn → Refresh token hoặc đăng nhập lại
- 401 Unauthorized → Redirect to login
- Network errors → Retry logic

### 6. Date Format
Backend sử dụng ISO 8601 format: `yyyy-MM-dd'T'HH:mm:ss'Z'`
Sử dụng `DateTime.parse()` trong Dart.

### 7. UUID
Backend sử dụng UUID cho IDs. Sử dụng `uuid` package nếu cần generate.

### 8. CORS
Backend đã cấu hình CORS cho phép tất cả origins. Không cần lo lắng về CORS khi phát triển.

### 9. File Upload Limits
- Max file size: 50MB
- Max request size: 50MB

### 10. Pagination
Tất cả các list endpoints đều hỗ trợ pagination với `page` và `size` parameters.

---

## Model Classes cho Flutter

### ApiResponse
```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.message, this.data});
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
    );
  }
}
```

### PageResponse
```dart
class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return PageResponse(
      content: (json['content'] as List).map((e) => fromJsonT(e)).toList(),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      page: json['page'],
      size: json['size'],
    );
  }
}
```

---

## Testing

### Base URL cho các môi trường:
- **Development**: `http://localhost:8080`
- **Production**: Cấu hình theo server thực tế

### Test với Postman/Insomnia:
1. Đăng ký/Đăng nhập để lấy token
2. Copy `accessToken` từ response
3. Thêm header: `Authorization: Bearer <token>`
4. Test các endpoints khác

---

## Tóm tắt Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/api/auth/register` | No | Đăng ký |
| POST | `/api/auth/login` | No | Đăng nhập |
| POST | `/api/auth/refresh` | No | Refresh token |
| POST | `/api/auth/logout` | Yes | Đăng xuất |
| POST | `/api/auth/password/change` | Yes | Đổi mật khẩu |
| POST | `/api/auth/password/forgot` | No | Quên mật khẩu |
| POST | `/api/auth/password/verify-otp` | No | Xác thực OTP |
| GET | `/api/users/me` | Yes | User hiện tại |
| GET | `/api/users/{userId}` | Yes | User theo ID |
| GET | `/api/users/username/{username}` | Yes | User theo username |
| PUT | `/api/users/profile` | Yes | Cập nhật profile |
| POST | `/api/users/profile/avatar` | Yes | Đổi avatar |
| POST | `/api/users/{userId}/follow` | Yes | Follow user |
| DELETE | `/api/users/{userId}/follow` | Yes | Unfollow user |
| GET | `/api/users/{userId}/followers` | Yes | Danh sách followers |
| GET | `/api/users/{userId}/following` | Yes | Danh sách following |
| POST | `/api/posts` | Yes | Tạo post |
| GET | `/api/posts/feed` | Yes | Feed |
| GET | `/api/posts/user/{userId}` | Yes | Posts của user |
| DELETE | `/api/posts/{postId}` | Yes | Xóa post |
| POST | `/api/posts/{postId}/likes` | Yes | Like post |
| DELETE | `/api/posts/{postId}/likes` | Yes | Unlike post |
| POST | `/api/posts/{postId}/comments` | Yes | Thêm comment |
| GET | `/api/posts/{postId}/comments` | Yes | Danh sách comments |
| DELETE | `/api/posts/{postId}/comments/{commentId}` | Yes | Xóa comment |
| POST | `/api/conversations` | Yes | Tạo conversation |
| GET | `/api/conversations` | Yes | Danh sách conversations |
| POST | `/api/conversations/{conversationId}/messages` | Yes | Gửi message |
| GET | `/api/conversations/{conversationId}/messages` | Yes | Danh sách messages |
| GET | `/api/notifications` | Yes | Danh sách notifications |
| POST | `/api/notifications/{notificationId}/read` | Yes | Đánh dấu đã đọc |
| GET | `/api/search/hashtags` | Yes | Tìm kiếm hashtag |

