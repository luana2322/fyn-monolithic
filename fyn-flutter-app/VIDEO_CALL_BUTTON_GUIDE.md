# 📞 Hướng dẫn sử dụng Video Call Button

## 🎯 Tính năng đã thêm

### Button Video Call trong Chat

Đã thêm **2 buttons** vào AppBar của màn hình chat:

1. **📞 Voice Call Button** (Icon `Icons.call`)
   - Vị trí: AppBar, bên trái button video
   - Chức năng: Placeholder (chưa implement)
   - Khi click: Hiện thông báo "Chức năng đang phát triển"

2. **🎥 Video Call Button** (Icon `Icons.videocam`)
   - Vị trí: AppBar, bên phải button voice
   - Chức năng: Khởi tạo video call
   - Khi click: Hiện dialog xác nhận

---

## 🚀 Cách sử dụng

### Bước 1: Mở Chat
1. Vào màn hình Messages/Chat
2. Chọn một cuộc hội thoại (conversation)
3. Mở màn hình chat detail

### Bước 2: Khởi động Video Call
1. Tại màn hình chat, nhìn lên **AppBar**
2. Thấy 2 icons bên phải:
   - 📞 Phone icon (voice call)
   - 🎥 Video icon (video call)
3. Tap vào **video icon** 🎥

### Bước 3: Xác nhận cuộc gọi
- Một dialog sẽ xuất hiện với:
  - Tiêu đề: "Gọi Video"
  - Nội dung: "Bắt đầu cuộc gọi video với [Tên người dùng]?"
  - Info box màu xanh: "Chức năng đang phát triển, cần setup Firebase"
  - 2 buttons:
    - **Hủy**: Đóng dialog
    - **Gọi ngay**: Tiếp tục

### Bước 4: Xem Placeholder
Nếu chọn "Gọi ngay":
1. Hiện SnackBar màu xanh: "Đang kết nối..."
2. Sau 2 giây, hiện SnackBar màu cam: "Tính năng sẽ sớm hoàn thiện!"

---

## 📁 Files đã thay đổi

### 1. [pubspec.yaml](file:///d:/fyn-monolithic/fyn-flutter-app/pubspec.yaml)

**Thêm packages:**
```yaml
# WebRTC for video calls
flutter_webrtc: ^0.11.7

# Firebase for signaling
firebase_core: ^3.8.1
firebase_firestore: ^5.5.2

# Permissions
permission_handler: ^11.3.1
```

### 2. [chat_detail_screen.dart](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/message/presentation/screens/chat_detail_screen.dart)

**Changes:**

#### A. AppBar Actions (dòng 152-175)
```dart
actions: [
  // Voice call button
  IconButton(
    icon: const Icon(Icons.call),
    tooltip: 'Gọi thoại',
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(...);
    },
  ),
  
  // Video call button
  IconButton(
    icon: const Icon(Icons.videocam),
    tooltip: 'Gọi video',
    onPressed: _initiateVideoCall,
  ),
  const SizedBox(width: 8),
],
```

#### B. _initiateVideoCall Method (dòng 105-191)
```dart
Future<void> _initiateVideoCall() async {
  // Show confirmation dialog
  final shouldProceed = await showDialog<bool>(...);
  
  if (shouldProceed == true) {
    // Show connecting message
    ScaffoldMessenger.of(context).showSnackBar(...);
    
    // Simulate connection
    await Future.delayed(const Duration(seconds: 2));
    
    // Show placeholder message
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

---

## 🔧 Cài đặt

### Install Dependencies
```bash
cd fyn-flutter-app
flutter pub get
```

### Chạy app
```bash
# Web
flutter run -d chrome

# Mobile
flutter run
```

---

## 🎨 UI Preview

### AppBar với Call Buttons
```
┌─────────────────────────────────────────┐
│ ← Avatar  User Name        📞  🎥       │
└─────────────────────────────────────────┘
```

### Confirmation Dialog
```
┌─────────────────────────────────────────┐
│              Gọi Video                  │
│                                         │
│ Bắt đầu cuộc gọi video với User Name?  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ℹ️  Chức năng video call đang trong │ │
│ │     giai đoạn phát triển. Cần setup│ │
│ │     Firebase trước.                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│              [Hủy]  [🎥 Gọi ngay]      │
└─────────────────────────────────────────┘
```

### SnackBar Messages
1. **Connecting** (màu xanh lá):
   ```
   ⭕ Đang kết nối với User Name...
   ```

2. **Placeholder** (màu cam):
   ```
   Tính năng video call sẽ sớm được hoàn thiện!
   ```

---

## 📋 Next Steps để hoàn thiện Video Call

### 1. Setup Firebase
- [ ] Tạo Firebase project
- [ ] Add Android app
- [ ] Add iOS app
- [ ] Add Web app
- [ ] Enable Firestore
- [ ] Download config files

### 2. Implement WebRTC Services
- [ ] Create `WebRTCService` class
- [ ] Create `SignalingService` class
- [ ] Handle permissions

### 3. Create Call Screens
- [ ] Outgoing call screen
- [ ] Incoming call screen
- [ ] Active call screen

### 4. Integrate Call Flow
- [ ] Replace placeholder with actual call initiation
- [ ] Add call state management
- [ ] Add call listener service

---

## 🔍 Testing

### Test Video Call Button
1. ✅ Run app: `flutter run -d chrome`
2. ✅ Login to app
3. ✅ Go to Messages tab
4. ✅ Open a conversation
5. ✅ Look for video icon in AppBar
6. ✅ Tap video icon
7. ✅ Confirm dialog appears
8. ✅ Tap "Gọi ngay"
9. ✅ See "Đang kết nối..." message
10. ✅ See "Tính năng sẽ sớm hoàn thiện!" message

### Test Voice Call Button
1. ✅ Tap phone icon
2. ✅ See "Chức năng đang phát triển" message

---

## 💡 Notes

### Current Status
- ✅ UI buttons added
- ✅ Dialog interaction working
- ✅ Placeholder flow complete
- ⚠️ Actual video call NOT implemented yet
- ⚠️ Requires Firebase setup
- ⚠️ Requires WebRTC service implementation

### Recommendations
1. **Setup Firebase first** before implementing actual call logic
2. **Test on mobile device** for better camera/microphone testing
3. **Use HTTPS or localhost** for web (WebRTC requirement)

---

## 📚 Documentation

- **Implementation Plan**: [`implementation_plan.md`](file:///C:/Users/nguye/.gemini/antigravity/brain/dc8396fb-16e0-45b8-96ea-f750f2f91349/implementation_plan.md)
- **Task Checklist**: [`task.md`](file:///C:/Users/nguye/.gemini/antigravity/brain/dc8396fb-16e0-45b8-96ea-f750f2f91349/task.md)

---

## 🆘 Troubleshooting

### Button không hiện
- Kiểm tra đã chạy `flutter pub get` chưa
- Restart app

### Dialog không mở
- Kiểm tra context có mounted không
- Check console for errors

### Package conflicts
```bash
flutter pub get
flutter clean
flutter pub get
```

---

**Status**: Button đã hoàn thành! Sẵn sàng cho việc implement logic video call thực sự. 🎉
