import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/post/presentation/screens/feed_screen.dart';
import '../features/user/presentation/screens/profile_screen.dart';
import '../features/user/presentation/screens/edit_profile_screen.dart';
import '../features/user/presentation/screens/followers_following_screen.dart';
import '../features/message/presentation/screens/chat_list_screen.dart';
import '../features/notification/presentation/screens/notification_screen.dart';
// Removed: video_call feature (not needed)
import '../features/events/presentation/screens/event_list_screen.dart';
import '../features/events/presentation/screens/create_event_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
// Removed: ALL connections feature screens (person-matching deleted)
import '../features/post/presentation/screens/create_post_screen.dart';
import '../features/post/presentation/screens/posts_by_place_screen.dart';
import '../features/meetup/presentation/screens/discover_meetups_screen.dart';
import '../features/meetup/presentation/screens/create_meetup_screen.dart';
import '../features/meetup/presentation/screens/meetup_details_screen.dart';
import '../features/meetup/presentation/screens/my_meets_screen.dart';
import '../features/meetup/presentation/screens/match_requests_screen.dart';
import '../features/admin/presentation/screens/reported_posts_screen.dart';
import '../features/admin/presentation/screens/report_detail_screen.dart';
import '../features/admin/data/models/post_report_model.dart';

class AppConfig {
  static const String appName = 'FYN Social';
  
  // Default values
  static const String _defaultWebBaseUrl = 'http://localhost:8080';
  static const String _defaultIosBaseUrl = 'http://localhost:8080';

  // Fixed IP for your current environment (use ipconfig value)
  // Your Machine IP is 172.26.27.3. The Phone IP (172.26.15.225) should not be used here.
  static const String _currentDevIp = '172.26.27.3'; 

  static String get baseUrl {
    // Falls back to platform-specific defaults
    if (kIsWeb) {
      return _defaultWebBaseUrl;
    }
    
    try {
      if (Platform.isAndroid) {
        // Use the fixed Dev IP for physical Android devices
        return 'http://$_currentDevIp:8080';
      } else if (Platform.isIOS) {
        return _defaultIosBaseUrl;
      }
    } catch (e) {
      // Fallback
    }
    
    return _defaultWebBaseUrl;
  }

  // Get only the host part (IP:Port) for MinIO
  static String get minioHost {
    if (kIsWeb) {
      return 'localhost:9000';
    }

    try {
      if (Platform.isAndroid) {
        // Use the same fixed Dev IP for MinIO
        return '$_currentDevIp:9000';
      }
    } catch (e) {
      // Ignore
    }

    return 'localhost:9000';
  }
  
  // Getter để debug - kiểm tra platform hiện tại
  static String get currentPlatform {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      return 'Unknown';
    }
    return 'Unknown';
  }
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(ref.watch(authNotifierProvider.notifier).stream),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register';
      
      // Nếu đã đăng nhập và đang cố vào login/register, redirect về feed hoặc admin dashboard
      if (isLoggedIn && isGoingToAuth) {
        if (authState.user?.role == 'ADMIN') {
          return '/admin/reported-posts';
        }
        return '/feed';
      }
      
      // Nếu chưa đăng nhập và đang cố vào protected routes, redirect về login
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      // Special case: If user is ADMIN and just logged in, or is on feed, redirect to admin dashboard
      if (isLoggedIn && authState.user?.role == 'ADMIN' && state.matchedLocation == '/feed') {
        return '/admin/reported-posts';
      }
      
      return null; // Không redirect
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/posts/place/:placeCode',
        name: 'posts-by-place',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final placeCode = state.pathParameters['placeCode']!;
          final placeName = extra?['placeName'] ?? placeCode;
          return PostsByPlaceScreen(
            placeCode: placeCode,
            placeName: placeName,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'my-profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        name: 'profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/u/:userId',
        name: 'profile-deeplink',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/followers-following',
        name: 'followers-following',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return FollowersFollowingScreen(
            userId: extra?['userId'] ?? '',
            type: extra?['type'] ?? 'followers',
          );
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      // Removed: video_call routes (feature not needed)
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventListScreen(),
        routes: [
           GoRoute(
            path: 'create',
            name: 'create-event',
            builder: (context, state) => const CreateEventScreen(),
          ),
          GoRoute(
            path: ':eventId',
            name: 'event-details',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return EventDetailScreen(eventId: eventId);
            },
          ),
        ],
      ),
      // Removed: ALL /connections, /discover, /matches, /dates routes
      // Meetup routes (ONLY dating feature)
      GoRoute(
        path: '/meetups',
        name: 'meetups',
        builder: (context, state) => const DiscoverMeetupsScreen(),
      ),
      GoRoute(
        path: '/meetups/create',
        name: 'create-meetup',
        builder: (context, state) => const CreateMeetupScreen(),
      ),
      GoRoute(
        path: '/meetups/my',
        name: 'my-meetups',
        builder: (context, state) => const MyMeetsScreen(),
      ),
      GoRoute(
        path: '/meetups/:id',
        name: 'meetup-details',
        builder: (context, state) {
          final meetupId = state.pathParameters['id']!;
          return MeetupDetailsScreen(meetupId: meetupId);
        },
      ),
      GoRoute(
        path: '/meetups/:id/matches',
        name: 'meetup-matches',
        builder: (context, state) {
          final meetupId = state.pathParameters['id']!;
          return MatchRequestsScreen(meetupId: meetupId);
        },
      ),
      // Admin routes
      GoRoute(
        path: '/admin/reported-posts',
        name: 'admin-reported-posts',
        builder: (context, state) => const ReportedPostsScreen(),
      ),
      GoRoute(
        path: '/admin/reports/:reportId',
        name: 'admin-report-detail',
        builder: (context, state) {
          final report = state.extra as PostReportModel;
          return ReportDetailScreen(report: report);
        },
      ),
    ],
  );
});

/// A [Listenable] that notifies when the [stream] emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

