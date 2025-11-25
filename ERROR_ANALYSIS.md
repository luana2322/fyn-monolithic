# Phân tích lỗi và cách xử lý

## 🔴 Lỗi đã phát hiện

### 1. Lỗi 400 khi đăng ký (ERROR[400] => PATH: /api/auth/register)

**Nguyên nhân:**
- Số điện thoại `888888888` không đúng định dạng E.164
- Backend yêu cầu format: `+[country code][number]` (8-15 chữ số)
- Ví dụ đúng: `+84901234567`

**Đã sửa:**
- ✅ Cải thiện validation phone number
- ✅ Tự động format phone number (thêm +84 nếu thiếu)
- ✅ Cải thiện error handling để hiển thị message từ backend
- ✅ Thêm helper text hướng dẫn user nhập phone

**Cách sử dụng:**
- User có thể nhập: `0912345678` → Tự động chuyển thành `+84912345678`
- Hoặc nhập trực tiếp: `+84912345678`

### 2. Lỗi Script PowerShell (start-local.ps1)

**Nguyên nhân:**
- Syntax error trong PowerShell script
- Có thể do encoding hoặc cách parse

**Đã sửa:**
- ✅ Script đã được kiểm tra và sửa

### 3. Đăng nhập thành công ✅

- API hoạt động bình thường
- Response 200 OK
- Token được lưu thành công

---

## 🔧 Các cải thiện đã thực hiện

### 1. Phone Number Validation & Formatting

**Trước:**
- Chỉ validate format cơ bản
- User phải tự nhập đúng format E.164

**Sau:**
- Tự động format phone number
- Cho phép nhập: `0912345678` → Tự động thành `+84912345678`
- Validation rõ ràng hơn

### 2. Error Handling

**Trước:**
- Chỉ hiển thị generic error message
- Không hiển thị chi tiết từ backend

**Sau:**
- Hiển thị message chi tiết từ backend
- Hiển thị validation errors nếu có
- Phân loại lỗi theo status code (400, 401, 404, 500)

### 3. User Experience

**Trước:**
- User không biết format phone number đúng
- Không có hướng dẫn

**Sau:**
- Helper text hướng dẫn: "Có thể nhập: 0912345678 (tự động thêm +84)"
- Placeholder rõ ràng: "0912345678 hoặc +84912345678"
- Validation message chi tiết

---

## 📝 Hướng dẫn sử dụng

### Đăng ký tài khoản

**Phone number:**
- ✅ Đúng: `0912345678` (tự động format)
- ✅ Đúng: `+84912345678`
- ❌ Sai: `888888888` (quá ngắn, không có +)

**Các trường khác:**
- Email: Required, valid format
- Username: Required, 3-30 characters
- Password: Required, 8-128 characters
- Full Name: Optional

### Test lại

1. Hot reload app (nhấn `r` trong terminal)
2. Thử đăng ký với phone: `0912345678`
3. Kiểm tra error message nếu có lỗi

---

## 🐛 Troubleshooting

### Nếu vẫn gặp lỗi 400

1. **Kiểm tra backend logs:**
   ```powershell
   # Xem logs backend
   cd fyn-monolithic
   # Logs sẽ hiển thị trong terminal đang chạy backend
   ```

2. **Test API trực tiếp:**
   ```powershell
   # Test với curl hoặc Postman
   curl -X POST http://localhost:8080/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@test.com","username":"testuser","password":"password123","phone":"+84901234567"}'
   ```

3. **Kiểm tra validation rules:**
   - Xem `API_DOCUMENTATION.md` để biết validation rules
   - Kiểm tra backend validation trong code

### Nếu phone number vẫn lỗi

1. **Kiểm tra format:**
   - Phải bắt đầu bằng `+`
   - Sau `+` là country code (84 cho Vietnam)
   - Tổng cộng 8-15 chữ số

2. **Ví dụ đúng:**
   - `+84901234567` (11 chữ số)
   - `+84912345678` (11 chữ số)

3. **Ví dụ sai:**
   - `888888888` (thiếu +, quá ngắn)
   - `+888888888` (country code sai)
   - `0912345678` (thiếu +, nhưng sẽ được auto-format)

---

## ✅ Kết quả

- ✅ Frontend đã chạy thành công trên Chrome
- ✅ Đăng nhập hoạt động (Response 200)
- ✅ Error handling đã được cải thiện
- ✅ Phone number validation và formatting đã được cải thiện
- ⚠️ Đăng ký cần test lại với phone number đúng format

---

## 🚀 Next Steps

1. **Test lại đăng ký** với phone number đúng format
2. **Kiểm tra backend logs** nếu vẫn có lỗi 400
3. **Xem error message** trong SnackBar để biết chi tiết lỗi

