import 'package:flutter/material.dart';
import '../../data/models/report_reason.dart';

class ReportModal extends StatefulWidget {
  final Function(ReportReason reason, String? description) onReport;

  const ReportModal({super.key, required this.onReport});

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  ReportReason? _selectedReason;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Báo cáo bài viết',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tại sao bạn muốn báo cáo bài viết này?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ...ReportReason.values.map((reason) {
            return RadioListTile<ReportReason>(
              title: Text(reason.displayName),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            );
          }).toList(),
          if (_selectedReason == ReportReason.OTHER) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Mô tả chi tiết lý do...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedReason == null
                  ? null
                  : () {
                      widget.onReport(
                        _selectedReason!,
                        _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text,
                      );
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Gửi báo cáo'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
