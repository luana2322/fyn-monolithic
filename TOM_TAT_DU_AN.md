# Tóm tắt Dự án - Flutter Frontend

## Tổng quan dự án

Đây là một ứng dụng mạng xã hội (Social Media App) với các tính năng:

1. **Authentication & User Management** - Đăng ký, đăng nhập, quản lý user
2. **Posts** - Tạo, xem, xóa bài viết với hình ảnh/video
3. **Interactions** - Like, Comment bài viết
4. **Social** - Follow/Unfollow users, xem followers/following
5. **Messaging** - Tin nhắn trực tiếp và nhóm
6. **Notifications** - Thông báo về các hoạt động
7. **Search** - Tìm kiếm theo hashtag

## Công nghệ Backend

- **Framework**: Spring Boot 3.5.7
- **Java Version**: 21
- **Database**: PostgreSQL
- **Storage**: MinIO (cho file upload)
- **Authentication**: JWT (JSON Web Token)
- **Security**: Spring Security

## Cấu trúc API

### Base URL
- Development: `http://localhost:8080`
- Production: (cấu hình theo server)

### Authentication
- Sử dụng JWT Bearer Token
- Token được gửi trong header: `Authorization: Bearer <token>`
- Access token: 24 giờ
- Refresh token: 7 ngày

## Các Module chính cần xây dựng trong Flutter

### 1. Authentication Module
- [ ] Màn hình đăng ký
- [ ] Màn hình đăng nhập
- [ ] Xử lý JWT token (lưu trữ, refresh)
- [ ] Quên mật khẩu / Đổi mật khẩu
- [ ] Auto-login khi mở app

### 2. Home/Feed Module
- [ ] Màn hình feed hiển thị posts
- [ ] Pull to refresh
- [ ] Infinite scroll (pagination)
- [ ] Hiển thị post với media (hình ảnh, video)
- [ ] Like/Unlike post
- [ ] Xem comments

### 3. Post Module
- [ ] Màn hình tạo post
- [ ] Upload hình ảnh/video
- [ ] Chọn visibility (PUBLIC, FOLLOWERS, PRIVATE)
- [ ] Thêm hashtags
- [ ] Mention users
- [ ] Xóa post

### 4. Profile Module
- [ ] Màn hình profile cá nhân
- [ ] Màn hình profile người khác
- [ ] Cập nhật profile (bio, website, location)
- [ ] Đổi avatar
- [ ] Xem danh sách posts của user
- [ ] Follow/Unfollow button

### 5. Social Module
- [ ] Màn hình danh sách followers
- [ ] Màn hình danh sách following
- [ ] Search users

### 6. Comment Module
- [ ] Màn hình comments của post
- [ ] Thêm comment
- [ ] Reply comment (nested comments)
- [ ] Xóa comment

### 7. Messaging Module
- [ ] Màn hình danh sách conversations
- [ ] Màn hình chat (messages)
- [ ] Gửi tin nhắn text
- [ ] Gửi tin nhắn media (hình ảnh)
- [ ] Real-time updates (nếu có WebSocket)

### 8. Notification Module
- [ ] Màn hình danh sách notifications
- [ ] Đánh dấu đã đọc
- [ ] Badge số lượng unread
- [ ] Navigate đến post/user khi click notification

### 9. Search Module
- [ ] Màn hình tìm kiếm
- [ ] Tìm kiếm theo hashtag
- [ ] Hiển thị kết quả posts

## Packages Flutter cần thiết

```yaml
dependencies:
  # HTTP Client
  dio: ^5.0.0
  
  # State Management (chọn một)
  provider: ^6.0.0
  # hoặc
  bloc: ^8.0.0
  # hoặc
  riverpod: ^2.0.0
  
  # Local Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
  
  # JSON Serialization
  json_annotation: ^4.8.0
  
  # Image/Video
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  video_player: ^2.8.0
  
  # UI Components
  flutter_svg: ^2.0.0
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.18.0
  uuid: ^4.0.0
  
  # Navigation
  go_router: ^12.0.0
  # hoặc
  auto_route: ^7.0.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

## Cấu trúc thư mục Flutter đề xuất

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── api_config.dart
│   └── app_config.dart
├── core/
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── interceptors.dart
│   │   └── endpoints.dart
│   ├── storage/
│   │   └── secure_storage.dart
│   ├── models/
│   │   ├── api_response.dart
│   │   └── page_response.dart
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   ├── post/
│   ├── profile/
│   ├── message/
│   ├── notification/
│   └── search/
└── shared/
    ├── widgets/
    └── themes/
```

## Luồng Authentication

1. User đăng nhập/đăng ký
2. Nhận `accessToken` và `refreshToken`
3. Lưu tokens vào secure storage
4. Mỗi request gửi kèm `Authorization: Bearer <accessToken>`
5. Khi token hết hạn (401), tự động refresh token
6. Nếu refresh token hết hạn, redirect về màn hình đăng nhập

## Các điểm cần lưu ý

### 1. File Upload
- Sử dụng `multipart/form-data`
- Max file size: 50MB
- Khi tạo post, gửi:
  - `payload`: JSON string của CreatePostRequest
  - `media`: List of files (optional)

### 2. Pagination
- Tất cả list endpoints đều hỗ trợ pagination
- Parameters: `page` (bắt đầu từ 0), `size`
- Response có `totalPages`, `totalElements` để hiển thị

### 3. Date Format
- Backend trả về ISO 8601: `2024-01-01T00:00:00Z`
- Sử dụng `DateTime.parse()` trong Dart

### 4. UUID
- Tất cả IDs đều là UUID (string)
- Sử dụng string để xử lý, không cần convert

### 5. Error Handling
- Luôn kiểm tra `success` field trong response
- Xử lý các HTTP status codes:
  - 400: Validation errors
  - 401: Unauthorized (token invalid/expired)
  - 404: Not found
  - 500: Server error

### 6. CORS
- Backend đã cấu hình CORS cho phép tất cả origins
- Không cần lo lắng về CORS khi phát triển

## Testing

### Test với Postman/Insomnia
1. Import collection từ API documentation
2. Test các endpoints
3. Verify request/response format

### Test với Flutter
1. Tạo mock data cho development
2. Test UI với mock data
3. Test integration với real API

## Bước tiếp theo

1. **Setup Flutter project**
   - Tạo Flutter project mới
   - Thêm các packages cần thiết
   - Setup folder structure

2. **Setup API Client**
   - Tạo Dio client với interceptors
   - Setup base URL
   - Handle authentication headers

3. **Tạo Models**
   - Generate models từ JSON (sử dụng json_serializable)
   - Tạo ApiResponse và PageResponse wrappers

4. **Implement Authentication**
   - Login/Register screens
   - Token storage
   - Auto-login logic

5. **Implement Core Features**
   - Feed screen
   - Post creation
   - Profile screens

6. **Implement Additional Features**
   - Messaging
   - Notifications
   - Search

## Tài liệu tham khảo

- Xem file `API_DOCUMENTATION.md` để biết chi tiết về tất cả các endpoints
- Spring Boot documentation: https://spring.io/projects/spring-boot
- Flutter documentation: https://flutter.dev/docs
- Dio package: https://pub.dev/packages/dio

## Lưu ý quan trọng

⚠️ **Security**: 
- Không commit tokens, secrets vào git
- Sử dụng environment variables cho base URL
- Lưu tokens trong secure storage

⚠️ **Performance**:
- Implement caching cho images
- Lazy loading cho lists
- Optimize image sizes trước khi upload

⚠️ **UX**:
- Loading states cho mọi async operations
- Error messages rõ ràng
- Pull to refresh
- Infinite scroll cho lists

