import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/dating_colors.dart';

/// Widget for confirming attendance after a meetup ends
class AttendanceConfirmationWidget extends ConsumerStatefulWidget {
  final String meetupId;
  final String meetupTitle;
  final VoidCallback? onConfirmed;

  const AttendanceConfirmationWidget({
    super.key,
    required this.meetupId,
    required this.meetupTitle,
    this.onConfirmed,
  });

  @override
  ConsumerState<AttendanceConfirmationWidget> createState() =>
      _AttendanceConfirmationWidgetState();
}

class _AttendanceConfirmationWidgetState
    extends ConsumerState<AttendanceConfirmationWidget> {
  String _selectedStatus = 'CONFIRMED';
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitAttendance() async {
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: Call AttendanceService.confirmAttendance via API
      // final response = await attendanceRepository.confirmAttendance(
      //   meetupId: widget.meetupId,
      //   status: _selectedStatus,
      //   feedback: _feedbackController.text,
      //   rating: _rating,
      // );
      
      widget.onConfirmed?.call();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã xác nhận tham dự!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DatingColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.event_available,
                color: isDark ? DatingColors.darkPrimary : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Xác nhận tham dự',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.meetupTitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? DatingColors.darkSecondaryText : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Status selection
          Text(
            'Bạn đã tham dự meetup này chưa?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatusButton(
                  label: 'Đã tham dự ✓',
                  isSelected: _selectedStatus == 'CONFIRMED',
                  color: Colors.green,
                  onTap: () => setState(() => _selectedStatus = 'CONFIRMED'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusButton(
                  label: 'Không tham dự',
                  isSelected: _selectedStatus == 'NO_SHOW',
                  color: Colors.red,
                  onTap: () => setState(() => _selectedStatus = 'NO_SHOW'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Rating (only if confirmed)
          if (_selectedStatus == 'CONFIRMED') ...[
            Text(
              'Đánh giá meetup',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(
                    starValue <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = starValue.toDouble()),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],

          // Feedback
          Text(
            'Nhận xét (tùy chọn)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? DatingColors.darkPrimaryText : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? DatingColors.darkSurfaceElevated : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedStatus == 'CONFIRMED' 
                    ? Colors.green 
                    : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _selectedStatus == 'CONFIRMED' 
                          ? 'Xác nhận đã tham dự'
                          : 'Báo cáo không tham dự',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? color : Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// Show the attendance confirmation dialog
void showAttendanceConfirmationDialog(
  BuildContext context, {
  required String meetupId,
  required String meetupTitle,
  VoidCallback? onConfirmed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AttendanceConfirmationWidget(
      meetupId: meetupId,
      meetupTitle: meetupTitle,
      onConfirmed: onConfirmed,
    ),
  );
}
