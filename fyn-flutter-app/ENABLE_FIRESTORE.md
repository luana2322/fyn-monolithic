# 🔥 Enable Firestore Database - REQUIRED

## ⚠️ QUAN TRỌNG

Trước khi video call hoạt động, bạn **BẮT BUỘC** phải enable Firestore Database trong Firebase Console.

---

## 📋 Các bước thực hiện

### Bước 1: Vào Firebase Console

1. Mở https://console.firebase.google.com
2. Chọn project: **fyn-7517d**
3. Sidebar bên trái → Click **"Firestore Database"**

### Bước 2: Create Database

1. Click button **"Create database"**
2. **Location**: Chọn **asia-southeast1 (Singapore)**
3. **Secure rules**: Chọn **"Start in production mode"**
4. Click **"Enable"**
5. Đợi vài giây để database được tạo

### Bước 3: Setup Security Rules

1. Trong Firestore Database, tab **"Rules"**
2. Replace toàn bộ với code sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all read/write for testing (⚠️ FOR TESTING ONLY!)
    match /calls/{callId} {
      allow read, write: if true;
    }
    
    match /calls/{callId}/callerCandidates/{candidateId} {
      allow read, write: if true;
    }
    
    match /calls/{callId}/calleeCandidates/{candidateId} {
      allow read, write: if true;
    }
  }
}
```

3. Click **"Publish"**

⚠️ **Note**: `if true` cho phép mọi người truy cập - CHỈ dùng để test!

---

## ✅ Verify

Sau khi setup xong:

1. Trong Firestore Database
2. Bạn sẽ thấy **"Data"** tab
3. Collection chưa có gì (empty)
4. Rules tab sẽ có code bạn vừa paste

---

## 🔒 Production Security Rules (sau này)

Khi deploy production, thay bằng:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users
    match /calls/{callId} {
      allow read, write: if request.auth != null;
    }
    
    match /calls/{callId}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## ❓ Troubleshooting

### "Create database" button bị disabled
- Check billing: Firebase free tier đủ dùng
- Check permissions: Bạn phải là Owner hoặc Editor

### Rules không save được  
- Check syntax (copy exact từ guide)
- Click "Publish" button

### Location không có asia-southeast1
- Chọn location gần nhất (asia-east, us-central)

---

**Sau khi xong**, báo lại để tôi tiếp tục implement video call services! 🚀
