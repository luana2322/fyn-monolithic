import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

// State for the list of events
final eventsListProvider = FutureProvider.autoDispose.family<List<EventModel>, Map<String, double>?>((ref, location) async {
  final repository = ref.watch(eventRepositoryProvider);
  final lat = location?['lat'];
  final lng = location?['lng'];
  
  return repository.getEvents(lat: lat, lng: lng);
});

// State for a single event details
final eventDetailsProvider = FutureProvider.autoDispose.family<EventModel, String>((ref, id) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvent(id);
});

// Notifier for creating events (if needed to track loading state of creation)
class CreateEventNotifier extends StateNotifier<AsyncValue<EventModel?>> {
  final EventRepository _repository;

  CreateEventNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createEvent(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final event = await _repository.createEvent(data);
      state = AsyncValue.data(event);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createEventProvider = StateNotifierProvider<CreateEventNotifier, AsyncValue<EventModel?>>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return CreateEventNotifier(repository);
});
