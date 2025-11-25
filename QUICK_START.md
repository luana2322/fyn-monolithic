# 🚀 Quick Start Guide

Hướng dẫn nhanh để chạy Frontend và Backend trên local.

## ⚡ Cách nhanh nhất

### 1. Start Backend Services (Database & MinIO)

```powershell
cd fyn-monolithic
docker-compose up -d fyn-postgres fyn-minio
```

### 2. Start Backend

**Cách 1: Sử dụng script (Khuyên dùng)**
```powershell
cd fyn-monolithic
.\start-local.ps1
```

**Cách 2: Chạy thủ công**
```powershell
cd fyn-monolithic
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

Backend sẽ chạy tại: **http://localhost:8080**

### 3. Start Frontend

**Cách 1: Sử dụng script (Khuyên dùng)**
```powershell
cd fyn-flutter-app
.\start-local.ps1
```

**Cách 2: Chạy thủ công**
```powershell
cd fyn-flutter-app
flutter pub get
flutter run -d chrome --web-port=3000
```

Frontend sẽ chạy tại: **http://localhost:3000**

---

## 📋 Checklist trước khi chạy

- [ ] Java 21 đã cài đặt
- [ ] Maven 3.8+ đã cài đặt
- [ ] Flutter 3.0+ đã cài đặt
- [ ] Docker đã cài đặt (cho PostgreSQL và MinIO)
- [ ] Port 8080 chưa bị chiếm
- [ ] Port 3000 chưa bị chiếm (hoặc port khác cho Flutter)

---

## 🔍 Kiểm tra nhanh

### Backend đang chạy?
```powershell
curl http://localhost:8080/health
# Hoặc mở browser: http://localhost:8080/health
```

### Frontend đang chạy?
Mở browser: http://localhost:3000

### Database đang chạy?
```powershell
docker ps | findstr postgres
```

---

## 🛠️ Troubleshooting nhanh

### Backend không chạy
1. Kiểm tra Java: `java -version`
2. Kiểm tra PostgreSQL: `docker ps | findstr postgres`
3. Kiểm tra port 8080: `netstat -ano | findstr :8080`

### Frontend không kết nối Backend
1. Kiểm tra file `.env`: `BASE_URL=http://localhost:8080`
2. Kiểm tra Backend đang chạy: `curl http://localhost:8080/health`
3. Xem Console trong browser (F12)

---

## 📚 Chi tiết hơn

Xem file `LOCAL_SETUP.md` để biết hướng dẫn chi tiết và troubleshooting đầy đủ.

