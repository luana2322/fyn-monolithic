import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'config/meetup_providers.dart';
import 'features/meetup/presentation/providers/meetup_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase for mobile platforms only
  // Web platform uses Firebase SDK loaded in index.html
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  }
  
  runApp(
    ProviderScope(
      overrides: [
        // Wire up meetup repository with Dio
        meetupRepositoryProvider.overrideWithProvider(actualMeetupRepositoryProvider),
      ],
      child: const FynApp(),
    ),
  );
}
