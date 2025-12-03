import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../theme/app_colors.dart';
import 'package:fyn_flutter_app/shared/themes/app_spacing.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../../../../core/utils/image_utils.dart'; // Đảm bảo import đúng

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(notificationProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0, // Giữ màu phẳng khi cuộn
        centerTitle: true,
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryText),
              onPressed: () => Navigator.pop(context),
            )
          : null,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () {
                // TODO: Mark all as read action
              },
              child: const Text(
                'Đã đọc',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
            color: AppColors.primary,
            child: _buildBody(state),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.secondaryText),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notificationProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tương tác với mọi người để nhận thông báo mới',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return _NotificationItem(notification: state.notifications[index]);
      },
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = notification.status == NotificationStatus.unread;
    
    // Logic xác định Icon và Màu sắc dựa trên loại thông báo
    IconData typeIcon;
    Color typeColor;
    // ignore: unused_local_variable
    String actionText = '';

    switch (notification.type) {
      case NotificationType.like:
        typeIcon = Icons.favorite;
        typeColor = const Color(0xFFEF4444); // Red
        break;
      case NotificationType.comment:
        typeIcon = Icons.chat_bubble;
        typeColor = const Color(0xFF3B82F6); // Blue
        break;
      case NotificationType.follow:
        typeIcon = Icons.person_add;
        typeColor = const Color(0xFF8B5CF6); // Purple
        actionText = 'Theo dõi lại';
        break;
      case NotificationType.system:
        typeIcon = Icons.info;
        typeColor = const Color(0xFFF59E0B); // Amber
        break;
      default:
        typeIcon = Icons.notifications;
        typeColor = AppColors.primary;
    }

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        // TODO: Gọi API xóa thông báo
      },
      child: InkWell(
        onTap: () {
          if (isUnread) {
            ref.read(notificationProvider.notifier).markAsRead(notification.id);
          }
          // Điều hướng dựa trên loại thông báo
          // if (notification.type == NotificationType.follow && notification.referenceId != null) {
          //    context.push('/profile/${notification.referenceId}'); 
          // } else if (notification.referenceId != null) {
          //    // context.push('/post/${notification.referenceId}'); 
          // }
        },
        child: Container(
          color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.transparent, // Highlight nhẹ
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Avatar with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceHighlight,
                    // Giả sử có senderAvatarUrl trong notification model (nếu không có thì dùng placeholder)
                    child: const Icon(Icons.person, color: AppColors.secondaryText),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: Icon(typeIcon, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // 2. Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 14,
                          color: AppColors.primaryText,
                          height: 1.4,
                        ),
                        children: [
                          // Tên người dùng (Giả lập vì model cũ chỉ có message string)
                          TextSpan(
                            text: notification.message,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeAgo(notification.createdAt ?? DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryText,
                      ),
                    ),
                    
                    // Nút hành động phụ (nếu là Follow)
                    if (notification.type == NotificationType.follow)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Theo dõi lại', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 3. Trailing (Preview Image or Unread Dot)
              if (notification.type == NotificationType.like || notification.type == NotificationType.comment)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surfaceHighlight,
                    // Nếu có postImage, dùng: image: DecorationImage(...)
                  ),
                  child: const Icon(Icons.image_outlined, size: 20, color: AppColors.tertiaryText),
                )
              else if (isUnread)
                Container(
                  margin: const EdgeInsets.only(left: 12, top: 12),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${time.day} thg ${time.month}';
  }
}