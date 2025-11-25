import '../data/repositories/auth_repository.dart';
import '../data/models/auth_response.dart';
import '../data/models/login_request.dart';
import '../data/models/register_request.dart';
import '../data/models/refresh_token_request.dart';
import '../data/models/token_response.dart';
import '../data/models/user_response.dart';
import '../../../core/storage/secure_storage.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  /// Đăng ký
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _repository.register(request);
    await _saveTokens(response);
    return response;
  }

  /// Đăng nhập
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _repository.login(request);
    await _saveTokens(response);
    return response;
  }

  /// Refresh token
  Future<TokenResponse> refreshToken(String refreshToken) async {
    final request = RefreshTokenRequest(refreshToken: refreshToken);
    final response = await _repository.refreshToken(request);
    await SecureStorage.saveAccessToken(response.accessToken);
    await SecureStorage.saveRefreshToken(response.refreshToken);
    return response;
  }

  /// Đăng xuất
  Future<void> logout() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _repository.logout(RefreshTokenRequest(refreshToken: refreshToken));
      } catch (e) {
        // Ignore errors on logout
      }
    }
    await SecureStorage.clearAll();
  }

  /// Lấy thông tin user hiện tại
  Future<UserResponse> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }

  /// Kiểm tra đã đăng nhập
  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Lưu tokens
  Future<void> _saveTokens(AuthResponse response) async {
    await SecureStorage.saveAccessToken(response.accessToken);
    await SecureStorage.saveRefreshToken(response.refreshToken);
    await SecureStorage.saveUserId(response.user.id);
  }
}

