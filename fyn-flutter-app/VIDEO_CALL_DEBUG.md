# Video Call Debug Guide

## Triển khai bug: "Can't connect video call"

### Bước 1: Kiểm tra Firebase Configuration

**Mở browser console** (F12) → Tab **Console**

Gõ vào console:
```javascript
firebase.apps.length
```

**Kết quả mong đợi**: Số > 0 (ví dụ: 1)
**Nếu = 0**: Firebase chưa được init → Cần config Firebase

---

### Bước 2: Test Firebase Connection

Trong console, gõ:
```javascript
firebase.firestore().collection('calls').get().then(
  snap => console.log('✅ Firestore OK:', snap.size, 'docs'),
  err => console.log('❌ Firestore Error:', err.message)
)
```

**Nếu thấy lỗi "Missing or insufficient permissions"**:
→ Cần update Firestore security rules

---

### Bước 3: Kiểm tra Camera/Mic Permissions

Trong console, gõ:
```javascript
navigator.mediaDevices.getUserMedia({video: true, audio: true})
  .then(() => console.log('✅ Camera/Mic OK'))
  .catch(err => console.log('❌ Permission Error:', err.message))
```

**Nếu thấy "Permission denied"**:
→ Click vào icon 🔒 bên trái address bar → Allow camera và microphone

---

### Bước 4: Test Video Call Button

1. Login vào app
2. Mở chat với bất kỳ user nào
3. Tap video call button 🎥
4. Quan sát console errors

**Các lỗi thường gặp:**

| Error | Nguyên nhân | Giải pháp |
|-------|-------------|-----------|
| `Firebase not defined` | Firebase chưa load | Check `web/index.html` có script Firebase |
| `Missing permissions` | Firestore rules block | Update rules: `allow read, write: if true;` |
| `getUserMedia failed` | Camera/mic denied | Allow trong browser settings |
| `Cannot read callId` | CallProvider error | Check console stack trace |

---

### Bước 5: Firebase Config (Nếu cần)

**File**: `d:\fyn-monolithic\fyn-flutter-app\web\index.html`

Đảm bảo có section này (thay YOUR_API_KEY bằng key thật):

```html
<script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore-compat.js"></script>
<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "fyn-7517d.firebaseapp.com",
    projectId: "fyn-7517d",
    storageBucket: "fyn-7517d.firebasestorage.app",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

**Lấy config từ**:
1. Firebase Console → Project Settings
2. Scroll xuống "Your apps" → Web app
3. Copy config object

---

### Bước 6: Firestore Security Rules

**Firebase Console** → Firestore Database → Rules

Thay bằng (cho testing):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **LƯU Ý**: Rules này chỉ dùng cho testing. Production cần auth check!

---

## Quick Checklist

- [ ] Firebase scripts loaded trong `index.html`
- [ ] Firebase config có API key thật (không phải placeholder)
- [ ] Firestore rules allow `read, write: if true`
- [ ] Browser cho phép camera/microphone
- [ ] Không có errors trong console khi click video button
- [ ] App navigate đến outgoing call screen

---

## Nếu vẫn không work

**Share với tôi:**
1. Screenshot browser console errors
2. Screenshot của outgoing call screen (nếu navigate được)
3. Kết quả của test Firebase connection (Bước 2)
