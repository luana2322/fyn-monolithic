import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/match_repository.dart';
import '../../../../core/network/dio_provider.dart';

/// Dialog for submitting post-date feedback
/// Shows 12-24h after scheduled date time
class DateFeedbackDialog extends ConsumerStatefulWidget {
  final String matchId;
  final String partnerName;

  const DateFeedbackDialog({
    super.key,
    required this.matchId,
    required this.partnerName,
  });

  @override
  ConsumerState<DateFeedbackDialog> createState() => _DateFeedbackDialogState();
}

class _DateFeedbackDialogState extends ConsumerState<DateFeedbackDialog> {
  bool? _didMeet;
  String? _noShowReason;
  String? _rating;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'How was your date?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'with ${widget.partnerName}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Did you meet question
            const Text(
              'Did you meet up?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Yes, we met',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isSelected: _didMeet == true,
                    onTap: () => setState(() {
                      _didMeet = true;
                      _noShowReason = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    label: 'No, we didn\'t',
                    icon: Icons.cancel,
                    color: Colors.red,
                    isSelected: _didMeet == false,
                    onTap: () => setState(() {
                      _didMeet = false;
                      _rating = null;
                    }),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Conditional questions
            if (_didMeet == true) ...[
              const Text(
                'How was it?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRatingButton('😊', 'good', Colors.green),
                  _buildRatingButton('😐', 'neutral', Colors.orange),
                  _buildRatingButton('😞', 'bad', Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Any comments? (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
            
            if (_didMeet == false) ...[
              const Text(
                'What happened?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildReasonTile(
                    'The other person didn\'t show up',
                    'partner_no_show',
                  ),
                  _buildReasonTile(
                    'Date was cancelled',
                    'cancelled',
                  ),
                  _buildReasonTile(
                    'Other reason',
                    'other',
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitFeedback : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(String emoji, String value, Color color) {
    final isSelected = _rating == value;
    return InkWell(
      onTap: () => setState(() => _rating = value),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile(String label, String value) {
    final isSelected = _noShowReason == value;
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _noShowReason,
      onChanged: (val) => setState(() => _noShowReason = val),
      activeColor: Colors.blue,
    );
  }

  bool _canSubmit() {
    if (_didMeet == null) return false;
    if (_didMeet == true && _rating == null) return false;
    if (_didMeet == false && _noShowReason == null) return false;
    return true;
  }

  Future<void> _submitFeedback() async {
    if (!_canSubmit()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = MatchRepository(ref.read(apiClientProvider));
      
      await repository.submitFeedback(
        widget.matchId,
        didMeet: _didMeet!,
        noShowReason: _noShowReason,
        rating: _rating,
        feedbackText: _feedbackController.text.trim().isNotEmpty
            ? _feedbackController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
