# 🚀 Hướng dẫn chạy FE và BE trên Local (Đơn giản)

## ⚡ Quick Start

### 1. Start Database Services (PostgreSQL + MinIO)

```powershell
cd E:\DACN\fyn-monolithic
docker-compose up -d fyn-postgres fyn-minio
```

### 2. Start Backend

```powershell
cd E:\DACN\fyn-monolithic
.\start-local.ps1
```

**Hoặc chạy thủ công:**
```powershell
cd E:\DACN\fyn-monolithic
.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev
```

✅ Backend sẽ chạy tại: **http://localhost:8080**

### 3. Start Frontend

Mở terminal mới:

```powershell
cd E:\DACN\fyn-flutter-app
.\start-local.ps1
```

**Hoặc chạy thủ công:**
```powershell
cd E:\DACN\fyn-flutter-app
flutter pub get
flutter run -d chrome --web-port=3000
```

✅ Frontend sẽ chạy tại: **http://localhost:3000**

---

## 📝 Lưu ý quan trọng

1. **Chạy Backend TRƯỚC**, sau đó mới chạy Frontend
2. **Đảm bảo PostgreSQL và MinIO đang chạy** (qua Docker)
3. **File `.env`** trong `fyn-flutter-app` phải có: `BASE_URL=http://localhost:8080`

---

## 🔍 Kiểm tra

### Backend đang chạy?
```powershell
curl http://localhost:8080/health
# Hoặc mở: http://localhost:8080/health
```

### Frontend đang chạy?
Mở browser: **http://localhost:3000**

---

## 🛠️ Nếu gặp lỗi

### Maven không tìm thấy
- Script sẽ tự động dùng Maven wrapper (`mvnw.cmd`)
- Không cần cài Maven nếu có wrapper

### Java không tìm thấy
- Cài Java 21: https://www.oracle.com/java/technologies/downloads/#java21
- Hoặc dùng OpenJDK 21

### Flutter không tìm thấy
- Cài Flutter: https://flutter.dev/docs/get-started/install
- Chạy `flutter doctor` để kiểm tra

### Port bị chiếm
```powershell
# Kiểm tra port 8080
netstat -ano | findstr :8080

# Kiểm tra port 3000
netstat -ano | findstr :3000
```

---

## 📚 Chi tiết

Xem `LOCAL_SETUP.md` để biết hướng dẫn chi tiết hơn.

