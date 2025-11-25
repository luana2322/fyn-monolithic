# Hướng dẫn chạy Frontend và Backend trên Local

## 📋 Yêu cầu hệ thống

### Backend (Spring Boot)
- Java 21
- Maven 3.8+
- PostgreSQL 16 (hoặc Docker để chạy PostgreSQL)
- MinIO (hoặc Docker để chạy MinIO)

### Frontend (Flutter)
- Flutter SDK 3.0+
- Dart 3.0+
- Node.js (cho web development)

---

## 🔧 Setup Backend

### Bước 1: Kiểm tra Java và Maven

```powershell
java -version
# Cần Java 21

mvn -version
# Cần Maven 3.8+
```

### Bước 2: Setup Database (PostgreSQL)

**Option 1: Sử dụng Docker (Khuyên dùng)**

```powershell
cd fyn-monolithic
docker-compose up -d fyn-postgres fyn-minio
```

**Option 2: Cài đặt PostgreSQL local**

1. Download và cài PostgreSQL 16
2. Tạo database: `fyn-monolithic`
3. User: `postgres`, Password: `postgres`
4. Port: `5432`

### Bước 3: Setup MinIO (Object Storage)

**Option 1: Sử dụng Docker**

```powershell
cd fyn-monolithic
docker-compose up -d fyn-minio
```

MinIO sẽ chạy tại:
- API: http://localhost:9000
- Console: http://localhost:9001
- Access Key: `minioadmin`
- Secret Key: `minioadmin`

**Option 2: Cài đặt MinIO local**

1. Download từ https://min.io/download
2. Chạy MinIO server
3. Tạo bucket `fyn-data`

### Bước 4: Cấu hình Backend

Sửa file `fyn-monolithic/src/main/resources/application-dev.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fyn-monolithic
    username: postgres
    password: postgres

minio:
  endpoint: http://localhost:9000
  access-key: minioadmin
  secret-key: minioadmin
  bucket: fyn-data
```

### Bước 5: Chạy Backend

```powershell
cd fyn-monolithic

# Build project
mvn clean install

# Chạy với profile dev
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Hoặc chạy JAR file
java -jar target/fyn-monolithic-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

Backend sẽ chạy tại: **http://localhost:8080**

**Kiểm tra backend đã chạy:**
```powershell
curl http://localhost:8080/health
# Hoặc mở browser: http://localhost:8080/health
```

---

## 🎨 Setup Frontend

### Bước 1: Kiểm tra Flutter

```powershell
flutter --version
# Cần Flutter 3.0+

flutter doctor
# Kiểm tra các dependencies
```

### Bước 2: Cài đặt dependencies

```powershell
cd fyn-flutter-app

# Cài đặt packages
flutter pub get

# Generate code (cho JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Bước 3: Cấu hình Environment

Tạo file `.env` trong thư mục `fyn-flutter-app`:

```env
BASE_URL=http://localhost:8080
```

### Bước 4: Chạy Frontend

**Option 1: Chạy trên Web (Khuyên dùng cho development)**

```powershell
cd fyn-flutter-app

# Chạy trên Chrome
flutter run -d chrome

# Hoặc chạy trên web server
flutter run -d web-server --web-port=3000
```

**Option 2: Chạy trên Mobile/Desktop**

```powershell
# Xem devices có sẵn
flutter devices

# Chạy trên device cụ thể
flutter run -d <device-id>
```

Frontend sẽ chạy tại: **http://localhost:3000** (hoặc port mặc định)

---

## 🚀 Chạy Full Stack

### Cách 1: Chạy từng terminal riêng

**Terminal 1 - Backend:**
```powershell
cd fyn-monolithic
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

**Terminal 2 - Frontend:**
```powershell
cd fyn-flutter-app
flutter run -d chrome
```

### Cách 2: Sử dụng Scripts

**Backend Script (`start-backend.ps1`):**
```powershell
cd fyn-monolithic
Write-Host "Starting Backend..." -ForegroundColor Yellow
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

**Frontend Script (`start-frontend.ps1`):**
```powershell
cd fyn-flutter-app
Write-Host "Starting Frontend..." -ForegroundColor Yellow
flutter run -d chrome
```

---

## 🔍 Kiểm tra và Debug

### Backend

**Xem logs:**
- Logs hiển thị trực tiếp trong terminal
- Log file: `fyn-monolithic/logs/application.log`

**Test API:**
```powershell
# Health check
curl http://localhost:8080/health

# Test với Postman/Insomnia
# Import collection từ API_DOCUMENTATION.md
```

**Database:**
```powershell
# Kết nối PostgreSQL
psql -U postgres -d fyn-monolithic -h localhost

# Hoặc dùng pgAdmin
```

### Frontend

**Hot Reload:**
- Nhấn `r` trong terminal để hot reload
- Nhấn `R` để hot restart
- Nhấn `q` để quit

**Debug:**
- Mở Chrome DevTools (F12)
- Xem Console logs
- Xem Network tab để kiểm tra API calls

**Flutter DevTools:**
```powershell
# Mở DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## ⚙️ Cấu hình nâng cao

### Backend - Thay đổi Port

Sửa `application-dev.yml`:
```yaml
server:
  port: 8080  # Thay đổi port ở đây
```

### Frontend - Thay đổi BASE_URL

Sửa file `.env`:
```env
BASE_URL=http://localhost:8080
```

Hoặc trong code (`lib/config/app_config.dart`):
```dart
static String get baseUrl {
  return dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
}
```

### CORS Configuration

Backend đã cấu hình CORS để cho phép tất cả origins. Nếu cần chỉnh sửa, xem file:
`fyn-monolithic/src/main/java/com/fyn_monolithic/config/CorsConfig.java`

---

## 🐛 Troubleshooting

### Backend không chạy được

1. **Kiểm tra Java version:**
   ```powershell
   java -version
   # Phải là Java 21
   ```

2. **Kiểm tra PostgreSQL đang chạy:**
   ```powershell
   docker ps | findstr postgres
   # Hoặc
   psql -U postgres -h localhost
   ```

3. **Kiểm tra port 8080 có bị chiếm:**
   ```powershell
   netstat -ano | findstr :8080
   ```

4. **Xem logs lỗi:**
   - Kiểm tra terminal output
   - Xem file `logs/application.log`

### Frontend không kết nối được Backend

1. **Kiểm tra BASE_URL:**
   - Mở file `.env`
   - Đảm bảo `BASE_URL=http://localhost:8080`

2. **Kiểm tra Backend đang chạy:**
   ```powershell
   curl http://localhost:8080/health
   ```

3. **Kiểm tra CORS:**
   - Mở Chrome DevTools (F12)
   - Xem Console có lỗi CORS không
   - Xem Network tab

4. **Clear Flutter cache:**
   ```powershell
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

### Database connection error

1. **Kiểm tra PostgreSQL:**
   ```powershell
   docker ps | findstr postgres
   ```

2. **Kiểm tra connection string:**
   - Xem `application-dev.yml`
   - Đảm bảo host, port, database name đúng

3. **Reset database:**
   ```powershell
   cd fyn-monolithic
   docker-compose down -v
   docker-compose up -d fyn-postgres
   ```

---

## 📝 Quick Start Commands

### Backend
```powershell
# Start database services
cd fyn-monolithic
docker-compose up -d fyn-postgres fyn-minio

# Run backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Frontend
```powershell
cd fyn-flutter-app
flutter pub get
flutter run -d chrome
```

---

## 🔗 URLs

- **Frontend**: http://localhost:3000 (hoặc port Flutter mặc định)
- **Backend API**: http://localhost:8080
- **API Health**: http://localhost:8080/health
- **MinIO Console**: http://localhost:9001
- **PostgreSQL**: localhost:5432

---

## 💡 Tips

1. **Hot Reload**: Frontend hỗ trợ hot reload, chỉ cần save file là tự động reload
2. **API Testing**: Sử dụng Postman hoặc Insomnia để test API
3. **Database Tools**: Sử dụng pgAdmin hoặc DBeaver để quản lý database
4. **Logs**: Luôn xem logs khi có lỗi để debug nhanh hơn
5. **Environment**: Sử dụng `.env` file để quản lý cấu hình theo môi trường

---

## 📚 Tài liệu tham khảo

- Backend API: Xem `API_DOCUMENTATION.md`
- Flutter: https://flutter.dev/docs
- Spring Boot: https://spring.io/projects/spring-boot
- PostgreSQL: https://www.postgresql.org/docs/

