import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meetup_model.dart';
import 'discover_screen.dart';
import 'matches_screen.dart';
import 'public_dates_screen.dart';
import 'my_dates_screen.dart';

/// Main connection hub with bottom navigation for different connection types
/// Serves as the central navigation for Dating, Friendship, Hobbies, Groups, Community
class ConnectionHubScreen extends ConsumerStatefulWidget {
  const ConnectionHubScreen({super.key});

  @override
  ConsumerState<ConnectionHubScreen> createState() => _ConnectionHubScreenState();
}

class _ConnectionHubScreenState extends ConsumerState<ConnectionHubScreen> {
  int _currentIndex = 0;
  ConnectionType _selectedType = ConnectionType.dating;

  // Pages for bottom navigation
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const DiscoverScreen(),
      const MatchesScreen(),
      const PublicDatesScreen(),
      const MyDatesScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(theme),
      floatingActionButton: _currentIndex >= 2
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDateSheet(),
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            )
          : null,
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.explore,
                label: 'Discover',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
                color: Colors.pink,
              ),
              _NavItem(
                icon: Icons.favorite,
                label: 'Matches',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
                color: Colors.red,
              ),
              _NavItem(
                icon: Icons.calendar_today,
                label: 'Dates',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
                color: Colors.purple,
              ),
              _NavItem(
                icon: Icons.event_note,
                label: 'My Plans',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const CreateDateSheet(),
      ),
    );
  }
}

/// Bottom navigation item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for creating a new date/meetup
class CreateDateSheet extends ConsumerStatefulWidget {
  const CreateDateSheet({super.key});

  @override
  ConsumerState<CreateDateSheet> createState() => _CreateDateSheetState();
}

class _CreateDateSheetState extends ConsumerState<CreateDateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeNameController = TextEditingController();
  final _placeAddressController = TextEditingController();

  PlaceType _selectedPlaceType = PlaceType.cafe;
  ConnectionType _selectedConnectionType = ConnectionType.dating;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeNameController.dispose();
    _placeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Create a Date Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection type selector
                  _buildSectionLabel('Connection Type'),
                  _buildConnectionTypeSelector(),
                  const SizedBox(height: 24),

                  // Title
                  _buildSectionLabel('What\'s the plan?'),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('e.g., Coffee & Chat'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Description (optional)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Place type
                  _buildSectionLabel('Place Type'),
                  _buildPlaceTypeSelector(),
                  const SizedBox(height: 16),

                  // Place name
                  TextFormField(
                    controller: _placeNameController,
                    decoration: _inputDecoration('Place name (optional)'),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _placeAddressController,
                    decoration: _inputDecoration('Address (optional)').copyWith(
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date and time
                  _buildSectionLabel('When?'),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeButton(
                          icon: Icons.calendar_today,
                          label: _formatDate(_selectedDate),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateTimeButton(
                          icon: Icons.access_time,
                          label: _selectedTime.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Public toggle
                  _buildSectionLabel('Visibility'),
                  SwitchListTile(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    title: const Text('Make it public'),
                    subtitle: const Text('Others can browse and send proposals'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        // Submit button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Date Plan', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildConnectionTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ConnectionType.values.map((type) {
          final isSelected = type == _selectedConnectionType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${type.emoji} ${type.label}'),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedConnectionType = type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PlaceType.values.take(6).map((type) {
        final isSelected = type == _selectedPlaceType;
        return ChoiceChip(
          label: Text('${type.emoji} ${type.label}'),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedPlaceType = type),
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'placeType': _selectedPlaceType.value,
      'placeName': _placeNameController.text.trim(),
      'placeAddress': _placeAddressController.text.trim(),
      'scheduledAt': scheduledAt.toIso8601String(),
      'isPublic': _isPublic,
      'connectionType': _selectedConnectionType.value,
    };

    // TODO: Call API to create date
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date plan created!')),
      );
    }
  }
}

class _DateTimeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
