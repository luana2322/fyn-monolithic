import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/meetup_requests.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import '../../../connections/presentation/widgets/map_location_picker.dart';
import '../../../connections/data/models/location_info.dart';

class CreateMeetupScreen extends ConsumerStatefulWidget {
  const CreateMeetupScreen({super.key});

  @override
  ConsumerState<CreateMeetupScreen> createState() => _CreateMeetupScreenState();
}

class _CreateMeetupScreenState extends ConsumerState<CreateMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  MeetType _meetType = MeetType.group;
  String? _category;
  DateTime? _scheduledAt;
  int _maxParticipants = 5;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isLoading = false;

  final List<String> _categories = [
    'Sports',
    'Gaming',
    'Music',
    'Art',
    'Food',
    'Tech',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createMeetup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ONE_TO_ONE meetups must have maxParticipants = 1
      final actualMaxParticipants = _meetType == MeetType.oneToOne ? 1 : _maxParticipants;
      
      final request = CreateMeetupRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        meetType: _meetType,
        category: _category,
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        scheduledAt: _scheduledAt!,
        maxParticipants: actualMaxParticipants,
      );

      final result = await ref.read(createMeetupProvider(request).future);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meetup created successfully!')),
        );
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meetup'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Coffee & Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Tell people what this meetup is about...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Meet Type
            Text('Meet Type *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<MeetType>(
              segments: const [
                ButtonSegment(
                  value: MeetType.oneToOne,
                  label: Text('1-on-1'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: MeetType.group,
                  label: Text('Group'),
                  icon: Icon(Icons.group),
                ),
              ],
              selected: {_meetType},
              onSelectionChanged: (Set<MeetType> newSelection) {
                setState(() {
                  _meetType = newSelection.first;
                  if (_meetType == MeetType.oneToOne) {
                    _maxParticipants = 1;
                  } else if (_maxParticipants == 1) {
                    _maxParticipants = 5;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'e.g., Starbucks, Main St',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Map Picker Button
            OutlinedButton.icon(
              onPressed: _pickLocationOnMap,
              icon: const Icon(Icons.map),
              label: Text(_latitude != 0.0 && _longitude != 0.0
                  ? 'Update location on map'
                  : 'Pick location on map'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            if (_latitude != 0.0 && _longitude != 0.0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Location: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Date & Time
            ListTile(
              title: const Text('Date & Time *'),
              subtitle: Text(
                _scheduledAt != null
                    ? _scheduledAt.toString()
                    : 'Tap to select',
              ),
              leading: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),

            // Max Participants
            if (_meetType != MeetType.oneToOne) ...[
              Text(
                'Max Participants: $_maxParticipants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _maxParticipants.toDouble(),
                min: 2,
                max: 20,
                divisions: 18,
                label: _maxParticipants.toString(),
                onChanged: (value) {
                  setState(() => _maxParticipants = value.toInt());
                },
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 16),

            // Create Button
            FilledButton(
              onPressed: _isLoading ? null : _createMeetup,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Meetup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickLocationOnMap() async {
    try {
      // Use current location as default or existing coordinates
      final initialLat = _latitude != 0.0 ? _latitude : null;
      final initialLng = _longitude != 0.0 ? _longitude : null;
      
      // Use full-screen modal with MapLocationPicker
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Pick Location'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: MapLocationPicker(
              initialLocation: initialLat != null && initialLng != null
                  ? LatLng(initialLat, initialLng)
                  : null,
              onLocationSelected: (LocationInfo location) {
                setState(() {
                  _locationController.text = location.name;
                  _latitude = location.latitude;
                  _longitude = location.longitude;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking location: $e')),
        );
      }
    }
  }
}
