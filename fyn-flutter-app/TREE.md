# Cây thư mục Flutter App

```
fyn-flutter-app/
├── .env.example                    # Environment variables example
├── .gitignore                       # Git ignore rules
├── analysis_options.yaml            # Linter configuration
├── pubspec.yaml                     # Dependencies
├── README.md                        # Documentation
├── STRUCTURE.md                     # Structure documentation
├── TREE.md                          # This file
│
├── assets/                          # Assets folder
│   ├── images/                      # Image assets
│   └── icons/                       # Icon assets
│
└── lib/                             # Source code
    ├── main.dart                    # Entry point
    ├── app.dart                     # App configuration
    │
    ├── config/                      # Configuration
    │   ├── api_config.dart          # API endpoints constants
    │   └── app_config.dart         # App config & routing
    │
    ├── core/                        # Core functionality
    │   ├── constants/               # App constants
    │   │   └── app_constants.dart   # App-wide constants
    │   ├── models/                  # Common models
    │   │   ├── api_response.dart    # ApiResponse wrapper
    │   │   └── page_response.dart   # PageResponse for pagination
    │   ├── network/                 # Network layer
    │   │   ├── api_client.dart      # Dio client
    │   │   ├── interceptors.dart    # Request/Response interceptors
    │   │   └── endpoints.dart       # Endpoints export
    │   ├── storage/                 # Local storage
    │   │   └── secure_storage.dart  # Secure storage for tokens
    │   └── utils/                   # Utilities
    │       ├── date_utils.dart      # Date formatting
    │       └── validators.dart       # Form validators
    │
    ├── features/                    # Feature modules
    │   ├── auth/                    # Authentication
    │   │   ├── data/
    │   │   │   ├── models/          # Auth data models
    │   │   │   └── repositories/    # Auth API repositories
    │   │   ├── domain/              # Auth business logic
    │   │   └── presentation/        # Auth UI
    │   │       ├── screens/          # Login, Register screens
    │   │       │   ├── login_screen.dart
    │   │       │   └── register_screen.dart
    │   │       └── widgets/         # Auth widgets
    │   │
    │   ├── post/                    # Posts feature
    │   │   ├── data/
    │   │   │   ├── models/          # Post data models
    │   │   │   └── repositories/    # Post API repositories
    │   │   ├── domain/              # Post business logic
    │   │   └── presentation/        # Post UI
    │   │       ├── screens/         # Feed, CreatePost screens
    │   │       │   └── feed_screen.dart
    │   │       └── widgets/         # Post widgets
    │   │
    │   ├── user/                    # User & Profile
    │   │   ├── data/
    │   │   │   ├── models/          # User data models
    │   │   │   └── repositories/    # User API repositories
    │   │   ├── domain/              # User business logic
    │   │   └── presentation/        # User UI
    │   │       ├── screens/         # Profile screens
    │   │       │   └── profile_screen.dart
    │   │       └── widgets/         # User widgets
    │   │
    │   ├── message/                 # Messaging
    │   │   ├── data/
    │   │   │   ├── models/          # Message data models
    │   │   │   └── repositories/    # Message API repositories
    │   │   ├── domain/              # Message business logic
    │   │   └── presentation/        # Message UI
    │   │       ├── screens/         # Conversations, Chat screens
    │   │       └── widgets/        # Message widgets
    │   │
    │   ├── notification/            # Notifications
    │   │   ├── data/
    │   │   │   ├── models/          # Notification data models
    │   │   │   └── repositories/    # Notification API repositories
    │   │   ├── domain/              # Notification business logic
    │   │   └── presentation/        # Notification UI
    │   │       ├── screens/         # Notifications screen
    │   │       └── widgets/         # Notification widgets
    │   │
    │   └── search/                  # Search
    │       ├── data/
    │       │   ├── models/          # Search data models
    │       │   └── repositories/    # Search API repositories
    │       ├── domain/              # Search business logic
    │       └── presentation/        # Search UI
    │           ├── screens/         # Search screen
    │           └── widgets/          # Search widgets
    │
    └── shared/                      # Shared resources
        ├── themes/                  # App themes
        │   └── app_theme.dart       # Light & Dark themes
        ├── utils/                   # Shared utilities
        └── widgets/                 # Reusable widgets
            ├── loading_indicator.dart
            └── error_widget.dart
```

## Tổng kết

### ✅ Đã có:
- ✅ Cấu trúc thư mục đầy đủ cho tất cả features
- ✅ Core modules (network, storage, models, utils)
- ✅ Configuration files
- ✅ Basic screens (Login, Register, Feed, Profile)
- ✅ Shared widgets (Loading, Error)
- ✅ Theme configuration
- ✅ API client với interceptors
- ✅ Secure storage
- ✅ Documentation files

### 📝 Cần implement:
- Models cho từng feature (DTOs từ API)
- Repositories cho từng feature (API calls)
- Domain logic (use cases)
- Complete screens
- Widgets cho từng feature
- State management (Provider/Riverpod)
- Navigation hoàn chỉnh

### 📦 Dependencies:
Tất cả dependencies đã được khai báo trong `pubspec.yaml`

### 🚀 Sẵn sàng để:
1. Chạy `flutter pub get`
2. Tạo file `.env` từ `.env.example`
3. Bắt đầu implement các features














