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

class AppConfig {
  static const String appName = 'FYN Social';
  
  // Base URL từ .env hoặc default
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
  }
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register';
      
      // Nếu đã đăng nhập và đang cố vào login/register, redirect về feed
      if (isLoggedIn && isGoingToAuth) {
        return '/feed';
      }
      
      // Nếu chưa đăng nhập và đang cố vào protected routes, redirect về login
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
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
    ],
  );
});


