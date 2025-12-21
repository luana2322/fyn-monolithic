import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/meetup/data/services/meetup_api_service.dart';
import '../features/meetup/data/repositories/meetup_repository.dart';
import '../features/meetup/presentation/providers/meetup_provider.dart';
import '../core/network/dio_provider.dart';

/// Override meetup repository provider with actual implementation
/// This connects the meetup feature to the API
Provider<MeetupRepository> get actualMeetupRepositoryProvider => Provider<MeetupRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final apiService = MeetupApiService(apiClient.dio);
  return MeetupRepository(apiService);
});

