import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/dio_provider.dart';
import 'storage_service.dart';

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StorageService(apiClient);
});
