import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/moderation_provider.dart';
import '../../data/models/post_report_model.dart';
import '../../data/models/report_status.dart';
import '../../../../theme/dating_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../post/presentation/widgets/post_card.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final PostReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = widget.report;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết báo cáo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin báo cáo', isDark),
            _buildInfoCard(report, isDark),
            const SizedBox(height: 24),
            _buildSectionTitle('Nội dung bị báo cáo', isDark),
            const SizedBox(height: 8),
            PostCard(
              post: report.post,
              isOwnPost: false,
              onTapProfile: () {},
              onToggleReaction: () async {},
              onOpenComments: () {},
            ),
            const SizedBox(height: 24),
            if (report.status == ReportStatus.PENDING) ...[
              _buildSectionTitle('Xử lý báo cáo', isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú của admin...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? DatingColors.darkSurface : Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButtons(context, ref),
            ] else ...[
              _buildSectionTitle('Kết quả xử lý', isDark),
              _buildModerationResult(report, isDark),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard(PostReportModel report, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Lý do:', report.reason.name, isDark),
            const Divider(),
            _buildInfoRow('Mô tả:', report.description ?? 'Không có mô tả', isDark),
            const Divider(),
            _buildInfoRow('Người báo cáo:', report.reporter.username, isDark),
            const Divider(),
            _buildInfoRow('Ngày báo cáo:', report.createdAt.toLocal().toString().split('.')[0], isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? DatingColors.darkSecondaryText : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleMarkValid(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Báo cáo đúng'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleMarkInvalid(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Báo cáo sai'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleHidePost(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.orange),
                  foregroundColor: Colors.orange,
                ),
                child: const Text('Ẩn bài viết'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleDeletePost(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Xóa bài viết'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModerationResult(PostReportModel report, bool isDark) {
    return Card(
      color: report.status == ReportStatus.VALID ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạng thái: ${report.status.label}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: report.status == ReportStatus.VALID ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ghi chú admin: ${report.moderationComment ?? "Không có ghi chú"}',
              style: TextStyle(color: isDark ? DatingColors.darkPrimaryText : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMarkValid(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(moderationProvider.notifier).markReportValid(
            widget.report.id,
            _commentController.text,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleMarkInvalid(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(moderationProvider.notifier).markReportInvalid(
            widget.report.id,
            _commentController.text,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleHidePost(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(moderationProvider.notifier).hidePost(
            widget.report.post.id,
            'Vi phạm tiêu chuẩn cộng đồng',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã ẩn bài viết')),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleDeletePost(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này vĩnh viễn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(moderationProvider.notifier).deletePost(
              widget.report.post.id,
              'Vi phạm nghiêm trọng chính sách',
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bài viết')),
          );
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $message'), backgroundColor: Colors.red),
      );
    }
  }
}
