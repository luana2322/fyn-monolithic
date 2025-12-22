import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/meetup_model.dart';
import '../../data/models/meetup_requests.dart';
import '../../data/models/meetup_enums.dart';
import '../providers/meetup_provider.dart';
import '../../../connections/presentation/widgets/map_location_picker.dart';
import '../../../connections/data/models/location_info.dart';

class EditMeetupScreen extends ConsumerStatefulWidget {
  final MeetupModel meetup;

  const EditMeetupScreen({
    super.key,
    required this.meetup,
  });

  @override
  ConsumerState<EditMeetupScreen> createState() => _EditMeetupScreenState();
}

class _EditMeetupScreenState extends ConsumerState<EditMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  
  late MeetType _meetType;
  String? _category;
  late DateTime _scheduledAt;
  late int _maxParticipants;
  late double _latitude;
  late double _longitude;
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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.meetup.title);
    _descriptionController = TextEditingController(text: widget.meetup.description);
    _locationController = TextEditingController(text: widget.meetup.location);
    _meetType = widget.meetup.meetType;
    _category = widget.meetup.category;
    _scheduledAt = widget.meetup.scheduledAt;
    _maxParticipants = widget.meetup.maxParticipants;
    _latitude = widget.meetup.latitude;
    _longitude = widget.meetup.longitude;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateMeetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final actualMaxParticipants = _meetType == MeetType.oneToOne ? 1 : _maxParticipants;
      
      final request = UpdateMeetupRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        meetType: _meetType,
        category: _category,
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        scheduledAt: _scheduledAt.toUtc(),
        maxParticipants: actualMaxParticipants,
      );

      await ref.read(updateMeetupProvider((
        id: widget.meetup.id,
        request: request,
      )).future);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meetup updated successfully!')),
        );
        ref.invalidate(meetupDetailProvider(widget.meetup.id));
        Navigator.pop(context, true);
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
        title: const Text('Edit Meetup'),
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
            
            OutlinedButton.icon(
              onPressed: _pickLocationOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Update location on map'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time
            ListTile(
              title: const Text('Date & Time *'),
              subtitle: Text(_scheduledAt.toString()),
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
            ],

            // Save Button
            FilledButton(
              onPressed: _isLoading ? null : _updateMeetup,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().isBefore(_scheduledAt) ? DateTime.now() : _scheduledAt,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
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
              initialLocation: LatLng(_latitude, _longitude),
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
