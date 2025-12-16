import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'shared/themes/dating_theme.dart';
import 'shared/providers/theme_provider.dart';

class FynApp extends ConsumerWidget {
  const FynApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: DatingTheme.lightTheme,
      darkTheme: DatingTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

