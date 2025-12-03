import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:fyn_flutter_app/shared/themes/app_spacing.dart';
import '../../data/models/post_model.dart';
import '../providers/comment_provider.dart';

class PostCommentsSheet extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCommentsSheet({super.key, required this.post});

  @override
  ConsumerState<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends ConsumerState<PostCommentsSheet> {
  late final TextEditingController _controller;
  late final CommentProviderArgs _args;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _args = CommentProviderArgs(
      postId: widget.post.id,
      ownerId: widget.post.author.id,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postCommentsProvider(_args).notifier).load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postCommentsProvider(_args));
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userAvatarUrl = ImageUtils.getAvatarUrl(user?.profile.avatarUrl);

    // Tính toán chiều cao để bottom sheet không bị che bởi bàn phím
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Handle Bar & Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Bình luận',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Comments List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.tertiaryText.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              'Chưa có bình luận nào',
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Hãy là người đầu tiên bình luận!',
                              style: TextStyle(color: AppColors.tertiaryText, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final comment = state.comments[index];
                          final isOwnComment = user?.id == comment.author.id;
                          final avatar = ImageUtils.getAvatarUrl(comment.author.profile.avatarUrl);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.surfaceElevated,
                                  backgroundImage: avatar != null 
                                      ? CachedNetworkImageProvider(avatar) 
                                      : null,
                                  child: avatar == null 
                                      ? Text(
                                          comment.author.username.isNotEmpty 
                                              ? comment.author.username[0].toUpperCase() 
                                              : '?',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                                        ) 
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment.author.username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: AppColors.primaryText,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTime(comment.createdAt),
                                            style: const TextStyle(color: AppColors.tertiaryText, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment.content,
                                        style: const TextStyle(fontSize: 14, color: AppColors.primaryText, height: 1.4),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Action Row (Reply, Delete)
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // TODO: Reply logic
                                            },
                                            child: const Text(
                                              'Trả lời',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.secondaryText),
                                            ),
                                          ),
                                          if (isOwnComment) ...[
                                            const SizedBox(width: 16),
                                            GestureDetector(
                                              onTap: () => ref.read(postCommentsProvider(_args).notifier).deleteComment(comment.id),
                                              child: const Text(
                                                'Xóa',
                                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.error),
                                              ),
                                            ),
                                          ]
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                
                                // Like Comment Button (Optional)
                                const Icon(Icons.favorite_border_rounded, size: 14, color: AppColors.tertiaryText),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // 3. Input Area (Pill shape)
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomInset),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceElevated,
                  backgroundImage: userAvatarUrl != null 
                      ? CachedNetworkImageProvider(userAvatarUrl) 
                      : null,
                  child: userAvatarUrl == null 
                      ? const Icon(Icons.person, color: AppColors.secondaryText) 
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated, // Nền xám nhạt (Liquid feel)
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Thêm bình luận...',
                        hintStyle: TextStyle(color: AppColors.tertiaryText),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      onChanged: (_) => setState(() {}), // Rebuild to show/hide Post button color
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                state.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _controller.text.trim().isEmpty 
                            ? null 
                            : () async {
                                final text = _controller.text.trim();
                                if (text.isEmpty) return;
                                await ref.read(postCommentsProvider(_args).notifier).addComment(text);
                                _controller.clear();
                                setState(() {}); // Reset button state
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          disabledForegroundColor: AppColors.tertiaryText,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Đăng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day} thg ${dt.month}';
  }
}