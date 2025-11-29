import 'package:dio/dio.dart';
import '../../config/api_config.dart' show ApiEndpoints;
import '../../config/app_config.dart' show AppConfig;
import '../storage/secure_storage.dart';
import 'interceptors.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    final baseUrl = AppConfig.baseUrl;
    
    // Log để debug (chỉ trong debug mode)
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('ApiClient initialized with baseUrl: $baseUrl');
    }
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    String fileKey = 'file',
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      if (data != null) ...data,
      fileKey: await MultipartFile.fromFile(filePath),
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }

  // Upload multiple files
  Future<Response> uploadFiles(
    String path,
    List<String> filePaths, {
    Map<String, dynamic>? data,
    String fileKey = 'files',
    ProgressCallback? onSendProgress,
  }) async {
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );

    final formData = FormData.fromMap({
      if (data != null) ...data,
      fileKey: files,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }
}

