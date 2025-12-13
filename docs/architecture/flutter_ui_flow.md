# Flutter UI Flow & Navigation Design

## Navigation Structure

```
App
├── /splash
├── /onboarding (first-time users)
│
├── 🔐 Auth Flow
│   ├── /login
│   └── /register
│
├── 🏠 Main (Bottom Navigation)
│   ├── /discover (Tab 1)
│   ├── /events (Tab 2)
│   ├── /groups (Tab 3)
│   ├── /chat (Tab 4)
│   └── /profile (Tab 5)
│
├── 👤 Profile & Settings
│   ├── /profile/edit
│   ├── /profile/:userId
│   ├── /settings
│   └── /settings/preferences
│
├── 🎯 Matching & Connections
│   ├── /discover
│   ├── /discover/filters
│   └── /connections
│
├── 📅 Events
│   ├── /events
│   ├── /events/create
│   ├── /events/:id
│   ├── /events/:id/participants
│   ├── /events/:id/edit
│   └── /events/:id/occurrences
│
├── 👥 Groups
│   ├── /groups
│   ├── /groups/create
│   ├── /groups/:id
│   └── /groups/:id/members
│
├── 💬 Chat
│   ├── /chat
│   ├── /chat/:roomId
│   └── /chat/:roomId/info
│
└── 🛡️ Safety
    ├── /safety/sos
    └── /safety/report
```

---

## Screen Breakdown

### 1. Discover Screen (Swipe Cards)

```
┌─────────────────────────────────────┐
│  ← Discover    [Filter] [Context ▼] │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │      [User Photo Card]      │   │
│  │                             │   │
│  │  ┌───────────────────────┐  │   │
│  │  │ Name, 25     ✓ 4.8★   │  │   │
│  │  │ 2.3 km away           │  │   │
│  │  │ 📷 Photography, ☕ Coffee │  │   │
│  │  │                       │  │   │
│  │  │ "85% Match"           │  │   │
│  │  └───────────────────────┘  │   │
│  └─────────────────────────────┘   │
│                                     │
│         [✗]    [★]    [❤️]         │
│         Pass  Super   Like          │
│                                     │
└─────────────────────────────────────┘
```

**File**: `lib/features/matching/presentation/screens/discover_screen.dart`

```dart
class DiscoverScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingState = ref.watch(matchingProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        actions: [
          IconButton(icon: Icon(Icons.tune), onPressed: _openFilters),
          _buildContextSelector(), // dating/friendship/activity
        ],
      ),
      body: matchingState.when(
        loading: () => ShimmerCards(),
        error: (e, _) => ErrorWidget(e),
        data: (users) => SwipeableStack(
          users: users,
          onSwipe: (user, direction) => _handleSwipe(user, direction),
        ),
      ),
      bottomSheet: MatchActions(
        onPass: () => _swipe(SwipeDirection.left),
        onSuperLike: () => _swipe(SwipeDirection.up),
        onLike: () => _swipe(SwipeDirection.right),
      ),
    );
  }
}
```

---

### 2. Events List Screen

```
┌─────────────────────────────────────┐
│  Events          [+ Create] [Map]   │
├─────────────────────────────────────┤
│ [🔍 Search events...]               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Filters: ☕ Coffee  📍 5km  📅 Today │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ☕ Coffee & Chat                 │ │
│ │ Tomorrow, 10:00 AM               │ │
│ │ The Workshop • 1.2 km           │ │
│ │ 4/6 going  🔄 Weekly             │ │
│ │ [👤 Host: Minh ✓]               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🏃 Morning Run D1                │ │
│ │ Sat, 6:00 AM                     │ │
│ │ Tao Dan Park • 3.5 km           │ │
│ │ 8/10 going                       │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**File**: `lib/features/events/presentation/screens/events_list_screen.dart`

```dart
class EventsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsProvider);
    final filters = ref.watch(eventFiltersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _createEvent),
          IconButton(icon: Icon(Icons.map), onPressed: _openMap),
        ],
      ),
      body: Column(
        children: [
          SearchBar(onChanged: (q) => ref.read(eventsProvider.notifier).search(q)),
          FilterChips(
            filters: filters,
            onChanged: (f) => ref.read(eventFiltersProvider.notifier).update(f),
          ),
          Expanded(
            child: EventsList(
              events: eventsState.events,
              onTap: (event) => context.push('/events/${event.id}'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 3. Create Event Screen

```
┌─────────────────────────────────────┐
│  ← Create Event            [Post]   │
├─────────────────────────────────────┤
│                                     │
│  [📷 Add Cover Photo]               │
│                                     │
│  Title *                            │
│  ┌─────────────────────────────┐   │
│  │ Coffee & Chat               │   │
│  └─────────────────────────────┘   │
│                                     │
│  Activity Type *                    │
│  [☕ Coffee ▼]                      │
│                                     │
│  Description                        │
│  ┌─────────────────────────────┐   │
│  │ Looking for people to...    │   │
│  └─────────────────────────────┘   │
│                                     │
│  📍 Location *                      │
│  [Select on map →]                  │
│                                     │
│  📅 Date & Time *                   │
│  [Tomorrow, 10:00 AM →]             │
│                                     │
│  👥 Participants                    │
│  Min: [2]  Max: [6]                 │
│                                     │
│  ─────────────────────────────────  │
│  🔄 Repeat                          │
│  [○ One-time  ● Weekly  ○ Monthly] │
│  Days: [Mon] [Tue] [Wed]...        │
│  Until: [Select end date]          │
│                                     │
│  ─────────────────────────────────  │
│  Advanced Options                   │
│  ☑ Requires approval               │
│  ☐ Age restriction: 22-35          │
│  ☐ Verified users only             │
│                                     │
└─────────────────────────────────────┘
```

**File**: `lib/features/events/presentation/screens/create_event_screen.dart`

```dart
class CreateEventScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  ActivityType? _activityType;
  LatLng? _location;
  DateTime? _startTime;
  bool _isRecurring = false;
  RecurrenceFrequency? _frequency;
  List<String> _recurringDays = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text('Post'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            CoverPhotoPicker(onPicked: (url) => setState(() => _coverUrl = url)),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title *'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            ActivityTypePicker(
              value: _activityType,
              onChanged: (t) => setState(() => _activityType = t),
            ),
            LocationPicker(
              value: _location,
              onPicked: (loc) => setState(() => _location = loc),
            ),
            DateTimePicker(
              value: _startTime,
              onChanged: (dt) => setState(() => _startTime = dt),
            ),
            ParticipantLimits(
              min: _minParticipants,
              max: _maxParticipants,
              onChanged: (min, max) => setState(() {
                _minParticipants = min;
                _maxParticipants = max;
              }),
            ),
            Divider(),
            SwitchListTile(
              title: Text('Repeat'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            if (_isRecurring) RecurrenceOptions(
              frequency: _frequency,
              days: _recurringDays,
              endDate: _recurrenceEndDate,
              onChanged: _updateRecurrence,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 4. Event Detail Screen

```
┌─────────────────────────────────────┐
│  ←                      [Share] [⋮] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │     [Cover Image]               │ │
│ └─────────────────────────────────┘ │
│                                     │
│  ☕ Coffee & Chat                   │
│  🔄 Weekly • Every Tuesday          │
│                                     │
│  📅 Next: Tue, Jan 16, 10:00 AM    │
│  📍 The Workshop, D1 (1.2 km)      │
│  👥 4/6 going                       │
│                                     │
│  ─────────────────────────────────  │
│  Created by                         │
│  [👤 Minh ✓] • 4.9★ • 23 events    │
│                                     │
│  ─────────────────────────────────  │
│  Description                        │
│  Looking for coffee lovers to...   │
│                                     │
│  ─────────────────────────────────  │
│  Participants (4)          [See all]│
│  [👤][👤][👤][👤] +2 pending       │
│                                     │
│  ─────────────────────────────────  │
│  📅 Upcoming Dates                  │
│  • Tue, Jan 16  [4/6]              │
│  • Tue, Jan 23  [2/6]              │
│  • Tue, Jan 30  [0/6]              │
│                                     │
├─────────────────────────────────────┤
│        [💬 Chat]  [🙋 Join]        │
└─────────────────────────────────────┘
```

---

### 5. Join Request Flow (Modal)

```
┌─────────────────────────────────────┐
│          Request to Join            │
├─────────────────────────────────────┤
│                                     │
│  ☕ Coffee & Chat                   │
│  Tue, Jan 16, 10:00 AM              │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Which dates? (Recurring event)     │
│  ○ Just this one (Jan 16)          │
│  ● All future dates                 │
│  ○ Select specific dates            │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Introduce yourself (optional)      │
│  ┌─────────────────────────────┐   │
│  │ Hi! I'm a coffee enthusiast │   │
│  │ looking to meet new people. │   │
│  └─────────────────────────────┘   │
│                                     │
│  💡 AI Suggestion:                  │
│  "Mình thấy bạn cũng thích..."     │
│  [Use this ↑]                       │
│                                     │
├─────────────────────────────────────┤
│   [Cancel]         [Send Request]   │
└─────────────────────────────────────┘
```

---

### 6. Participant Management (Event Owner)

```
┌─────────────────────────────────────┐
│  ← Participants        Coffee & Chat│
├─────────────────────────────────────┤
│                                     │
│  Pending (2)                        │
│  ┌─────────────────────────────┐   │
│  │ [👤] Linh • 4.7★            │   │
│  │ "Hi! I love coffee..."      │   │
│  │ [Reject] [Waitlist] [Accept]│   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ [👤] Nam • 4.2★             │   │
│  │ "Looking forward to..."     │   │
│  │ [Reject] [Waitlist] [Accept]│   │
│  └─────────────────────────────┘   │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Confirmed (4)                      │
│  [👤 Minh ★ Owner]                 │
│  [👤 Hoa ✓]                        │
│  [👤 Tuan]                          │
│  [👤 Chi]                           │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Waitlist (1)                       │
│  [👤 Duc] [Promote]                 │
│                                     │
└─────────────────────────────────────┘
```

---

### 7. Groups List Screen

```
┌─────────────────────────────────────┐
│  Groups                  [+ Create] │
├─────────────────────────────────────┤
│ [🔍 Search groups...]               │
│                                     │
│ My Groups                           │
│ ┌─────────────────────────────────┐ │
│ │ 🏃 D1 Running Club              │ │
│ │ 245 members • 3 events/week    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Suggested For You                   │
│ ┌─────────────────────────────────┐ │
│ │ 📷 HCMC Street Photography     │ │
│ │ 1.2k members • Public          │ │
│ │ [Join]                         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Nearby Groups                       │
│ ┌─────────────────────────────────┐ │
│ │ ☕ Specialty Coffee D3          │ │
│ │ 89 members • 1.5 km            │ │
│ │ [Join]                         │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

---

## Router Configuration

```dart
// lib/config/routes.dart

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
                          state.matchedLocation.startsWith('/register');
      
      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/splash') {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/discover';
      }
      return null;
    },
    routes: [
      // Splash & Auth
      GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
      
      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/discover',
            builder: (_, __) => DiscoverScreen(),
            routes: [
              GoRoute(
                path: 'filters',
                builder: (_, __) => DiscoverFiltersScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/events',
            builder: (_, __) => EventsListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => CreateEventScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => EventDetailScreen(
                  eventId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'participants',
                    builder: (_, state) => ParticipantsScreen(
                      eventId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => EditEventScreen(
                      eventId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'occurrences',
                    builder: (_, state) => EventOccurrencesScreen(
                      eventId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/groups',
            builder: (_, __) => GroupsListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => CreateGroupScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => GroupDetailScreen(
                  groupId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/chat',
            builder: (_, __) => ChatListScreen(),
            routes: [
              GoRoute(
                path: ':roomId',
                builder: (_, state) => ChatDetailScreen(
                  roomId: state.pathParameters['roomId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, __) => EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Other user profiles
      GoRoute(
        path: '/users/:userId',
        builder: (_, state) => UserProfileScreen(
          userId: state.pathParameters['userId']!,
        ),
      ),
      
      // Connections
      GoRoute(
        path: '/connections',
        builder: (_, __) => ConnectionsScreen(),
      ),
      
      // Settings
      GoRoute(
        path: '/settings',
        builder: (_, __) => SettingsScreen(),
        routes: [
          GoRoute(
            path: 'preferences',
            builder: (_, __) => MatchingPreferencesScreen(),
          ),
          GoRoute(
            path: 'safety',
            builder: (_, __) => SafetySettingsScreen(),
          ),
        ],
      ),
      
      // Safety
      GoRoute(
        path: '/safety/sos',
        builder: (_, __) => SOSScreen(),
      ),
      GoRoute(
        path: '/safety/report',
        builder: (_, state) => ReportScreen(
          userId: state.uri.queryParameters['userId'],
        ),
      ),
    ],
  );
});
```

---

## State Management Structure

```
lib/
├── features/
│   ├── matching/
│   │   └── providers/
│   │       ├── matching_provider.dart      # Discover candidates
│   │       ├── swipe_provider.dart         # Swipe actions
│   │       └── filters_provider.dart       # Discover filters
│   │
│   ├── events/
│   │   └── providers/
│   │       ├── events_provider.dart        # Event list
│   │       ├── event_detail_provider.dart  # Single event
│   │       ├── event_filters_provider.dart # Event filters
│   │       └── my_events_provider.dart     # User's events
│   │
│   ├── groups/
│   │   └── providers/
│   │       ├── groups_provider.dart
│   │       └── group_detail_provider.dart
│   │
│   └── connections/
│       └── providers/
│           └── connections_provider.dart
```

---

## Shared Widgets

```
lib/shared/widgets/
├── cards/
│   ├── user_card.dart           # User swipe card
│   ├── event_card.dart          # Event list item
│   └── group_card.dart          # Group list item
│
├── inputs/
│   ├── location_picker.dart     # Map picker
│   ├── date_time_picker.dart    # DateTime selection
│   ├── activity_picker.dart     # Activity type selector
│   └── recurrence_picker.dart   # Recurring options
│
├── lists/
│   ├── participant_list.dart    # Event participants
│   └── filter_chips.dart        # Filter bar
│
└── feedback/
    ├── swipe_buttons.dart       # Pass/Like/Super
    └── empty_state.dart         # No results
```
