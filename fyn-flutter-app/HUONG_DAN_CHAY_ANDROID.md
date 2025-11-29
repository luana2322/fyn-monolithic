# Hướng Dẫn Chạy Flutter App Trên Android Simulator

## 📋 Yêu Cầu

1. **Flutter SDK** (>= 3.0.0) - Đã cài đặt ✓
2. **Android Studio** với Android SDK
3. **Android Emulator** đã tạo và đang chạy
4. **Backend Spring Boot** đang chạy trên port 8080

## 🚀 Các Bước Chạy App

### Bước 1: Kiểm tra Android Emulator

Đảm bảo Android Emulator đang chạy:

```bash
flutter devices
```

Bạn sẽ thấy output như:
```
sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64
```

Nếu không có emulator, mở Android Studio và tạo/khởi động emulator.

### Bước 2: Cấu hình API URL

File `.env` đã được tạo với nội dung:
```env
BASE_URL=http://10.0.2.2:8080
```

**Lưu ý quan trọng:**
- **Android Emulator**: Sử dụng `http://10.0.2.2:8080` (địa chỉ đặc biệt để truy cập localhost của máy host)
- **Physical Device**: Sử dụng IP của máy tính (ví dụ: `http://192.168.1.100:8080`)
- **iOS Simulator**: Sử dụng `http://localhost:8080`

### Bước 3: Cài đặt Dependencies

```bash
cd fyn-flutter-app
flutter pub get
```

### Bước 4: Generate Code (nếu cần)

Một số models sử dụng code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Bước 5: Chạy App Trên Android Emulator

#### Cách 1: Chạy trực tiếp (khuyến nghị)

```bash
flutter run -d emulator-5554
```

Hoặc nếu chỉ có 1 emulator đang chạy:

```bash
flutter run
```

#### Cách 2: Chọn device từ danh sách

```bash
flutter run
# Sau đó chọn device từ danh sách hiển thị
```

#### Cách 3: Chạy với hot reload

```bash
flutter run -d emulator-5554
```

Trong khi app đang chạy:
- Nhấn `r` để hot reload
- Nhấn `R` để hot restart
- Nhấn `q` để quit

## 🔧 Troubleshooting

### Lỗi: "No devices found"

**Giải pháp:**
1. Mở Android Studio
2. Tools → Device Manager
3. Khởi động emulator hoặc tạo mới

### Lỗi: "Connection refused" hoặc không kết nối được API

**Nguyên nhân:**
- Backend chưa chạy
- URL trong `.env` sai
- Firewall chặn

**Giải pháp:**
1. Kiểm tra backend đang chạy:
   ```bash
   # Trong thư mục fyn-monolithic
   mvn spring-boot:run
   ```

2. Kiểm tra `.env` file:
   ```env
   BASE_URL=http://10.0.2.2:8080
   ```

3. Kiểm tra backend có chạy trên port 8080:
   - Mở browser: `http://localhost:8080`
   - Hoặc kiểm tra trong `application.yml`

### Lỗi: "Build failed"

**Giải pháp:**
```bash
flutter clean
flutter pub get
flutter run
```

### Lỗi: "Android licenses not accepted"

**Giải pháp:**
```bash
flutter doctor --android-licenses
# Nhấn 'y' để chấp nhận tất cả licenses
```

### Lỗi: Video không load trên Android Emulator (nhưng load được trên Web)

**Nguyên nhân:**
- Thiếu INTERNET permission trong AndroidManifest.xml
- Android 9+ chặn HTTP traffic (cleartext) theo mặc định

**Giải pháp:**
Đã được fix trong `android/app/src/main/AndroidManifest.xml`:
- ✅ Thêm `<uses-permission android:name="android.permission.INTERNET"/>`
- ✅ Thêm `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`
- ✅ Thêm `android:usesCleartextTraffic="true"` trong `<application>`

**Sau khi fix, rebuild app:**
```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Kiểm Tra App Đang Chạy

Sau khi chạy thành công, bạn sẽ thấy:
- App được cài đặt và mở trên Android Emulator
- Terminal hiển thị logs
- Có thể sử dụng hot reload (`r`) để cập nhật code

## 🔗 Kết Nối Với Backend

Đảm bảo:
1. Backend Spring Boot đang chạy trên `http://localhost:8080`
2. File `.env` có `BASE_URL=http://10.0.2.2:8080`
3. Emulator có thể truy cập internet

## 📝 Lệnh Hữu Ích

```bash
# Xem danh sách devices
flutter devices

# Xem danh sách emulators
flutter emulators

# Chạy trên device cụ thể
flutter run -d <device_id>

# Build APK
flutter build apk

# Build APK release
flutter build apk --release

# Xem logs
flutter logs
```

## ✅ Checklist Trước Khi Chạy

- [ ] Flutter SDK đã cài đặt
- [ ] Android SDK đã cài đặt
- [ ] Android Emulator đang chạy
- [ ] File `.env` đã được tạo với `BASE_URL=http://10.0.2.2:8080`
- [ ] Dependencies đã cài đặt (`flutter pub get`)
- [ ] Backend Spring Boot đang chạy trên port 8080
- [ ] Không có lỗi trong `flutter doctor`

---

**Lưu ý:** Đảm bảo backend API đang chạy trước khi test các tính năng trong app!

