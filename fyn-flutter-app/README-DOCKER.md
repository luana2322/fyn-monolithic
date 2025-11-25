# Docker Deployment Guide

## Build và chạy với Docker

### Cách 1: Sử dụng Docker Compose (Khuyên dùng)

```bash
# Build và chạy
docker-compose up -d

# Xem logs
docker-compose logs -f

# Dừng
docker-compose down

# Rebuild
docker-compose up -d --build
```

App sẽ chạy tại: http://localhost:3000

### Cách 2: Sử dụng Docker trực tiếp

```bash
# Build image
docker build -t fyn-flutter-web .

# Chạy container
docker run -d -p 3000:80 --name fyn-flutter-web fyn-flutter-web

# Xem logs
docker logs -f fyn-flutter-web

# Dừng và xóa container
docker stop fyn-flutter-web
docker rm fyn-flutter-web
```

### Cấu hình môi trường

Để thay đổi BASE_URL (API endpoint), sửa trong `docker-compose.yml`:

```yaml
environment:
  - BASE_URL=http://your-api-url:8080
```

Hoặc khi chạy Docker trực tiếp:

```bash
docker run -d -p 3000:80 \
  -e BASE_URL=http://your-api-url:8080 \
  --name fyn-flutter-web \
  fyn-flutter-web
```

### Production Deployment

1. **Build image:**
   ```bash
   docker build -t fyn-flutter-web:latest .
   ```

2. **Tag và push lên registry (nếu cần):**
   ```bash
   docker tag fyn-flutter-web:latest your-registry/fyn-flutter-web:latest
   docker push your-registry/fyn-flutter-web:latest
   ```

3. **Deploy trên server:**
   ```bash
   docker pull your-registry/fyn-flutter-web:latest
   docker run -d -p 80:80 --name fyn-flutter-web --restart unless-stopped fyn-flutter-web:latest
   ```

### Lưu ý

- Đảm bảo backend API đang chạy và có thể truy cập được
- Nếu backend chạy trên Docker khác, sử dụng cùng network hoặc expose port
- Để thay đổi port, sửa trong `docker-compose.yml`: `"3000:80"` → `"YOUR_PORT:80"`

