# Testing Video Functionality in Flutter App

## Prerequisites
- Flutter app is running (`flutter run -d chrome` or on device)
- Backend server is running on `http://localhost:8080`
- You have test video files ready (< 5 minutes, MP4 format recommended)

## Quick Test Guide

### 1. Install Dependencies
```bash
cd fyn-flutter-app
flutter pub get
```

### 2. Run the App
```bash
# For web
flutter run -d chrome

# For mobile (Android/iOS)
flutter run
```

### 3. Test Video Upload

**Steps**:
1. Login to the app
2. Tap the "Create Post" button or sheet
3. Tap the **video camera icon** (📹)
4. Select a video from your gallery
5. **Observe**: Thumbnail generation
   - Loading spinner appears
   - Thumbnail from video frame appears
   - Play button overlay shows
   - Red "VIDEO" badge in corner
6. (Optional) Add text content
7. Tap "Đăng bài" (Post) button
8. **Observe**: Post uploads and appears in feed

### 4. Test Video Playback

**Steps**:
1. Scroll to a post with video in the feed
2. **Observe**: Video player shows with play button
3. Tap the video to play
4. **Observe**:
   - Video starts playing
   - Play button overlay disappears
   - Video loops when finished
5. Tap again to pause
6. **Observe**: Play button overlay reappears

### 5. Test Error Handling

**Steps**:
1. Try playing a video with network disconnected
2. **Observe**: Error placeholder shows instead of crash

## Expected Behavior

### ✅ Video Preview (Create Post)
- [ ] Thumbnail generates within 1-2 seconds
- [ ] Thumbnail shows actual frame from video (not icon)
- [ ] Play button overlay visible
- [ ] "VIDEO" badge visible in top-left
- [ ] Can remove video by tapping X button

### ✅ Video Upload
- [ ] Upload progress shows loading indicator
- [ ] Post appears in feed after upload
- [ ] Video metadata sent to backend correctly

### ✅ Video Playback (Feed)
- [ ] Video player initializes automatically
- [ ] Tap to play/pause works
- [ ] Video loops seamlessly
- [ ] Error handling works (bad URL, network error)
- [ ] Multiple videos in feed work independently

## Common Issues & Solutions

### Issue: Thumbnail not generating on Web
**Cause**: `video_thumbnail` package has limited web support  
**Solution**: Fallback to icon placeholder (already implemented)

### Issue: Video doesn't play on Web
**Cause**: Browser autoplay policy  
**Solution**: User must tap to play (implemented - no autoplay)

### Issue: Large video takes long to upload
**Cause**: File size  
**Solution**: Use smaller test videos (< 50MB recommended)

### Issue: Video format not supported
**Cause**: Platform codec limitations  
**Solution**: Use MP4 with H.264 codec for best compatibility

## Backend Verification

After uploading a video, check it was saved correctly:

```bash
# View the post in backend logs
curl http://localhost:8080/api/posts/feed \
  -H "Authorization: Bearer <token>" | jq '.data.content[0]'
```

Expected response should include:
```json
{
  "media": [
    {
      "objectKey": "uuid-video.mp4",
      "mediaUrl": "http://localhost:9000/fyn-data/uuid-video.mp4",
      "mediaType": "VIDEO",
      "description": null
    }
  ]
}
```

## Performance Notes

- **Thumbnail Generation**: ~1-2 seconds per video
- **Video Upload**: Depends on file size and network  
- **Video Initialization**: ~500ms-2s depending on network
- **Memory**: Each video player uses ~20-50MB RAM

## Next Steps

Once basic functionality is verified, consider:
1. Testing with different video formats (MOV, AVI, WebM)
2. Testing with videos of different durations
3. Testing with poor network conditions
4. Testing multi-video posts (if supported)
5. Performance testing with many videos in feed

## Need Help?

Check the implementation files:
- [`create_post_sheet.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/post/presentation/widgets/create_post_sheet.dart) - Video picker & preview
- [`post_card.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/features/post/presentation/widgets/post_card.dart) - Video player in feed
- [`video_widgets.dart`](file:///d:/fyn-monolithic/fyn-flutter-app/lib/shared/widgets/video_widgets.dart) - Reusable video components
- [`walkthrough.md`](file:///C:/Users/nguye/.gemini/antigravity/brain/dc8396fb-16e0-45b8-96ea-f750f2f91349/walkthrough.md) - Complete implementation guide
