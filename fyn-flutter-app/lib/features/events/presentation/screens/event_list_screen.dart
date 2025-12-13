import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/event_provider.dart';
import '../../data/models/event_model.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, pass null location to fetch default events (or mock location)
    final eventsAsyncValue = ref.watch(eventsListProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/events/create'),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Open map view
            }, 
          ),
        ],
      ),
      body: eventsAsyncValue.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events found nearby'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(event: event);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/events/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.coverImageUrl != null)
              Image.network(
                event.coverImageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 150, color: Colors.grey[300]),
              )
            else
              Container(
                height: 150,
                color: Colors.primaries[event.title.length % Colors.primaries.length],
                child: Center(
                  child: Text(
                    event.activityType,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.activityType.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.startTime != null)
                        Text(
                          _formatDate(event.startTime), // Helper to format date
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.locationName ?? event.locationAddress ?? 'Online',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants} going',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (event.createdBy != null) ...[
                        CircleAvatar(
                          backgroundImage: event.createdBy!.avatarUrl != null
                              ? NetworkImage(event.createdBy!.avatarUrl!)
                              : null,
                          radius: 12,
                          child: event.createdBy!.avatarUrl == null
                              ? Text(event.createdBy!.username[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 8),
                         Text(
                          event.createdBy!.fullName ?? event.createdBy!.username,
                           style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatter, consider using intl package
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
