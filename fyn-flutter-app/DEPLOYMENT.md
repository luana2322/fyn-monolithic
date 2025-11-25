# Hướng dẫn Deploy Full Stack

## Kiến trúc

- **Backend**: Spring Boot chạy trên Docker (port 8080)
- **Frontend**: Flutter Web chạy trên Docker (port 3000)
- **Database**: PostgreSQL (port 5432)
- **Storage**: MinIO (port 9000-9001)

## Cách chạy Full Stack

### Bước 1: Start Backend Services

```powershell
cd ..\fyn-monolithic
docker-compose up -d
```

Kiểm tra backend đã chạy:
```powershell
docker ps
# Backend sẽ chạy tại http://localhost:8080
```

### Bước 2: Build và Start Frontend

```powershell
cd ..\fyn-flutter-app
docker-compose build
docker-compose up -d
```

### Bước 3: Kiểm tra

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)

## Quản lý Services

### Xem logs

```powershell
# Backend logs
cd ..\fyn-monolithic
docker-compose logs -f fyn-backend

# Frontend logs
cd ..\fyn-flutter-app
docker-compose logs -f flutter-web
```

### Dừng services

```powershell
# Dừng frontend
cd ..\fyn-flutter-app
docker-compose down

# Dừng backend
cd ..\fyn-monolithic
docker-compose down
```

### Restart services

```powershell
# Restart backend
cd ..\fyn-monolithic
docker-compose restart fyn-backend

# Restart frontend
cd ..\fyn-flutter-app
docker-compose restart flutter-web
```

## Cấu hình

### Thay đổi BASE_URL cho Frontend

Sửa trong `fyn-flutter-app/docker-compose.yml`:

```yaml
build:
  args:
    - BASE_URL=http://your-backend-url:8080
```

Sau đó rebuild:
```powershell
docker-compose up -d --build
```

### Thay đổi Ports

**Frontend port** (mặc định 3000):
```yaml
ports:
  - "YOUR_PORT:80"
```

**Backend port** (mặc định 8080):
Sửa trong `fyn-monolithic/docker-compose.yml`

## Troubleshooting

### Frontend không kết nối được Backend

1. Kiểm tra backend đang chạy:
   ```powershell
   docker ps | findstr fyn-backend
   ```

2. Test API:
   ```powershell
   curl http://localhost:8080/health
   ```

3. Kiểm tra BASE_URL trong frontend:
   - Mở browser console
   - Kiểm tra network requests

### Rebuild Frontend sau khi có thay đổi code

```powershell
cd fyn-flutter-app
docker-compose up -d --build
```

### Xóa và rebuild từ đầu

```powershell
# Frontend
cd fyn-flutter-app
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Backend
cd ..\fyn-monolithic
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Production Deployment

### 1. Build images

```powershell
# Backend
cd fyn-monolithic
docker build -t fyn-backend:latest .

# Frontend
cd ..\fyn-flutter-app
docker build -t fyn-flutter-web:latest .
```

### 2. Tag và push lên registry (nếu cần)

```powershell
docker tag fyn-backend:latest your-registry/fyn-backend:latest
docker tag fyn-flutter-web:latest your-registry/fyn-flutter-web:latest

docker push your-registry/fyn-backend:latest
docker push your-registry/fyn-flutter-web:latest
```

### 3. Deploy trên server

- Sử dụng docker-compose hoặc Kubernetes
- Cấu hình reverse proxy (nginx/traefik) cho production
- Setup SSL/TLS certificates
- Cấu hình environment variables cho production

