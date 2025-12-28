# 💖 FYN - Nền Tảng Hẹn Hò & Kết Nối Xã Hội Toàn Diện

Dự án **FYN** là một ứng dụng mạng xã hội và hẹn hò hiện đại, được xây dựng với kiến trúc **Monolithic Backend (Java Spring Boot)** và **Multi-platform Frontend (Flutter)**. Ứng dụng tích hợp trí tuệ nhân tạo (AI) để gợi ý nội dung và hệ thống định vị thông minh để kết nối người dùng một cách tối ưu nhất.

![Tech Stack](https://img.shields.io/badge/Java-21-orange) ![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.1-green) ![Flutter](https://img.shields.io/badge/Flutter-3.x-blue) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue) ![AI](https://img.shields.io/badge/AI-HuggingFace-yellow) ![Docker](https://img.shields.io/badge/Docker-Enabled-blue)

---

## 📱 Hình Ảnh Ứng Dụng (Screenshots)

### 🔐 Khởi Đầu & Bảo Mật
<p align="center">
  <img src="fyn-monolithic/img/z7373925443629_0fd31585711b4b072e955a29b003874c.jpg" width="200" title="Đăng nhập"/>
  <img src="fyn-monolithic/img/z7373925445064_8793432c5d333365f286e4a4feba30fc.jpg" width="200" title="Đăng ký"/>
  <img src="fyn-monolithic/img/z7373925356088_0b2e43109bead60181d6838fa4e7b8ae.jpg" width="200" title="Mã QR cá nhân"/>
</p>

### 📱 Bảng Tin & Khám Phá
<p align="center">
  <img src="fyn-monolithic/img/z7373925435416_9a7ce70c36d6329ef43f82433e87cea5.jpg" width="200" title="Trang chủ Feed"/>
  <img src="fyn-monolithic/img/z7373925317167_8280059ca8cb2bacc35fd2738cbde2cd.jpg" width="200" title="Tạo bài viết"/>
  <img src="fyn-monolithic/img/z7373925439871_59a0e8ab841808cce4b13da70ecaec17.jpg" width="200" title="Khám phá & Bộ lọc"/>
</p>

### ❤️ Hệ Thống Meetup (Hẹn Hò)
<p align="center">
  <img src="fyn-monolithic/img/z7373925393851_1b837e94a9ab5124cf9b3d396b4f700a.jpg" width="200" title="Chọn địa điểm Meetup"/>
  <img src="fyn-monolithic/img/z7373925394854_ac0eb51e6d62482d65047b023bae823e.jpg" width="200" title="Tạo Meetup"/>
  <img src="fyn-monolithic/img/z7373925428090_846a0d2d0beb4771ad088302be799cd9.jpg" width="200" title="Danh sách Meetup"/>
</p>

### 💬 Trò Chuyện & Thông Báo
<p align="center">
  <img src="fyn-monolithic/img/z7373925344611_9d86a3686ca0b613a203c41c5157c5e5.jpg" width="200" title="Danh sách tin nhắn"/>
  <img src="fyn-monolithic/img/z7373925331570_3da57dd57c8f6216dd9eb532a3dff330.jpg" width="200" title="Chọn người nhắn tin"/>
  <img src="fyn-monolithic/img/z7373925334163_6524baf30d0383cc798d8c0f1b6f82d0.jpg" width="200" title="Phòng chat"/>
  <img src="fyn-monolithic/img/z7373925353247_5cb4f771ba1e877d3d01ccc47b082e46.jpg" width="200" title="Thông báo"/>
</p>

### 👤 Cá Nhân & Quản Trị
<p align="center">
  <img src="fyn-monolithic/img/z7373925389967_9fd5628223866c8dff6a6c8e1702e0da.jpg" width="200" title="Trang cá nhân"/>
  <img src="fyn-monolithic/img/z7373925362465_c349b1e0d85706367ebf95a7c5a1c706.jpg" width="200" title="Chỉnh sửa profile"/>
  <img src="fyn-monolithic/img/z7373925435312_d49583a081fcab31f0e0195eb4dd102a.jpg" width="200" title="Quản trị - Tổng quan"/>
</p>

### 📋 Chi Tiết Khác
<p align="center">
  <img src="fyn-monolithic/img/z7373925390059_055eb75a29091aa16f692ec11b2b34d9.jpg" width="200" title="Chi tiết Meetup"/>
  <img src="fyn-monolithic/img/z7373925396319_9c2dbeca3de33b0fb05c1a178f33c059.jpg" width="200" title="Meetup của tôi"/>
  <img src="fyn-monolithic/img/z7373925394631_5edee1ca8d4dbcbf22c107058f12ef42.jpg" width="200" title="Meetup đã tham gia"/>
</p>

---

## ✨ Tính Năng Cốt Lõi

### 📱 Frontend (Flutter App)
- **News Feed**: Luồng tin cập nhật thời gian thực, hỗ trợ hiển thị đa phương tiện (Ảnh, Video).
- **Stories**: Khoảnh khắc biến mất sau 24h, hỗ trợ tương tác nhanh.
- **Meetup System**: Tìm kiếm và tham gia các buổi gặp gỡ quanh vị trí hiện tại dựa trên GPS.
- **Real-time Chat**: Nhắn tin tức thời qua WebSocket với hỗ trợ gửi ảnh và emoji.
- **AI Recommendation**: Gợi ý bạn bè và bài viết phù hợp với sở thích cá nhân.
- **Admin Dashboard**: Giao diện quản lý báo cáo và nội dung vi phạm dành cho Admin.

### ⚙️ Backend (Spring Boot Service)
- **Hệ Thống Auth**: Xác thực dựa trên JWT với cơ chế Refresh Token bảo mật.
- **AI Engine**: Tích hợp Hugging Face API để chuyển đổi nội dung thành Vector Embedding (384-dim).
- **Spatial Search**: Sử dụng PostGIS để tính toán khoảng cách và tìm kiếm địa điểm xung quanh.
- **Cloud Storage**: Quản lý tập trung tài nguyên hình ảnh/video qua MinIO (S3 Compatible).
- **Moderation**: Hệ thống quản lý báo cáo (Report) bài viết và xử lý vi phạm linh hoạt.

---

## 🛠️ Công Nghệ Sử Dụng

### Backend
- **Ngôn ngữ**: Java 21
- **Framework**: Spring Boot 3.4.1
- **Cơ sở dữ liệu**: PostgreSQL 15 (với **PostGIS** & **PGVector**)
- **Caching**: Redis
- **Lưu trữ**: MinIO
- **Migration**: Flyway

### Frontend
- **Framework**: Flutter 3 (Hỗ trợ Web, Android, iOS)
- **Quản lý trạng thái**: Riverpod
- **Điều hướng**: GoRouter
- **Kết nối API**: Dio + Interceptors

---

## 🏗️ Kiến Trúc Hệ Thống

```mermaid
graph TD
    subgraph Client
        F[Flutter Mobile/Web]
    end
    
    subgraph Backend
        S[Spring Boot App]
        DB[(PostgreSQL + PostGIS & PGVector)]
        R[(Redis Caching)]
        M[(MinIO Storage)]
    end
    
    subgraph Services_Bên_Thứ_3
        H[Hugging Face AI]
        MAP[SerpAPI / Nominatim]
    end

    F <-->|REST API / WebSockets| S
    S <--> DB
    S <--> R
    S <--> M
    S -->|Vector Search| DB
    S -->|Embeddings| H
    S -->|Location Search| MAP
```

---

## 🚀 Hướng Dẫn Cài Đặt (Quick Start)

### 1️⃣ Yêu cầu hệ thống
- Docker Desktop
- Java 21 SDK
- Flutter SDK

### 2️⃣ Khởi chạy hạ tầng (Docker)
```powershell
cd fyn-monolithic
docker-compose up -d
```
*Lệnh này sẽ khởi chạy Postgres, Redis, và MinIO.*

### 3️⃣ Chạy Backend
```powershell
./mvnw spring-boot:run
```
*Lưu ý: Flyway sẽ tự động khởi tạo cấu trúc Database (Schema) trong lần chạy đầu tiên.*

### 4️⃣ Chạy Frontend
```powershell
cd fyn-flutter-app
flutter pub get
flutter run
```

---

## 🧠 Trí Tuệ Nhân Tạo & Định Vị

### 🤖 Logic Gợi Ý Của AI
Hệ thống sử dụng model `all-MiniLM-L6-v2` để tạo vector cho nội dung và sở thích.
```mermaid
graph TD
    A[Nội dung mới] --> B[HuggingFace API]
    B --> C{Tạo Vector 384 chiều}
    C --> D[Lưu vào PGVector]
    E[Người dùng truy vấn] --> F[Tính Cosine Similarity]
    D --> F
    F --> G[Xếp hạng gợi ý]
    G --> H[Hiển thị trên Feed]
```

---

## 🔒 Tài Khoản Demo
- **Admin**: `admin@fyn.vn` / `password`
- **User**: `luan@gmail.com` / `password`

---

## 📡 API Documentation (Nổi bật)
- **Auth**: `/api/auth/login` - Đăng nhập bảo mật JWT.
- **Feed**: `/api/posts/recommended` - Lấy bài viết dựa trên AI.
- **Meetup**: `/api/v1/meetups/discover` - Tìm kiếm buổi hẹn gần đây.

---
Made with ❤️ by FYN Team
