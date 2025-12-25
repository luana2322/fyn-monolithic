import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import 'edit_meetup_screen.dart';
import '../../../message/presentation/screens/chat_detail_screen.dart';
import '../../../message/presentation/providers/message_provider.dart';

/// Owner view for meetup details - shows full info + applicants management
class OwnerMeetupDetailScreen extends ConsumerStatefulWidget {
  final MeetupModel meetup;

  const OwnerMeetupDetailScreen({super.key, required this.meetup});

  @override
  ConsumerState<OwnerMeetupDetailScreen> createState() => _OwnerMeetupDetailScreenState();
}

class _OwnerMeetupDetailScreenState extends ConsumerState<OwnerMeetupDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
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
    final meetup = widget.meetup;
    final applicantsState = ref.watch(applicantsProvider(meetup.id));
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with title
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                meetup.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('✏️ Chỉnh sửa')),
                  const PopupMenuItem(value: 'cancel', child: Text('❌ Hủy cuộc hẹn')),
                ],
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ Core Meet Info Card
                  _buildMeetInfoCard(meetup),
                  const SizedBox(height: 24),

                  // 3️⃣ Quick Stats
                  _buildQuickStats(applicantsState),
                  const SizedBox(height: 16),

                  // 3️⃣ Smart Suggestions (Phase 3)
                  _buildSmartSuggestions(applicantsState),
                  const SizedBox(height: 24),

                  // 4️⃣ Post-Match View (Phase 4) - only if matched
                  if (meetup.status == MeetupStatus.matched || 
                      meetup.status == MeetupStatus.waitingConfirmation)
                    _buildPostMatchSection(applicantsState),

                  // 5️⃣ Confirmation Section (Phase 5) - after meet time
                  if (meetup.scheduledAt.isBefore(DateTime.now()) &&
                      meetup.status == MeetupStatus.waitingConfirmation)
                    _buildConfirmationSection(meetup),

                  // 2️⃣ Applicants Section Header
                  _buildSectionHeader(
                    'Người đăng ký',
                    applicantsState.valueOrNull?.length ?? 0,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // 2️⃣ Applicants List
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildApplicantsList(applicantsState),
        ],
      ),
    );
  }

  // ============== 1️⃣ CORE MEET INFO CARD ==============
  Widget _buildMeetInfoCard(MeetupModel meetup) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d/M/yyyy • HH:mm');
    final countdown = _getCountdown(meetup.scheduledAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + Type Row
            Row(
              children: [
                _buildStatusBadge(meetup.status),
                const SizedBox(width: 8),
                _buildTypeBadge(meetup.meetType),
                const Spacer(),
                Text(
                  '${meetup.acceptedCount}/${meetup.maxParticipants} người',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time
            Row(
              children: [
                Icon(Icons.schedule, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(meetup.scheduledAt),
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (countdown != null)
                        Text(
                          countdown,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meetup.location ?? 'Unknown location',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                // Map button
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () => _openMap(meetup),
                  tooltip: 'Mở bản đồ',
                ),
              ],
            ),

            // Description
            if (meetup.description != null && meetup.description!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                meetup.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============== 3️⃣ QUICK STATS ==============
  Widget _buildQuickStats(AsyncValue<List<MeetupMatchModel>> applicantsState) {
    final applicants = applicantsState.valueOrNull ?? [];
    final pending = applicants.where((a) => a.status == MatchStatus.pending).length;
    final accepted = applicants.where((a) => a.status == MatchStatus.accepted).length;
    final rejected = applicants.where((a) => a.status == MatchStatus.rejected).length;

    return Row(
      children: [
        _buildStatCard('Chờ duyệt', pending, Colors.orange),
        const SizedBox(width: 8),
        _buildStatCard('Đã chấp', accepted, Colors.green),
        const SizedBox(width: 8),
        _buildStatCard('Từ chối', rejected, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ============== 3️⃣ SMART SUGGESTIONS (Phase 3) ==============
  Widget _buildSmartSuggestions(AsyncValue<List<MeetupMatchModel>> state) {
    final applicants = state.valueOrNull ?? [];
    final pending = applicants.where((a) => a.status == MatchStatus.pending).toList();
    
    if (pending.isEmpty) return const SizedBox.shrink();

    // Sort by earliest apply
    pending.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.now();
      final bDate = b.createdAt ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
    final earliest = pending.first;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? Colors.amber.withOpacity(0.15) : Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700], size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Gợi ý thông minh',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem(
              '🥇 Apply sớm nhất',
              earliest.user.fullName ?? earliest.user.username,
              earliest.user.fullAvatarUrl,
              () => _acceptApplicant(earliest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String label, String name, String? avatarUrl, VoidCallback onAccept) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? Text(name[0].toUpperCase()) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onAccept,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('Chọn'),
          ),
        ],
      ),
    );
  }

  // ============== 4️⃣ POST-MATCH VIEW (Phase 4) ==============
  Widget _buildPostMatchSection(AsyncValue<List<MeetupMatchModel>> state) {
    final accepted = state.valueOrNull?.where((a) => a.status == MatchStatus.accepted).toList() ?? [];
    
    if (accepted.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade100, Colors.green.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Đã match thành công!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Matched users avatars
              Row(
                children: [
                  ...accepted.take(5).map((a) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: a.user.fullAvatarUrl != null 
                          ? NetworkImage(a.user.fullAvatarUrl!) 
                          : null,
                      child: a.user.fullAvatarUrl == null 
                          ? Text(a.user.username[0].toUpperCase()) 
                          : null,
                    ),
                  )),
                  if (accepted.length > 5)
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Text('+${accepted.length - 5}'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openGroupChat(accepted),
                      icon: const Icon(Icons.chat),
                      label: const Text('Mở Chat'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openMap(widget.meetup),
                      icon: const Icon(Icons.map),
                      label: const Text('Dẫn đường'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ============== 5️⃣ CONFIRMATION SECTION (Phase 5) ==============
  Widget _buildConfirmationSection(MeetupModel meetup) {
    final hoursSinceMeet = DateTime.now().difference(meetup.scheduledAt).inHours;
    final confirmDeadline = 24 - hoursSinceMeet;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.amber.withOpacity(0.15) : Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Xác nhận cuộc hẹn',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                confirmDeadline > 0 
                    ? 'Còn $confirmDeadline giờ để xác nhận'
                    : 'Hết hạn xác nhận',
                style: TextStyle(color: Colors.amber[isDark ? 500 : 800]),
              ),
              const SizedBox(height: 16),
              
              // Confirmation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmMeetup('NO_SHOW'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Không gặp'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _confirmMeetup('SUCCESS'),
                      icon: const Icon(Icons.check),
                      label: const Text('Đã gặp'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ============== 2️⃣ APPLICANTS LIST ==============
  Widget _buildApplicantsList(AsyncValue<List<MeetupMatchModel>> state) {
    return state.when(
      data: (applicants) {
        if (applicants.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có ai đăng ký',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // Sort: pending first, then by apply time
        final sorted = [...applicants]
          ..sort((a, b) {
            if (a.status == MatchStatus.pending && b.status != MatchStatus.pending) return -1;
            if (b.status == MatchStatus.pending && a.status != MatchStatus.pending) return 1;
            final aDate = a.createdAt ?? DateTime.now();
            final bDate = b.createdAt ?? DateTime.now();
            return bDate.compareTo(aDate);
          });

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildApplicantCard(sorted[index]),
            childCount: sorted.length,
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildApplicantCard(MeetupMatchModel applicant) {
    final user = applicant.user;
    final isPending = applicant.status == MatchStatus.pending;
    final isAccepted = applicant.status == MatchStatus.accepted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Status
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user.fullAvatarUrl != null
                      ? NetworkImage(user.fullAvatarUrl!)
                      : null,
                  child: user.fullAvatarUrl == null
                      ? Text(user.username[0].toUpperCase(), style: const TextStyle(fontSize: 20))
                      : null,
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _buildApplicantStatus(applicant.status),
              ],
            ),

            // Message
            if (applicant.message != null && applicant.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        applicant.message!,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Tags
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                if (applicant.createdAt != null)
                  _buildTag('${_timeAgo(applicant.createdAt!)}', Icons.access_time),
                // Add more tags here based on data
              ],
            ),

            // Action buttons (only for pending)
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectApplicant(applicant),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Từ\nchối', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: () => _openChat(applicant),
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Cha\nt', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FilledButton.icon(
                      onPressed: () => _acceptApplicant(applicant),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Nhận', style: TextStyle(fontSize: 11)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Chat button (for accepted)
            if (isAccepted && applicant.conversationId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openChat(applicant),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Mở Chat'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============== HELPER WIDGETS ==============
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(MeetupStatus status) {
    Color color;
    String text;

    switch (status) {
      case MeetupStatus.open:
        color = Colors.green;
        text = 'OPEN';
        break;
      case MeetupStatus.matched:
        color = Colors.blue;
        text = 'MATCHED';
        break;
      case MeetupStatus.waitingConfirmation:
        color = Colors.amber;
        text = 'CHỜ XÁC NHẬN';
        break;
      case MeetupStatus.completed:
        color = Colors.purple;
        text = 'DONE';
        break;
      case MeetupStatus.cancelled:
        color = Colors.grey;
        text = 'CANCELLED';
        break;
      case MeetupStatus.expired:
        color = Colors.red;
        text = 'HẾT HẠN';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTypeBadge(MeetType type) {
    final isOneToOne = type == MeetType.oneToOne;
    final color = isOneToOne ? Colors.purple : Colors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOneToOne ? '1-1' : 'Group',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildApplicantStatus(MatchStatus status) {
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
        text = 'Hủy';
        break;
      case MatchStatus.confirmed:
        color = Colors.blue;
        text = 'Xác nhận';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  // ============== HELPERS ==============
  String? _getCountdown(DateTime scheduledAt) {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);

    if (diff.isNegative) return 'Đã qua';
    if (diff.inDays > 0) return 'Còn ${diff.inDays} ngày';
    if (diff.inHours > 0) return 'Còn ${diff.inHours} giờ';
    if (diff.inMinutes > 0) return 'Còn ${diff.inMinutes} phút';
    return 'Sắp diễn ra';
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d trước';
    if (diff.inHours > 0) return '${diff.inHours}h trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m trước';
    return 'Vừa xong';
  }

  // ============== ACTIONS ==============
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditMeetupScreen(meetup: widget.meetup),
          ),
        ).then((updated) {
          if (updated == true && mounted) {
            // Since this screen takes a model, we might need to refresh it
            // or use a provider in the parent. For now, pop with true to notify parent.
            Navigator.pop(context, true);
          }
        });
        break;
      case 'cancel':
        _confirmCancelMeetup();
        break;
    }
  }

  Future<void> _confirmCancelMeetup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy cuộc hẹn?'),
        content: const Text('Bạn có chắc muốn hủy cuộc hẹn này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy cuộc hẹn', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Call cancel API
        await ref.read(meetupRepositoryProvider).cancelMeetup(widget.meetup.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy cuộc hẹn thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate cancellation
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi hủy cuộc hẹn: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _acceptApplicant(MeetupMatchModel applicant) async {
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

  Future<void> _rejectApplicant(MeetupMatchModel applicant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Từ chối ${applicant.user.fullName ?? applicant.user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
          ),
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

  Future<void> _openMap(MeetupModel meetup) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${meetup.latitude},${meetup.longitude}';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở bản đồ')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi mở bản đồ: $e')),
        );
      }
    }
  }

  Future<void> _openChat(MeetupMatchModel applicant) async {
    String? conversationId = applicant.conversationId;

    if (conversationId == null) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang khởi tạo cuộc trò chuyện...')),
      );

      try {
        final updatedMatch = await ref
            .read(applicantsProvider(widget.meetup.id).notifier)
            .initiateChat(applicant.id);
        conversationId = updatedMatch.conversationId;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể khởi tạo chat: $e')),
          );
        }
        return;
      }
    }

    if (conversationId == null) return;

    try {
      final messageRepo = ref.read(messageRepositoryProvider);
      final conversation = await messageRepo.getConversationById(conversationId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở chat: $e')),
        );
      }
    }
  }

  Future<void> _openGroupChat(List<MeetupMatchModel> accepted) async {
    if (accepted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có người tham gia được chấp nhận')),
      );
      return;
    }

    // Find first match with conversationId
    final matchWithChat = accepted.firstWhere(
      (m) => m.conversationId != null,
      orElse: () => accepted.first,
    );

    if (matchWithChat.conversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có cuộc hội thoại được tạo')),
      );
      return;
    }

    try {
      final messageRepo = ref.read(messageRepositoryProvider);
      final conversation = await messageRepo.getConversationById(matchWithChat.conversationId!);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở chat: $e')),
        );
      }
    }
  }

  Future<void> _confirmMeetup(String result) async {
    double rating = 5.0;
    String? feedback;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(result == 'SUCCESS' ? 'Xác nhận thành công' : 'Xác nhận không gặp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn đánh giá cuộc gặp này thế nào?'),
              const SizedBox(height: 16),
              const Text('Rating:'),
              Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: rating.toString(),
                onChanged: (val) => setState(() => rating = val),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (val) => feedback = val,
                decoration: const InputDecoration(
                  labelText: 'Góp ý (Tùy chọn)',
                  hintText: 'Chia sẻ trải nghiệm...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(confirmMeetupProvider((
                    meetupId: widget.meetup.id,
                    result: result,
                    feedback: feedback,
                    rating: rating,
                  )).future);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi xác nhận và đánh giá'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }
}
