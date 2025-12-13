import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import 'package:go_router/go_router.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _activityType = 'COFFEE';
  DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  int _maxParticipants = 4;

  @override
  Widget build(BuildContext context) {
    final createEventState = ref.watch(createEventProvider);
    
    // Listen for success
    ref.listen(createEventProvider, (previous, next) {
      next.whenData((event) {
        if (event != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
          context.pop(); // Go back to list
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
             DropdownButtonFormField<String>(
              value: _activityType,
              items: ['COFFEE', 'SPORTS', 'DINNER', 'STUDY', 'OTHER']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _activityType = v!),
              decoration: const InputDecoration(labelText: 'Activity Type'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
               title: const Text('Start Time'),
               subtitle: Text('${_startTime.toLocal()}'),
               trailing: const Icon(Icons.calendar_today),
               onTap: () async {
                 final date = await showDatePicker(
                   context: context,
                   initialDate: _startTime,
                   firstDate: DateTime.now(),
                   lastDate: DateTime.now().add(const Duration(days: 365)),
                 );
                 if (date != null) {
                   final time = await showTimePicker(
                     context: context,
                     initialTime: TimeOfDay.fromDateTime(_startTime),
                   );
                   if (time != null) {
                     setState(() {
                       _startTime = DateTime(
                         date.year, date.month, date.day, time.hour, time.minute
                       );
                     });
                   }
                 }
               },
            ),
             const SizedBox(height: 16),
             TextFormField(
               controller: _locationController,
               decoration: const InputDecoration(labelText: 'Location Name'),
             ),
             const SizedBox(height: 16),
             Row(
               children: [
                 const Text('Max Participants: '),
                 Expanded(
                   child: Slider(
                     value: _maxParticipants.toDouble(),
                     min: 2,
                     max: 20,
                     divisions: 18,
                     label: '$_maxParticipants',
                     onChanged: (v) => setState(() => _maxParticipants = v.toInt()),
                   ),
                 ),
                 Text('$_maxParticipants'),
               ],
             ),
             const SizedBox(height: 32),
             ElevatedButton(
               onPressed: createEventState.isLoading ? null : _submit,
               child: createEventState.isLoading 
                   ? const CircularProgressIndicator()
                   : const Text('Create Event'),
             ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'title': _titleController.text,
        'description': _descController.text,
        'activityType': _activityType,
        'startTime': _startTime.toIso8601String(),
        'maxParticipants': _maxParticipants,
        'locationName': _locationController.text,
        // Add other fields as necessary mapped to DTO
      };
      
      ref.read(createEventProvider.notifier).createEvent(data);
    }
  }
}
