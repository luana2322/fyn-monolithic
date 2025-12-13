# 🔥 Firebase Setup Guide - Web Platform

## 📋 Thông tin cần thiết

### Android Package Name
```
com.example.fyn_flutter_app
```
**Location**: `android/app/src/main/AndroidManifest.xml`

---

## 🚀 Các bước setup Firebase

### Bước 1: Tạo Firebase Project

1. Vào https://console.firebase.google.com
2. Click **"Add project"** hoặc **"Create a project"**
3. Nhập tên project: **fyn-social** (hoặc tên bạn muốn)
4. Tắt Google Analytics (optional)
5. Click **"Create project"**
6. Đợi vài giây để project được tạo

---

### Bước 2: Add Web App

1. Trong Firebase Console, vào **Project Overview**
2. Click icon **Web** (`</>`) để thêm web app
3. Nhập **App nickname**: `fyn-web`
4. ✅ Check **"Also set up Firebase Hosting"** (optional)
5. Click **"Register app"**

6. **Copy Firebase Configuration**:

Bạn sẽ thấy code như thế này:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "fyn-social.firebaseapp.com",
  projectId: "fyn-social",
  storageBucket: "fyn-social.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456"
};
```

7. **Copy toàn bộ object này!**

---

### Bước 3: Cập nhật index.html

File đã sẵn sàng tại: [`web/index.html`](file:///d:/fyn-monolithic/fyn-flutter-app/web/index.html)

**Thay thế config placeholder**:

Tìm dòng này trong `index.html`:
```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",  // ← Thay thế
  authDomain: "your-project.firebaseapp.com",  // ← Thay thế
  projectId: "your-project-id",  // ← Thay thế
  // ...
};
```

**Paste config từ Firebase Console** (bước 2):
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "fyn-social.firebaseapp.com",
  projectId: "fyn-social",
  storageBucket: "fyn-social.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456"
};
```

✅ **Save file**

---

### Bước 4: Enable Firestore Database

1. Trong Firebase Console, sidebar bên trái
2. Click **"Build"** → **"Firestore Database"**
3. Click **"Create database"**
4. Chọn location: **asia-southeast1** (Singapore) hoặc gần nhất
5. **Start mode**: Chọn **"Production mode"**
6. Click **"Enable"**

---

### Bước 5: Setup Firestore Security Rules

1. Trong Firestore, tab **"Rules"**
2. Replace với rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write calls
    match /calls/{callId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write ICE candidates
    match /calls/{callId}/callerCandidates/{candidateId} {
      allow read, write: if request.auth != null;
    }
    
    match /calls/{callId}/calleeCandidates/{candidateId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

⚠️ **Note**: Rules này yêu cầu authentication. Nếu test không có auth, dùng:
```javascript
allow read, write: if true; // ONLY FOR TESTING!
```

---

### Bước 6 (Optional): Add Android App

Nếu muốn chạy trên Android:

1. Trong Firebase Console, click icon **Android** (robot)
2. **Android package name**: `com.example.fyn_flutter_app`
3. Click **"Register app"**
4. Download `google-services.json`
5. Copy vào: `android/app/google-services.json`
6. Click **"Next"** → **"Continue to console"**

---

## ✅ Verify Setup

### Test Firebase Connection

1. Rebuild Docker hoặc run web:
```bash
cd fyn-flutter-app

# Option 1: Docker
docker-compose build
docker-compose up -d

# Option 2: Local
flutter run -d chrome
```

2. Mở browser console (F12)
3. Tìm message: **"Firebase initialized successfully!"**
4. Nếu có lỗi, check:
   - apiKey đã đúng chưa
   - projectId có khớp không
   - Firestore đã enable chưa

---

## 🎯 Tóm tắt các file cần

| Platform | File | Location | Status |
|----------|------|----------|--------|
| **Web** | Firebase config | `web/index.html` | ✅ Done (cần update config) |
| **Android** | `google-services.json` | `android/app/` | ⏳ Optional |

---

## 📝 Checklist

### Firebase Console
- [ ] Tạo Firebase project
- [ ] Add Web app
- [ ] Copy Firebase config
- [ ] Enable Firestore
- [ ] Setup security rules

### Code Updates
- [x] Thêm Firebase SDK vào `index.html`
- [ ] Paste Firebase config (thay YOUR_API_KEY...)
- [x] Save file

### Testing
- [ ] Rebuild app
- [ ] Check browser console
- [ ] Verify "Firebase initialized" message

---

## 🐛 Troubleshooting

### Lỗi: "Firebase not defined"
- Check Firebase SDK scripts đã load chưa
- Đảm bảo thứ tự: firebase-app.js trước firebase-firestore.js

### Lỗi: "Firebase: Error (auth/api-key-not-valid)"
- apiKey sai hoặc chưa thay thế
- Copy lại từ Firebase Console

### Lỗi: "Firestore permission denied"
- Check Firestore security rules
- Đảm bảo `allow read, write: if request.auth != null`
- Hoặc dùng `if true` để test

---

## 🎉 Next Steps

Sau khi Firebase setup xong:

1. ✅ Test video call button
2. ✅ Implement WebRTC services
3. ✅ Create call screens
4. ✅ Test end-to-end calling

🔥 Firebase sẵn sàng cho video calls!
