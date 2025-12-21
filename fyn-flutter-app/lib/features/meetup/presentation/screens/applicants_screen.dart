import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';

/// Screen to view and manage applicants for a meetup
class ApplicantsScreen extends ConsumerStatefulWidget {
  final MeetupModel meetup;

  const ApplicantsScreen({super.key, required this.meetup});

  @override
  ConsumerState<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends ConsumerState<ApplicantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApplicants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicants() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(applicantsProvider(widget.meetup.id).notifier).load();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicantsState = ref.watch(applicantsProvider(widget.meetup.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Người đăng ký'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Chờ duyệt (${_countByStatus(applicantsState, MatchStatus.pending)})'),
            Tab(text: 'Đã chấp (${_countByStatus(applicantsState, MatchStatus.accepted)})'),
            Tab(text: 'Từ chối (${_countByStatus(applicantsState, MatchStatus.rejected)})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : applicantsState.when(
              data: (applicants) => TabBarView(
                controller: _tabController,
                children: [
                  _buildList(applicants.where((a) => a.status == MatchStatus.pending).toList(), true),
                  _buildList(applicants.where((a) => a.status == MatchStatus.accepted).toList(), false),
                  _buildList(applicants.where((a) => a.status == MatchStatus.rejected).toList(), false),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
            ),
    );
  }

  int _countByStatus(AsyncValue<List<MeetupMatchModel>> state, MatchStatus status) {
    return state.valueOrNull?.where((a) => a.status == status).length ?? 0;
  }

  Widget _buildList(List<MeetupMatchModel> applicants, bool showActions) {
    if (applicants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Không có ai', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplicants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applicants.length,
        itemBuilder: (context, index) {
          final applicant = applicants[index];
          return _ApplicantCard(
            applicant: applicant,
            showActions: showActions,
            onAccept: () => _handleAccept(applicant),
            onReject: () => _handleReject(applicant),
          );
        },
      ),
    );
  }

  Future<void> _handleAccept(MeetupMatchModel applicant) async {
    try {
      await ref.read(applicantsProvider(widget.meetup.id).notifier).accept(applicant.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chấp nhận ${applicant.user.fullName ?? applicant.user.username}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _handleReject(MeetupMatchModel applicant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn từ chối ${applicant.user.fullName ?? applicant.user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Từ chối')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(applicantsProvider(widget.meetup.id).notifier).reject(applicant.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã từ chối ${applicant.user.fullName ?? applicant.user.username}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}

/// Card widget for each applicant
class _ApplicantCard extends StatelessWidget {
  final MeetupMatchModel applicant;
  final bool showActions;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantCard({
    required this.applicant,
    required this.showActions,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final user = applicant.user;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(user.username[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? user.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(applicant.status),
              ],
            ),
            if (applicant.message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.message, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        applicant.message!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Từ chối'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check),
                      label: const Text('Chấp nhận'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MatchStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case MatchStatus.pending:
        color = Colors.orange;
        text = 'Chờ';
        break;
      case MatchStatus.accepted:
        color = Colors.green;
        text = 'Đã chấp';
        break;
      case MatchStatus.rejected:
        color = Colors.red;
        text = 'Từ chối';
        break;
      case MatchStatus.cancelled:
        color = Colors.grey;
        text = 'Đã hủy';
        break;
      case MatchStatus.confirmed:
        color = Colors.blue;
        text = 'Đã xác nhận';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
