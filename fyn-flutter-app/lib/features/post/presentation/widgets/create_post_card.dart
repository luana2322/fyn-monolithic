import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import 'create_post_sheet.dart';

class CreatePostCard extends ConsumerWidget {
  const CreatePostCard({super.key, this.onCreatePost});
  final VoidCallback? onCreatePost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final avatarUrl = ImageUtils.getAvatarUrl(user?.profile.avatarUrl);

    void handlePress() async {
      if (onCreatePost != null) {
        onCreatePost!();
      } else {
         await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => const CreatePostSheet(),
        );
      }
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceHighlight,
            backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
            child: avatarUrl == null ? Text(user?.username[0] ?? '?', style: const TextStyle(fontWeight: FontWeight.bold)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: handlePress,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight, // Màu nền xám nhạt
                  borderRadius: BorderRadius.circular(24), // Pill shape
                ),
                child: Text(
                  'Bạn đang nghĩ gì thế?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.image_outlined, color: AppColors.secondary),
            onPressed: handlePress,
            tooltip: 'Thêm ảnh',
          ),
        ],
      ),
    );
  }
}