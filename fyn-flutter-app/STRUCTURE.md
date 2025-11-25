# Cấu trúc thư mục Flutter App

## Tổng quan

Dự án được tổ chức theo **Clean Architecture** với cấu trúc feature-based.

```
fyn-flutter-app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # App configuration
│   ├── config/                      # Configuration
│   │   ├── api_config.dart          # API endpoints
│   │   └── app_config.dart          # App config & routing
│   ├── core/                        # Core functionality
│   │   ├── network/                  # Network layer
│   │   │   ├── api_client.dart      # Dio client
│   │   │   ├── interceptors.dart    # Request/Response interceptors
│   │   │   └── endpoints.dart       # Endpoints export
│   │   ├── storage/                  # Local storage
│   │   │   └── secure_storage.dart  # Secure storage cho tokens
│   │   ├── models/                   # Common models
│   │   │   ├── api_response.dart     # ApiResponse wrapper
│   │   │   └── page_response.dart    # PageResponse cho pagination
│   │   └── utils/                    # Utilities
│   │       ├── date_utils.dart       # Date formatting
│   │       └── validators.dart       # Form validators
│   ├── features/                     # Feature modules
│   │   ├── auth/                     # Authentication
│   │   │   ├── data/
│   │   │   │   ├── models/          # Data models (DTOs)
│   │   │   │   └── repositories/   # API repositories
│   │   │   ├── domain/              # Business logic
│   │   │   └── presentation/        # UI
│   │   │       ├── screens/         # Screens
│   │   │       └── widgets/         # Widgets
│   │   ├── post/                    # Posts feature
│   │   ├── user/                    # User & Profile
│   │   ├── message/                 # Messaging
│   │   ├── notification/            # Notifications
│   │   └── search/                  # Search
│   └── shared/                      # Shared resources
│       ├── widgets/                  # Reusable widgets
│       └── themes/                   # App themes
├── assets/                           # Assets
│   ├── images/
│   └── icons/
├── pubspec.yaml                      # Dependencies
├── .env.example                      # Environment variables example
├── README.md                         # Documentation
└── analysis_options.yaml             # Linter rules
```

## Chi tiết từng module

### 1. Core Module

#### Network (`core/network/`)
- **api_client.dart**: Dio client với các methods GET, POST, PUT, DELETE, upload
- **interceptors.dart**: 
  - `AuthInterceptor`: Tự động thêm JWT token
  - `LoggingInterceptor`: Log requests/responses (debug)
  - `ErrorInterceptor`: Xử lý errors
- **endpoints.dart**: Export ApiEndpoints

#### Storage (`core/storage/`)
- **secure_storage.dart**: Lưu trữ tokens an toàn

#### Models (`core/models/`)
- **api_response.dart**: Wrapper cho API responses
- **page_response.dart**: Model cho paginated responses

#### Utils (`core/utils/`)
- **date_utils.dart**: Format dates (ISO 8601, readable)
- **validators.dart**: Form validation helpers

### 2. Features

Mỗi feature có cấu trúc:

```
feature_name/
├── data/
│   ├── models/          # Data models (DTOs từ API)
│   └── repositories/    # API calls
├── domain/              # Business logic, use cases
└── presentation/        # UI
    ├── screens/         # Full screens
    └── widgets/         # Reusable widgets
```

#### Auth Feature
- **Screens**: Login, Register
- **Models**: LoginRequest, RegisterRequest, AuthResponse
- **Repository**: AuthRepository

#### Post Feature
- **Screens**: Feed, CreatePost, PostDetail
- **Models**: PostResponse, CreatePostRequest, CommentResponse
- **Repository**: PostRepository

#### User Feature
- **Screens**: Profile, EditProfile
- **Models**: UserResponse, ProfileResponse
- **Repository**: UserRepository

#### Message Feature
- **Screens**: Conversations, Chat
- **Models**: ConversationResponse, MessageResponse
- **Repository**: MessageRepository

#### Notification Feature
- **Screens**: Notifications
- **Models**: NotificationResponse
- **Repository**: NotificationRepository

#### Search Feature
- **Screens**: Search
- **Models**: SearchResult
- **Repository**: SearchRepository

### 3. Shared

#### Widgets (`shared/widgets/`)
- Reusable widgets như LoadingIndicator, ErrorWidget, etc.

#### Themes (`shared/themes/`)
- **app_theme.dart**: Light & Dark themes

## Cách thêm feature mới

1. Tạo thư mục trong `features/`
2. Tạo cấu trúc: `data/`, `domain/`, `presentation/`
3. Tạo models trong `data/models/`
4. Tạo repository trong `data/repositories/`
5. Tạo screens trong `presentation/screens/`
6. Thêm routes trong `config/app_config.dart`

## Naming Conventions

- **Files**: snake_case (ví dụ: `login_screen.dart`)
- **Classes**: PascalCase (ví dụ: `LoginScreen`)
- **Variables**: camelCase (ví dụ: `userName`)
- **Constants**: lowerCamelCase với prefix (ví dụ: `kBaseUrl`)

## Dependencies

Xem `pubspec.yaml` để biết danh sách đầy đủ dependencies.

## Environment Variables

Tạo file `.env` từ `.env.example` và cấu hình:
- `BASE_URL`: URL của backend API














