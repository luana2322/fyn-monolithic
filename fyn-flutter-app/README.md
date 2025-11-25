# FYN Flutter App

Flutter frontend application cho FYN Social Media Platform.

## 📋 Mô tả

Ứng dụng mạng xã hội được xây dựng bằng Flutter, kết nối với Spring Boot backend API.

## 🚀 Tính năng

- ✅ Authentication (Đăng ký, đăng nhập, JWT)
- ✅ Posts (Tạo, xem, xóa bài viết với media)
- ✅ Interactions (Like, Comment)
- ✅ Social (Follow/Unfollow, xem followers/following)
- ✅ Messaging (Tin nhắn trực tiếp và nhóm)
- ✅ Notifications (Thông báo)
- ✅ Search (Tìm kiếm hashtag)
- ✅ Profile Management

## 🛠️ Công nghệ

- **Framework**: Flutter 3.x
- **State Management**: Provider + Riverpod
- **HTTP Client**: Dio
- **Navigation**: GoRouter
- **Local Storage**: Flutter Secure Storage
- **Image Loading**: Cached Network Image

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration
├── config/                   # App configuration
│   ├── api_config.dart       # API endpoints & base URL
│   └── app_config.dart       # App-wide configuration
├── core/                     # Core functionality
│   ├── network/              # Network layer
│   │   ├── api_client.dart   # Dio client setup
│   │   ├── interceptors.dart # Request/Response interceptors
│   │   └── endpoints.dart    # API endpoints constants
│   ├── storage/              # Local storage
│   │   └── secure_storage.dart
│   ├── models/               # Common models
│   │   ├── api_response.dart
│   │   └── page_response.dart
│   └── utils/                # Utilities
│       ├── date_utils.dart
│       └── validators.dart
├── features/                 # Feature modules
│   ├── auth/                 # Authentication
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   ├── post/                 # Posts
│   ├── user/                 # User & Profile
│   ├── message/              # Messaging
│   ├── notification/         # Notifications
│   └── search/               # Search
└── shared/                   # Shared resources
    ├── widgets/              # Reusable widgets
    └── themes/               # App themes
```

## 🏃 Cài đặt và chạy

### Yêu cầu

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Backend API đang chạy (xem `fyn-monolithic`)

### Bước 1: Clone và cài đặt dependencies

```bash
cd fyn-flutter-app
flutter pub get
```

### Bước 2: Cấu hình môi trường

Tạo file `.env` trong thư mục root:

```env
BASE_URL=http://localhost:8080
# hoặc
BASE_URL=http://10.0.2.2:8080  # cho Android Emulator
# hoặc
BASE_URL=http://YOUR_IP:8080   # cho physical device
```

### Bước 3: Chạy ứng dụng

```bash
# Development
flutter run

# Chạy trên device cụ thể
flutter run -d <device_id>

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## 📱 API Configuration

Backend API base URL được cấu hình trong:
- `lib/config/api_config.dart`
- Hoặc sử dụng `.env` file với `flutter_dotenv`

Mặc định: `http://localhost:8080`

**Lưu ý:**
- Android Emulator: Sử dụng `http://10.0.2.2:8080`
- iOS Simulator: Sử dụng `http://localhost:8080`
- Physical Device: Sử dụng IP của máy tính (ví dụ: `http://192.168.1.100:8080`)

## 🔐 Authentication

Ứng dụng sử dụng JWT (JSON Web Token) để xác thực:

1. User đăng nhập/đăng ký
2. Nhận `accessToken` và `refreshToken`
3. Tokens được lưu trong secure storage
4. Mỗi request tự động thêm header: `Authorization: Bearer <token>`
5. Tự động refresh token khi hết hạn

## 📦 Dependencies chính

- **dio**: HTTP client với interceptors
- **provider**: State management
- **flutter_riverpod**: Advanced state management
- **flutter_secure_storage**: Lưu trữ tokens an toàn
- **go_router**: Navigation
- **cached_network_image**: Load và cache images
- **image_picker**: Chọn ảnh từ gallery/camera

## 🧪 Testing

```bash
# Run tests
flutter test

# Run tests với coverage
flutter test --coverage
```

## 📚 Tài liệu tham khảo

- [API Documentation](../API_DOCUMENTATION.md) - Chi tiết tất cả API endpoints
- [Tóm tắt dự án](../TOM_TAT_DU_AN.md) - Tổng quan dự án

## 🏗️ Architecture

Ứng dụng sử dụng **Clean Architecture** với các layer:

1. **Presentation Layer**: UI, Screens, Widgets
2. **Domain Layer**: Business logic, Use cases
3. **Data Layer**: Repositories, Models, API clients

Mỗi feature được tổ chức theo cấu trúc này để dễ maintain và test.

## 🔄 State Management

- **Provider**: Cho state management đơn giản
- **Riverpod**: Cho state management phức tạp và dependency injection

## 📝 Code Generation

Một số models sử dụng code generation:

```bash
# Generate code
flutter pub run build_runner build

# Watch mode (tự động generate khi có thay đổi)
flutter pub run build_runner watch
```

## 🐛 Troubleshooting

### Lỗi kết nối API

1. Kiểm tra backend đang chạy
2. Kiểm tra BASE_URL trong config
3. Kiểm tra firewall/network
4. Android Emulator: Sử dụng `10.0.2.2` thay vì `localhost`

### Lỗi build

```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run
```

### Lỗi dependencies

```bash
# Update dependencies
flutter pub upgrade
flutter pub get
```

## 📄 License

Private project - All rights reserved

## 👥 Contributors

- Development Team

---

**Lưu ý**: Đảm bảo backend API đang chạy trước khi test ứng dụng Flutter.














