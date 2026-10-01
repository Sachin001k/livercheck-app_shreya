import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_language.dart';
import 'config.dart';
import 'screens/auth_gate.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isSupabaseConfigured) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  }
  runApp(const LivrCheckApp());
}

class LivrCheckApp extends StatelessWidget {
  const LivrCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LivrCheck',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Above the Navigator, so every screen follows the selected language.
      builder: (context, child) =>
          LanguageScope(notifier: appLanguage, child: child!),
      home: isSupabaseConfigured ? const AuthGate() : const _SetupNeededScreen(),
    );
  }
}

/// Shown when the app was started without Supabase credentials.
class _SetupNeededScreen extends StatelessWidget {
  const _SetupNeededScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.key, size: 48),
              SizedBox(height: 12),
              Text(
                'Supabase is not configured',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Fill in env.json with your project URL and anon key, then run:\n'
                'flutter run --dart-define-from-file=env.json',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
