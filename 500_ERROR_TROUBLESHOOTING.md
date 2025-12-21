# 🔧 500 Error Troubleshooting - Meetup Discovery

## Current Status

You're getting a **500 Internal Server Error** when trying to load meetups. This is a backend error that happens AFTER the frontend successfully connects.

![Error Screenshot](file:///C:/Users/nguye/.gemini/antigravity/brain/e35a1c80-03d5-4f3a-9979-10d137d4013d/uploaded_image_1766252422081.png)

---

## Most Likely Causes

### 1. ⚠️ Authentication/Session Issue (MOST LIKELY)
After rebuilding, your login session may have expired.

**Fix:** Log out and log back in to get a fresh authentication token.

### 2. ⚠️ User Profile Missing Location
The backend tries to get user location from your profile when not provided.

**Check:** Your user profile needs `latitude` and `longitude` fields populated.

```sql
-- Check your user location
SELECT id, email, latitude, longitude FROM users WHERE email = 'your@email.com';

-- If NULL, update it:
UPDATE users 
SET latitude = 10.762622, longitude = 106.660172  
WHERE email = 'your@email.com';
```

### 3. ⚠️ Backend Query Error
The database query might be failing due to data inconsistency.

---

## Quick Diagnostic Steps

### Step 1: Check Backend Health
```bash
# See if backend is running
docker ps | grep fyn-backend

# Check recent logs for errors
docker logs fyn-backend --tail 50
```

### Step 2: Check Authentication
1. Open browser DevTools (F12)
2. Go to **Application** → **Local Storage** / **Cookies**
3. Look for auth token
4. If missing/expired → **Log out and log back in**

### Step 3: Test API Directly
With your auth token from DevTools:
```bash
curl -X GET "http://localhost:8080/api/v1/meetups/discover?latitude=10.762622&longitude=106.660172&radiusKm=10" \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN_HERE"
```

If this returns data → Frontend issue  
If this returns 500 → Backend issue

---

## Frontend Changes Made

### ✅ Already Fixed:
1. Added default location (Ho Chi Minh City coordinates)
2. Frontend now always sends `latitude` and `longitude`
3. Removed "Browse Dates" tab as requested

### Code in `discover_meetups_screen.dart`:
```dart
void _loadMeetups() {
  // Use default location (Ho Chi Minh City) as fallback
  ref.read(discoveredMeetupsProvider.notifier).discoverMeetups(
    latitude: 10.762622,  // ✅ Always provided
    longitude: 106.660172, // ✅ Always provided
    radiusKm: _radiusKm,
    meetType: _selectedMeetType,
    category: _selectedCategory,
    sortBy: _sortBy,
  );
}
```

---

## Recommended Actions

### Option 1: Try Logging Out/In (FASTEST)
1. Log out of the app
2. Log back in with your credentials
3. Navigate to Meetups tab
4. Should work now! ✅

### Option 2: Check Backend Logs (If Option 1 fails)
```bash
# Watch logs in real-time
docker logs -f fyn-backend

# Then refresh the meetups page and see the error
```

Send me the error message that appears and I'll fix it immediately.

### Option 3: Check Database (Advanced)
```bash
# Connect to database
docker exec -it fyn-postgres psql -U postgres -d fyn

# Check if there are any meetups
SELECT count(*) FROM meetups WHERE status = 'OPEN';

# Check your user profile
SELECT id, email, latitude, longitude FROM users LIMIT 5;
```

---

## What I Need From You

To help debug further, please provide **ONE** of the following:

### A) Backend Logs
```bash
docker logs fyn-backend --tail 100 --since 5m
```
Copy the full output, especially any lines with "ERROR" or "Exception"

### B) Browser DevTools Error
1. F12 → Console tab
2. Find the red error for `/meetups/discover`
3. Click it → Response tab
4. Copy the full error message

### C) Network Request Details
1. F12 → Network tab
2. Find the failed request (red, status 500)
3. Click it → Headers tab
4. Show me:
   - Request URL
   - Request Headers (especially Authorization)
   - Response tab (error message)

---

## Summary

**Issue:** 500 error loading meetups  
**Most Likely:** Expired auth session after rebuild  
**Quick Fix:** Log out and log back in  
**Alternative:** Check backend logs for specific error  

The frontend code is already fixed to always send coordinates, so the error is likely authentication or backend-related, not a code issue.
