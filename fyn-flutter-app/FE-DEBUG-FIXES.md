# Frontend Code Fixes - Connection Issues

## Các vấn đề đã được sửa

### 1. ✅ Error Handling khi load .env
**File:** `lib/main.dart`
- Thêm try-catch khi load .env file
- Thêm logging để debug
- Set default BASE_URL nếu .env không load được

### 2. ✅ Logging BASE_URL
**File:** `lib/config/app_config.dart`
- Thêm logging để xem BASE_URL được load như thế nào
- Giúp debug khi BASE_URL không đúng

### 3. ✅ Logging trong ApiClient
**File:** `lib/core/network/api_client.dart`
- Log baseUrl khi khởi tạo ApiClient
- Giúp xác nhận BASE_URL được set đúng

### 4. ✅ Cải thiện Error Logging
**File:** `lib/core/network/interceptors.dart`
- Log full URL (baseUrl + path) trong requests
- Thêm thông báo cụ thể cho connection timeout và connection error
- Giúp debug lỗi kết nối dễ dàng hơn

## Cách debug

### 1. Chạy script debug:
```powershell
.\debug-api-config.ps1
```

### 2. Kiểm tra console logs:
Khi chạy app, xem console để thấy:
- `✓ Loaded .env file` hoặc `⚠ Failed to load .env file`
- `BASE_URL: http://localhost:8080`
- `AppConfig.baseUrl: http://localhost:8080`
- `ApiClient initialized with baseUrl: http://localhost:8080`
- `REQUEST[POST] => http://localhost:8080/api/auth/login`

### 3. Kiểm tra Browser DevTools:
1. Mở DevTools (F12)
2. Vào tab Console
3. Xem các log messages
4. Vào tab Network
5. Xem requests có đúng URL không

## Các vấn đề thường gặp

### Vấn đề 1: BASE_URL không được load
**Triệu chứng:**
- Console log: `⚠ Failed to load .env file`
- Requests đi đến default URL

**Giải pháp:**
1. Kiểm tra file .env có tồn tại không
2. Kiểm tra .env có trong pubspec.yaml assets không
3. Rebuild app: `flutter clean && flutter pub get && flutter run`

### Vấn đề 2: Connection Timeout
**Triệu chứng:**
- Console log: `⚠ Connection timeout`
- Error: `ERR_CONNECTION_TIMED_OUT`

**Giải pháp:**
1. Kiểm tra backend có đang chạy không:
   ```powershell
   docker ps | findstr fyn-backend
   ```
2. Kiểm tra port 8080:
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 8080
   ```
3. Khởi động backend nếu chưa chạy:
   ```powershell
   cd ..\fyn-monolithic
   docker compose up -d fyn-backend
   ```

### Vấn đề 3: BASE_URL sai
**Triệu chứng:**
- Requests đi đến URL sai
- Console log hiển thị BASE_URL không đúng

**Giải pháp:**
1. Kiểm tra .env file:
   ```powershell
   Get-Content .env
   ```
2. Sửa BASE_URL nếu cần:
   ```powershell
   Set-Content -Path .env -Value "BASE_URL=http://localhost:8080"
   ```
3. Rebuild Docker image:
   ```powershell
   docker compose build --build-arg BASE_URL=http://localhost:8080
   docker compose up -d
   ```

## Checklist khi gặp lỗi kết nối

- [ ] Backend đang chạy (`docker ps | findstr fyn-backend`)
- [ ] Port 8080 accessible (`curl http://localhost:8080`)
- [ ] .env file tồn tại và có BASE_URL đúng
- [ ] .env được include trong pubspec.yaml
- [ ] Console logs hiển thị BASE_URL đúng
- [ ] Network tab trong DevTools hiển thị requests đúng URL
- [ ] Không có CORS errors trong console

## Test nhanh

1. **Test backend:**
   ```powershell
   curl http://localhost:8080/api/auth/login -Method POST -ContentType "application/json" -Body '{"identifier":"test","password":"test"}'
   ```

2. **Test frontend:**
   - Mở app trong browser
   - Mở DevTools (F12)
   - Thử đăng nhập
   - Xem console và network tabs

## Liên hệ

Nếu vẫn gặp vấn đề sau khi kiểm tra các điểm trên:
1. Chạy `.\debug-api-config.ps1`
2. Chụp screenshot console logs
3. Chụp screenshot network tab
4. Kiểm tra backend logs: `docker logs fyn-backend --tail 50`

