import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../../config/api_config.dart' show ApiEndpoints;
import '../../config/app_config.dart' show AppConfig;

/// Interceptor để tự động thêm JWT token vào header
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Không thêm token cho các endpoint public
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Lấy access token từ storage
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Nếu lỗi 401 (Unauthorized), thử refresh token
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry request với token mới
        final opts = err.requestOptions;
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          opts.headers['Authorization'] = 'Bearer $token';
          try {
            final response = await Dio().fetch(opts);
            handler.resolve(response);
            return;
          } catch (e) {
            // Refresh failed, clear tokens và redirect to login
            await SecureStorage.clearAll();
            handler.reject(err);
            return;
          }
        }
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path.startsWith('/api/auth/register') ||
        path.startsWith('/api/auth/login') ||
        path.startsWith('/api/auth/refresh') ||
        path.startsWith('/api/auth/password/forgot') ||
        path.startsWith('/api/auth/password/verify-otp') ||
        path.startsWith('/health') ||
        path.startsWith('/actuator');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await SecureStorage.saveAccessToken(data['accessToken']);
        await SecureStorage.saveRefreshToken(data['refreshToken']);
        return true;
      }
    } catch (e) {
      // Refresh failed
    }
    return false;
  }
}

/// Interceptor để log requests và responses (chỉ trong debug mode)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      if (options.data != null) {
        print('DATA: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('QUERY: ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
      print('MESSAGE: ${err.message}');
    }
    handler.next(err);
  }
}

/// Interceptor để xử lý errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform DioException thành custom error nếu cần
    handler.next(err);
  }
}

