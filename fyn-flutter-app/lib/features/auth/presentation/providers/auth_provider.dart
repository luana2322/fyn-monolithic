import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/auth_service.dart';
import '../../data/models/user_response.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../../../core/network/dio_provider.dart';

// Providers
// Local apiClientProvider removed to use shared one from dio_provider.dart

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authRepositoryProvider));
});

// State
class AuthState {
  final UserResponse? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserResponse? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      try {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(user: user);
      } catch (e) {
        // Not logged in or token expired
        state = state.copyWith(user: null);
      }
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(
        LoginRequest(identifier: identifier, password: password),
      );
      state = state.copyWith(
        user: response.user,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String? phone,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.register(
        RegisterRequest(
          email: email,
          username: username,
          password: password,
          phone: phone,
          fullName: fullName,
        ),
      );
      state = state.copyWith(
        user: response.user,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refreshCurrentUser() async {
    await refreshUser();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

