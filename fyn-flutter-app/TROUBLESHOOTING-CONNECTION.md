# Troubleshooting ERR_CONNECTION_TIMED_OUT

## Vấn đề
Lỗi `ERR_CONNECTION_TIMED_OUT` xảy ra khi Flutter web không thể kết nối đến backend server.

## Nguyên nhân phổ biến

### 1. Backend chưa chạy
**Kiểm tra:**
```powershell
docker ps | findstr fyn-backend
```

**Giải pháp:**
```powershell
cd ..\fyn-monolithic
docker compose up -d fyn-backend
```

### 2. BASE_URL không đúng cho web
Flutter web chạy trên browser (client-side), cần kết nối đến `http://localhost:8080`.

**Kiểm tra .env:**
```powershell
cat .env
```

**Nếu BASE_URL là `http://10.0.2.2:8080` (cho Android):**
- Đây là địa chỉ cho Android emulator
- Web cần `http://localhost:8080`

**Giải pháp:**
1. Tạo file `.env` với nội dung:
   ```
   BASE_URL=http://localhost:8080
   ```

2. Rebuild Docker image:
   ```powershell
   docker compose build --build-arg BASE_URL=http://localhost:8080
   docker compose up -d
   ```

### 3. Port 8080 không accessible
**Kiểm tra:**
```powershell
curl http://localhost:8080
# hoặc mở browser: http://localhost:8080
```

**Nếu không kết nối được:**
- Kiểm tra backend có đang chạy không
- Kiểm tra firewall có chặn port 8080 không
- Kiểm tra backend logs: `docker logs fyn-backend`

### 4. Docker network không tồn tại
**Kiểm tra:**
```powershell
docker network ls | findstr fyn-monolithic_fyn-network
```

**Nếu không có:**
```powershell
cd ..\fyn-monolithic
docker compose up -d
```

## Các bước kiểm tra nhanh

### Sử dụng script tự động:
```powershell
.\check-backend-connection.ps1
```

### Kiểm tra thủ công:

1. **Backend đang chạy?**
   ```powershell
   docker ps --filter "name=fyn-backend"
   ```

2. **Port 8080 accessible?**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 8080
   ```

3. **BASE_URL đúng?**
   ```powershell
   Get-Content .env
   ```

4. **Backend logs có lỗi?**
   ```powershell
   docker logs fyn-backend --tail 50
   ```

## Giải pháp nhanh

### Nếu chạy Flutter web trong Docker:
```powershell
# 1. Đảm bảo backend đang chạy
cd ..\fyn-monolithic
docker compose up -d fyn-backend

# 2. Kiểm tra backend
curl http://localhost:8080

# 3. Rebuild Flutter web với BASE_URL đúng
cd ..\fyn-flutter-app
docker compose build --build-arg BASE_URL=http://localhost:8080
docker compose up -d

# 4. Kiểm tra web
# Mở browser: http://localhost:3000
```

### Nếu chạy Flutter web local (không Docker):
```powershell
# 1. Tạo/update .env
echo "BASE_URL=http://localhost:8080" > .env

# 2. Đảm bảo backend đang chạy
cd ..\fyn-monolithic
docker compose up -d fyn-backend

# 3. Chạy Flutter web
flutter run -d chrome --web-port=3000
```

## CORS Issues

Nếu gặp lỗi CORS, cần cấu hình CORS trong backend Spring Boot để cho phép requests từ `http://localhost:3000`.

## Kiểm tra từ Browser DevTools

1. Mở browser DevTools (F12)
2. Vào tab Network
3. Thử đăng nhập
4. Xem request nào bị failed
5. Kiểm tra:
   - URL được gọi
   - Status code
   - Error message

## Liên hệ

Nếu vẫn gặp vấn đề, kiểm tra:
- Backend logs: `docker logs fyn-backend`
- Flutter web logs: `docker logs fyn-flutter-web`
- Network connectivity: `docker network inspect fyn-monolithic_fyn-network`

