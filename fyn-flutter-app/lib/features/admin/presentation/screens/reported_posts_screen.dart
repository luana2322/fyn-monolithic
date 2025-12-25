import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/moderation_provider.dart';
import '../../data/models/post_report_model.dart';
import '../../data/models/report_status.dart';
import '../../../../theme/dating_colors.dart';
import '../../../post/data/models/report_reason.dart';
import 'report_detail_screen.dart';

class ReportedPostsScreen extends ConsumerStatefulWidget {
  const ReportedPostsScreen({super.key});

  @override
  ConsumerState<ReportedPostsScreen> createState() => _ReportedPostsScreenState();
}

class _ReportedPostsScreenState extends ConsumerState<ReportedPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moderationProvider.notifier).loadReportedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moderationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo nội dung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(moderationProvider.notifier).loadReportedPosts(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: state.isLoading && state.reportedPosts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.reportedPosts.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: () => ref.read(moderationProvider.notifier).loadReportedPosts(),
                  child: ListView.builder(
                    itemCount: state.reportedPosts.length,
                    itemBuilder: (context, index) {
                      final report = state.reportedPosts[index];
                      return _buildReportItem(context, report, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.done_all,
            size: 64,
            color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text('Không có báo cáo nào cần xử lý'),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, PostReportModel report, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report.status.label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                report.reason.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Người báo cáo: ${report.reporter.username}',
              style: TextStyle(color: isDark ? DatingColors.darkSecondaryText : Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Bài viết: ${report.post.content}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? DatingColors.darkPrimaryText : Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày báo cáo: ${report.createdAt.toLocal().toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/admin/reports/${report.id}', extra: report);
        },
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.PENDING:
        return Colors.orange;
      case ReportStatus.VALID:
        return Colors.red;
      case ReportStatus.INVALID:
        return Colors.green;
    }
  }
}
