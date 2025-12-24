# 💕 FYN - Dating & Social Connection App

A full-stack dating and social connection application with **Spring Boot** backend and **Flutter** mobile/web frontend.

![Tech Stack](https://img.shields.io/badge/Java-17-orange) ![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green) ![Flutter](https://img.shields.io/badge/Flutter-3.x-blue) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [API Documentation](#-api-documentation)
- [Database Schema](#-database-schema)
- [Matching Process](#-matching-process)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔐 **Authentication** | JWT-based login/register with refresh tokens |
| 🎯 **Meetups** | Create and discover meetups, apply/accept matching |
| 💬 **Messaging** | Real-time chat via WebSocket |
| 📹 **Video Call** | 1-on-1 video calls (WebRTC) |
| 📝 **Posts** | Social feed with likes, comments |
| 📖 **Stories** | 24-hour ephemeral content |
| 🎉 **Events** | Create and join events |
| 🔍 **Search** | Find users by interests, location |
| 🔔 **Notifications** | Push notifications |
| 👤 **Profiles** | User profiles with photos, bio, interests |

---

## 🛠 Tech Stack

### Backend
- **Java 17** + **Spring Boot 3**
- **PostgreSQL** (with PostGIS for location)
- **MinIO** (S3-compatible object storage)
- **WebSocket** (STOMP for real-time messaging)
- **JWT** (authentication)
- **Docker Compose** (local development)

### Frontend
- **Flutter 3** (Dart)
- **Riverpod** (state management)
- **GoRouter** (navigation)
- **Dio** (HTTP client)
- **WebSocket** (real-time)
- **Firebase** (notifications, mobile)

---

## 🏗 Project Structure

```
fyn-monolithic/
├── fyn-monolithic/              # 🔧 Backend (Spring Boot)
│   └── src/main/java/com/fyn_monolithic/
│       ├── config/              # Security, WebSocket, MinIO config
│       ├── controller/          # REST API controllers (23 controllers)
│       │   ├── auth/            # Login, Register, Password
│       │   ├── date/            # Meetup, Dating features
│       │   ├── post/            # Posts, Comments, Likes
│       │   ├── message/         # Conversations, Messages
│       │   ├── story/           # Stories
│       │   └── user/            # Profile, Followers
│       ├── dto/                 # Request/Response DTOs (46 DTOs)
│       ├── model/               # JPA entities (54 models)
│       ├── repository/          # Data access layer (29 repos)
│       ├── service/             # Business logic (25 services)
│       ├── security/            # JWT authentication
│       └── exception/           # Error handlers
│
├── fyn-flutter-app/             # 📱 Frontend (Flutter)
│   └── lib/
│       ├── config/              # API config, routing (GoRouter)
│       ├── core/                # Network, storage, utils
│       ├── features/            # Feature modules
│       │   ├── auth/            # Login, Register screens
│       │   ├── meetup/          # Meetup discovery, apply, manage
│       │   ├── post/            # Feed, Create post
│       │   ├── story/           # Stories
│       │   ├── message/         # Chat screens
│       │   ├── video_call/      # Video call screens
│       │   ├── events/          # Events
│       │   └── user/            # Profile screens
│       ├── shared/              # Reusable widgets, themes
│       └── theme/               # App theming
│
└── docs/                        # Documentation
```

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 17+
- Flutter SDK 3.x
- Android Studio / VS Code

### 1️⃣ Start Backend

```powershell
# Navigate to backend folder
cd fyn-monolithic

# Start infrastructure (PostgreSQL, MinIO, Redis)
docker-compose up -d

# Run Spring Boot application
.\mvnw spring-boot:run
```

Backend runs at: `http://localhost:8080`

### 2️⃣ Start Flutter App

```powershell
# Navigate to Flutter app folder
cd fyn-flutter-app

# Install dependencies
flutter pub get

# Configure .env file (copy from .env.example)
# Update BASE_URL with your backend URL

# Run on Web
flutter run -d chrome

# Run on Android (replace DEVICE_ID with your device)
flutter devices                    # List devices
flutter run -d <DEVICE_ID>         # Run on specific device
```

### 📱 Android Configuration

For Android devices, update `.env` with your computer's IP address:

```env
# Replace with your computer's IP (use `ipconfig` to find it)
BASE_URL=http://192.168.x.x:8080
```

---

## 📡 API Documentation

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/refresh` | Refresh token |

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users/me` | Get current user |
| PUT | `/api/v1/users/profile` | Update profile |
| POST | `/api/v1/users/avatar` | Upload avatar |

### Meetups
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/meetups/discover` | Discover nearby meetups |
| POST | `/api/v1/meetups` | Create new meetup |
| GET | `/api/v1/meetups/{id}` | Get meetup details |
| POST | `/api/v1/meetups/{id}/apply` | Apply to meetup |
| PATCH | `/api/v1/matches/{id}/accept` | Accept match request |
| PATCH | `/api/v1/matches/{id}/reject` | Reject match request |
| GET | `/api/v1/meetups/my` | Get my meetups |
| GET | `/api/v1/meetups/applied` | Get applied meetups |

### Posts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/posts/feed` | Get feed |
| POST | `/api/posts` | Create post |
| POST | `/api/posts/{id}/like` | Like post |
| POST | `/api/posts/{id}/comments` | Comment on post |
| GET | `/api/posts/recommended` | AI-powered recommendations |

### Stories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/stories` | Get stories |
| POST | `/api/v1/stories` | Create story |

### Messages
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/conversations` | List conversations |
| GET | `/api/v1/conversations/{id}/messages` | Get messages |
| POST | `/api/v1/conversations/{id}/messages` | Send message |

---

## 🗄 Database Schema

### Key Entities

| Entity | Description |
|--------|-------------|
| `users` | User accounts |
| `user_profiles` | Extended profile data |
| `meetups` | Meetup events |
| `meetup_matches` | Match requests for meetups |
| `conversations` | Chat threads |
| `messages` | Chat messages |
| `posts` | Social feed posts |
| `stories` | Ephemeral stories |
| `events` | Events |

---

## 🔄 Matching Process

### Meetup Flow
```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  ORGANIZER  │      │   DATABASE   │      │  APPLICANT  │
└──────┬──────┘      └──────┬───────┘      └──────┬──────┘
       │                    │                     │
       │─── Create ────────>│                     │
       │    Meetup          │                     │
       │                    │                     │
       │                    │<──── Discover ──────│
       │                    │      Meetups        │
       │                    │                     │
       │                    │<──── Apply ─────────│
       │                    │      to Meetup      │
       │                    │                     │
       │<── Get Match ──────│                     │
       │    Requests        │                     │
       │                    │                     │
       │─── Accept/Reject ─>│                     │
       │    Match           │                     │
       │                    │──── Notify ────────>│
       │                    │     Result          │
       │                    │                     │
       │<───────────────────│─────────────────────│
       │        💬 Chat Available 💬              │
       └────────────────────┴─────────────────────┘
```

### Match Status Flow
```
PENDING → ACCEPTED → CONFIRMED
       ↘ REJECTED
       ↘ CANCELLED
```

---

## 📁 Key Files

### Backend
| File | Description |
|------|-------------|
| `MeetupController.java` | Meetup REST endpoints |
| `MeetupMatchService.java` | Meetup matching logic |
| `PostController.java` | Posts REST endpoints |
| `MessageController.java` | Chat endpoints |
| `SecurityConfig.java` | JWT security config |

### Frontend
| File | Description |
|------|-------------|
| `discover_meetups_screen.dart` | Meetup discovery UI |
| `my_meets_screen.dart` | User's meetups |
| `feed_screen.dart` | Social feed |
| `chat_detail_screen.dart` | Chat UI |
| `meetup_repository.dart` | Meetup API calls |

---

## 🐳 Docker Commands

```powershell
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Restart a specific service
docker-compose restart postgres
```

---

## 🔧 Troubleshooting

### Build Errors

**file_picker plugin error:**
```powershell
# Upgrade file_picker to latest version
flutter pub upgrade file_picker
```

**Gradle/Java version mismatch:**
Add to `android/gradle.properties`:
```properties
android.javaCompile.suppressSourceTargetDeprecationWarning=true
```

### Connection Issues

- Ensure backend is running on `http://localhost:8080`
- For Android: Use computer's IP address instead of `localhost`
- Check firewall settings

---

## 📄 License

Private project. All rights reserved.

---

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

---

Made with ❤️ by FYN Team
