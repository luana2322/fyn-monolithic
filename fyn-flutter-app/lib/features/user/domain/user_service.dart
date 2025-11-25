import '../../auth/data/models/user_response.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/follower_repository.dart';
import '../data/models/update_profile_request.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/page_response.dart';

class UserService {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;
  final FollowerRepository _followerRepository;

  UserService(
    this._userRepository,
    this._profileRepository,
    this._followerRepository,
  );

  /// Lấy thông tin user theo ID
  Future<UserResponse> getUserById(String userId) async {
    return await _userRepository.getUserById(userId);
  }

  /// Lấy thông tin user theo username
  Future<UserResponse> getUserByUsername(String username) async {
    return await _userRepository.getUserByUsername(username);
  }

  /// Cập nhật profile
  Future<UserResponse> updateProfile(UpdateProfileRequest request) async {
    return await _profileRepository.updateProfile(request);
  }

  /// Upload avatar
  Future<UserResponse> uploadAvatar(XFile imageFile) async {
    return await _profileRepository.uploadAvatar(imageFile);
  }

  /// Follow user
  Future<void> follow(String userId) async {
    await _followerRepository.follow(userId);
  }

  /// Unfollow user
  Future<void> unfollow(String userId) async {
    await _followerRepository.unfollow(userId);
  }

  /// Lấy danh sách followers
  Future<PageResponse<UserResponse>> getFollowers(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    return await _followerRepository.getFollowers(userId, page: page, size: size);
  }

  /// Lấy danh sách following
  Future<PageResponse<UserResponse>> getFollowing(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    return await _followerRepository.getFollowing(userId, page: page, size: size);
  }
}

