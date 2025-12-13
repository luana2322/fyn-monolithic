import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../auth/data/models/user_response.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/follower_repository.dart';
import '../../domain/user_service.dart';
import '../../data/models/update_profile_request.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/page_response.dart';

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

final followerRepositoryProvider = Provider<FollowerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FollowerRepository(apiClient);
});

// Service
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.watch(userRepositoryProvider),
    ref.watch(profileRepositoryProvider),
    ref.watch(followerRepositoryProvider),
  );
});

// State cho user profile
class UserProfileState {
  final UserResponse? user;
  final bool isLoading;
  final String? error;
  final bool isFollowing;
  final int? followersCount;
  final int? followingCount;

  UserProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isFollowing = false,
    this.followersCount,
    this.followingCount,
  });

  UserProfileState copyWith({
    UserResponse? user,
    bool? isLoading,
    String? error,
    bool? isFollowing,
    int? followersCount,
    int? followingCount,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFollowing: isFollowing ?? this.isFollowing,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

// Notifier cho user profile
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserService _userService;
  final String? userId;
  final String? username;

  UserProfileNotifier(this._userService, {this.userId, this.username})
      : super(UserProfileState());

  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      UserResponse user;
      if (userId != null) {
        user = await _userService.getUserById(userId!);
      } else if (username != null) {
        user = await _userService.getUserByUsername(username!);
      } else {
        throw Exception('userId hoặc username phải được cung cấp');
      }

      // Load followers/following count
      final followers = await _userService.getFollowers(user.id, size: 1);
      final following = await _userService.getFollowing(user.id, size: 1);

      state = state.copyWith(
        user: user,
        isLoading: false,
        followersCount: followers.totalElements,
        followingCount: following.totalElements,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadUser();
  }

  Future<void> toggleFollow() async {
    if (state.user == null) return;

    try {
      if (state.isFollowing) {
        await _userService.unfollow(state.user!.id);
      } else {
        await _userService.follow(state.user!.id);
      }

      // Reload để cập nhật trạng thái
      await loadUser();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

class UserProfileParams {
  final String? userId;
  final String? username;

  const UserProfileParams({this.userId, this.username});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileParams &&
        other.userId == userId &&
        other.username == username;
  }

  @override
  int get hashCode => Object.hash(userId, username);

  UserProfileParams copyWith({String? userId, String? username}) {
    return UserProfileParams(
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }
}

// Provider cho user profile
final userProfileProvider = StateNotifierProvider.family<UserProfileNotifier,
    UserProfileState, UserProfileParams>((ref, params) {
  final userService = ref.watch(userServiceProvider);
  return UserProfileNotifier(
    userService,
    userId: params.userId,
    username: params.username,
  );
});

// State cho edit profile
class EditProfileState {
  final bool isLoading;
  final String? error;

  EditProfileState({
    this.isLoading = false,
    this.error,
  });

  EditProfileState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier cho edit profile
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final UserService _userService;
  final Ref _ref;

  EditProfileNotifier(this._userService, this._ref)
      : super(EditProfileState());

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userService.updateProfile(request);
      
      // Refresh current user
      final authNotifier = _ref.read(authNotifierProvider.notifier);
      await authNotifier.refreshCurrentUser();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> uploadAvatar(XFile imageFile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userService.uploadAvatar(imageFile);
      
      // Refresh current user
      final authNotifier = _ref.read(authNotifierProvider.notifier);
      await authNotifier.refreshCurrentUser();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

// Provider cho edit profile
final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  final userService = ref.watch(userServiceProvider);
  return EditProfileNotifier(userService, ref);
});

