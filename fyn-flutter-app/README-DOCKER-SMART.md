# Hướng Dẫn Chạy Frontend với Smart Device Detection

## 📋 Tổng Quan

Script `start-frontend-smart.ps1` tự động kiểm tra Android emulator và chạy ứng dụng phù hợp:
- **Có Android emulator**: Chạy trên cả Android emulator VÀ web (Docker)
- **Không có emulator**: Chỉ chạy web (Docker)

## 🚀 Cách Sử Dụng

### Chạy với cấu hình mặc định

```powershell
cd fyn-flutter-app
.\start-frontend-smart.ps1
```

### Chạy với BASE_URL tùy chỉnh

```powershell
.\start-frontend-smart.ps1 -BASE_URL "http://192.168.1.100:8080"
```

## 🔍 Cách Hoạt Động

1. **Kiểm tra Android Emulator**
   - Sử dụng `adb devices` để tìm emulator đang chạy
   - Nếu không tìm thấy, sử dụng `flutter devices`
   - Nếu tìm thấy emulator, lấy device ID

2. **Khởi động Web (Docker)**
   - Luôn luôn build và start Docker container cho web
   - Web sẽ chạy tại: `http://localhost:3000`

3. **Khởi động Android (nếu có emulator)**
   - Cập nhật `.env` với `BASE_URL=http://10.0.2.2:8080` (cho Android emulator)
   - Chạy `flutter pub get` và `build_runner`
   - Chạy `flutter run` trên emulator

## 📱 Cấu Hình BASE_URL

Script tự động cấu hình BASE_URL phù hợp:
- **Web (Docker)**: Sử dụng giá trị từ tham số `-BASE_URL` (mặc định: `http://localhost:8080`)
- **Android Emulator**: Tự động đặt thành `http://10.0.2.2:8080` (địa chỉ đặc biệt để emulator truy cập host localhost)

## 🛠️ Các Lệnh Hữu Ích

### Xem logs Docker
```powershell
docker compose logs -f flutter-web
```

### Dừng Docker container
```powershell
docker compose down
```

### Kiểm tra emulator thủ công
```powershell
adb devices
# hoặc
flutter devices
```

### Chạy chỉ trên web (không kiểm tra emulator)
```powershell
docker compose up -d
```

## ⚠️ Lưu Ý

1. **Android Emulator**: Phải khởi động trước khi chạy script (hoặc script sẽ chỉ chạy web)
2. **Backend**: Đảm bảo backend Spring Boot đang chạy trên port 8080
3. **Flutter SDK**: Cần cài đặt Flutter SDK để chạy trên Android
4. **Docker**: Cần Docker Desktop đang chạy để chạy web container

## 🔧 Troubleshooting

### Lỗi: "Docker build failed"
- Kiểm tra Docker Desktop đang chạy
- Kiểm tra Dockerfile có lỗi không
- Thử: `docker compose build --no-cache`

### Lỗi: "No Android emulator detected"
- Mở Android Studio
- Tools → Device Manager
- Khởi động emulator
- Chạy lại script

### Lỗi: "Flutter not found"
- Cài đặt Flutter SDK
- Thêm Flutter vào PATH
- Chạy `flutter doctor` để kiểm tra

### Web không kết nối được backend
- Kiểm tra backend đang chạy: `http://localhost:8080`
- Kiểm tra BASE_URL trong docker-compose.yml
- Kiểm tra network: `docker network ls`

## 📝 Ví Dụ Output

### Khi có Android emulator:
```
========================================
  Starting Flutter Frontend (Smart)
========================================

Checking for Android emulator...
✓ Android emulator detected via adb
  Device ID: emulator-5554

Starting Flutter web via Docker Compose...
Building Docker image...
Starting Docker container...
✓ Flutter web started in Docker
  Web URL: http://localhost:3000

========================================
  Starting Flutter on Android Emulator
========================================

Starting Flutter app on Android emulator...
  Using device: emulator-5554
```

### Khi không có emulator:
```
========================================
  Starting Flutter Frontend (Smart)
========================================

Checking for Android emulator...
✗ No Android emulator detected

Starting Flutter web via Docker Compose...
Building Docker image...
Starting Docker container...
✓ Flutter web started in Docker
  Web URL: http://localhost:3000

========================================
  Summary
========================================
✓ Flutter web running in Docker
  URL: http://localhost:3000
```

