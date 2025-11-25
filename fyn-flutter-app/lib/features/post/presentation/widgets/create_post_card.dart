import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/image_utils.dart';

class CreatePostCard extends ConsumerWidget {
  final VoidCallback? onCreatePost;

  const CreatePostCard({super.key, this.onCreatePost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: user?.profile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            ImageUtils.getAvatarUrl(user!.profile.avatarUrl) ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildAvatarInitials(user.username);
                            },
                          ),
                        )
                      : _buildAvatarInitials(user?.username ?? 'U'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onCreatePost ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tạo bài viết mới')),
                          );
                        },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Bạn đang nghĩ gì?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: Colors.red,
                  onTap: onCreatePost ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                ),
                _buildActionButton(
                  icon: Icons.photo_library,
                  label: 'Ảnh',
                  color: Colors.green,
                  onTap: onCreatePost ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                ),
                _buildActionButton(
                  icon: Icons.emoji_emotions,
                  label: 'Cảm xúc',
                  color: Colors.orange,
                  onTap: onCreatePost ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tính năng đang phát triển')),
                        );
                      },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarInitials(String username) {
    final initials = username.isNotEmpty
        ? username.substring(0, 1).toUpperCase()
        : 'U';
    return Text(
      initials,
      style: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

