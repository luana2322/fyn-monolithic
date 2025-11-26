import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

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
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationProvider.notifier).refresh(),
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppColors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state.notifications.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có thông báo nào',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              );
            }

            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length +
                  (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                if (index >= state.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final notification = state.notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.follow:
        return Icons.person_add_alt_1;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      case NotificationType.message:
        return Icons.message_outlined;
      case NotificationType.system:
      default:
        return Icons.notifications;
    }
  }

  Color _iconColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.follow:
        return Colors.blueAccent;
      case NotificationType.like:
        return Colors.pinkAccent;
      case NotificationType.comment:
        return Colors.green;
      case NotificationType.message:
        return Colors.orangeAccent;
      case NotificationType.system:
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = notification.status.isUnread;

    return Material(
      color: isUnread ? AppColors.surface : AppColors.background,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _iconColorForType(notification.type).withOpacity(0.15),
          child: Icon(
            _iconForType(notification.type),
            color: _iconColorForType(notification.type),
          ),
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: notification.createdAt != null
            ? Text(
                // Simple relative time
                _formatTimeAgo(notification.createdAt!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              )
            : null,
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (isUnread) {
            ref
                .read(notificationProvider.notifier)
                .markAsRead(notification.id);
          }
          // TODO: điều hướng tới màn hình chi tiết tương ứng theo referenceId/type
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '$weeks tuần trước';
    return '${time.day}/${time.month}/${time.year}';
  }
}


