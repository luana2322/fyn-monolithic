import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meetup_model.dart';
import '../providers/dates_provider.dart';
import '../widgets/date_card.dart';

/// Screen showing public dates available for proposals
class PublicDatesScreen extends ConsumerStatefulWidget {
  const PublicDatesScreen({super.key});

  @override
  ConsumerState<PublicDatesScreen> createState() => _PublicDatesScreenState();
}

class _PublicDatesScreenState extends ConsumerState<PublicDatesScreen> {
  PlaceType? _selectedPlaceType;
  ConnectionType? _selectedConnectionType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(publicDatesProvider.notifier).loadDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicDatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Dates'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilters(),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Place type filter
          ...PlaceType.values.take(5).map((type) {
            final isSelected = type == _selectedPlaceType;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${type.emoji} ${type.label}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPlaceType = selected ? type : null;
                  });
                  ref.read(publicDatesProvider.notifier).loadDates(
                    placeType: _selectedPlaceType?.value,
                    connectionType: _selectedConnectionType,
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBody(PublicDatesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(publicDatesProvider.notifier).loadDates(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.dates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No dates available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create one!',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(publicDatesProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.dates.length,
        itemBuilder: (context, index) {
          final date = state.dates[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DateCard(
              date: date,
              onTap: () => _showDateDetails(date),
              onPropose: () => _showProposalSheet(date),
            ),
          );
        },
      ),
    );
  }

  void _showDateDetails(dynamic date) {
    // TODO: Navigate to date detail screen
  }

  void _showProposalSheet(dynamic date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProposalSheet(dateId: date.id, dateTitle: date.title),
    );
  }
}

/// Bottom sheet for sending a proposal
class ProposalSheet extends ConsumerStatefulWidget {
  final String dateId;
  final String dateTitle;

  const ProposalSheet({
    super.key,
    required this.dateId,
    required this.dateTitle,
  });

  @override
  ConsumerState<ProposalSheet> createState() => _ProposalSheetState();
}

class _ProposalSheetState extends ConsumerState<ProposalSheet> {
  final _messageController = TextEditingController();
  bool _suggestDifferentTime = false;
  DateTime? _proposedTime;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalsProvider(widget.dateId));

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Join "${widget.dateTitle}"',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Message input
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Say something nice...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Suggest different time option
            CheckboxListTile(
              value: _suggestDifferentTime,
              onChanged: (v) => setState(() => _suggestDifferentTime = v ?? false),
              title: const Text('Suggest a different time'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_suggestDifferentTime)
              OutlinedButton.icon(
                onPressed: _pickProposedTime,
                icon: const Icon(Icons.schedule),
                label: Text(_proposedTime != null
                    ? _formatDateTime(_proposedTime!)
                    : 'Select time'),
              ),
            const SizedBox(height: 24),
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.isSending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Proposal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProposedTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _proposedTime = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final success = await ref.read(proposalsProvider(widget.dateId).notifier).sendProposal(
      message: _messageController.text.trim(),
      proposedTime: _suggestDifferentTime ? _proposedTime : null,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal sent!')),
      );
    }
  }
}
