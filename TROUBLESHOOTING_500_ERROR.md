# 🔍 Troubleshooting 500 Error

## Quick Diagnostics

### 1. Check if User is Logged In
**Problem:** The `/api/v1/meetups/discover` endpoint requires authentication  
**Solution:** Make sure you're logged in to the app

### 2. Check User Location
**Problem:** Controller tries to get user's location from profile  
**Line:** `latitude = userDetails.getUser().getLatitude();`  
**Error:** If user.latitude or user.longitude is NULL → 500 error

**Solution:** User profile must have location set

### 3. Which Endpoint is Failing?
The error could be from different endpoints:
- `/api/v1/meetups/discover` - Discover meetups
- `/api/v1/meetups/{id}` - Get single meetup
- `/api/v1/meetups` - Create meetup

---

## 🔧 Quick Fixes

### Fix 1: Set Your Location
Your user profile needs latitude/longitude. Check if it's set:

```sql
SELECT id, email, latitude, longitude 
FROM users 
WHERE id = 'YOUR_USER_ID';
```

If NULL, update it:
```sql
UPDATE users 
SET latitude = 10.762622, longitude = 106.660172  -- Example: Ho Chi Minh City
WHERE id = 'YOUR_USER_ID';
```

### Fix 2: Check Backend Logs in Real-Time
```bash
docker logs -f fyn-backend
```

Then refresh the page to see the exact error.

### Fix 3: Test Without Auth (if possible)
Check if endpoint itself works - open browser DevTools:
1. Network tab
2. Find the failing request  
3. Look at Response tab for detailed error message

---

## 📋 Common Causes

| Cause | Symptom | Fix |
|-------|---------|-----|
| **Not logged in** | 401/500 error | Log in first |
| **NULL location** | 500 NullPointerException | Set user lat/lng |
| **Invalid query params** | 400/500 error | Check frontend request |
| **Database down** | 500 connection error | Check Postgres |

---

## 🎯 Next Steps

**Please share:**
1. **Which screen/page** are you on?
2. **Browser console error** (F12 → Console tab)
3. **Network request details** (F12 → Network → find failed request → Response)

This will help me pinpoint the exact issue!
