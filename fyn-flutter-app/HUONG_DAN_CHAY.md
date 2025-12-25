# Hướng dẫn chạy FYN Flutter App

## 📋 Yêu cầu trước khi chạy

- **Flutter SDK**: >= 3.0.0
- **Backend API**: Đang chạy tại `http://localhost:8080`
- **Chrome**: (cho Web)
- **Android Studio + Emulator**: (cho Android)

---

## 🌐 Chạy trên Web

### Bước 1: Cài đặt dependencies

```bash
cd fyn-flutter-app
flutter pub get
```

### Bước 2: Chạy ứng dụng

```bash
flutter run -d chrome
```

Hoặc sử dụng script PowerShell có sẵn:

```powershell
.\run-web.ps1
```

> **Lưu ý**: Web sẽ tự động kết nối đến `http://localhost:8080`

---

## 📱 Chạy trên Android

### Bước 1: Khởi động Android Emulator

Mở Android Studio → Device Manager → Start emulator

Hoặc dùng command:

```bash
flutter emulators --launch <emulator_id>
```

### Bước 2: Cài đặt dependencies

```bash
cd fyn-flutter-app
flutter pub get
```

### Bước 3: Chạy ứng dụng

```bash
flutter run
```

> **Lưu ý**: Android Emulator tự động sử dụng `http://10.0.2.2:8080` để kết nối đến backend (localhost của máy host)

### Bước 4: Build APK (tùy chọn)

```bash
flutter build apk
```

File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔧 Cấu hình Base URL (nếu cần)

App tự động detect platform và sử dụng URL phù hợp:

| Platform | Base URL |
|----------|----------|
| Web | `http://localhost:8080` |
| Android Emulator | `http://10.0.2.2:8080` |
| iOS Simulator | `http://localhost:8080` |

Xem chi tiết tại: `lib/config/app_config.dart`

---

## ❌ Xử lý lỗi thường gặp

### Lỗi kết nối API

```bash
# Kiểm tra backend đang chạy
curl http://localhost:8080/health
```

### Lỗi dependencies

```bash
flutter clean
flutter pub get
flutter run
```

### Kiểm tra devices có sẵn

```bash
flutter devices
```

---

## ⚡ Lệnh nhanh

| Mục đích | Lệnh |
|----------|------|
| Chạy Web | `flutter run -d chrome` |
| Chạy Android | `flutter run -d emulator-5554` |
| Build APK | `flutter build apk` |
| Build Web | `flutter build web` |
| Clean project | `flutter clean` |
