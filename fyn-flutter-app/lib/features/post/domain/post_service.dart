import 'package:image_picker/image_picker.dart';

import '../../../core/models/page_response.dart';
import '../data/models/create_post_request.dart';
import '../data/models/post_model.dart';
import '../data/repositories/post_repository.dart';

class PostService {
  final PostRepository _postRepository;

  PostService(this._postRepository);

  Future<PageResponse<PostModel>> getFeed({int page = 0, int size = 10}) {
    return _postRepository.getFeed(page: page, size: size);
  }

  Future<PageResponse<PostModel>> getPostsByUser(
    String userId, {
    int page = 0,
    int size = 9,
  }) {
    return _postRepository.getPostsByUser(userId, page: page, size: size);
  }

  Future<PostModel> createPost(
    CreatePostRequest request, {
    List<XFile>? mediaFiles,
  }) {
    return _postRepository.createPost(request, mediaFiles: mediaFiles);
  }

  Future<void> deletePost(String postId) {
    return _postRepository.deletePost(postId);
  }
}

