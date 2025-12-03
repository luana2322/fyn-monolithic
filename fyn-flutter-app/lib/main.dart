import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✓ Loaded .env file');
    print('BASE_URL: ${dotenv.env['BASE_URL'] ?? 'NOT SET'}');
  } catch (e) {
    print('⚠ Failed to load .env file: $e');
    print('⚠ Using default BASE_URL: http://localhost:8080');
    // Không cố gán vào dotenv.env khi chưa khởi tạo
    // AppConfig sẽ tự động xử lý default value
  }
  
  runApp(
    const ProviderScope(
      child: FynApp(),
    ),
  );
}


