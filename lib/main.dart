import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_language.dart';
import 'config.dart';
import 'onboarding/onboarding_prefs.dart';
import 'screens/auth_gate.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OnboardingPrefs.init();
  if (isSupabaseConfigured) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
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
      scrollBehavior: const AppScrollBehavior(),
      // Above the Navigator, so every screen follows the selected language.
      builder: (context, child) =>
          LanguageScope(notifier: appLanguage, child: child!),
      home: isSupabaseConfigured
          ? const AuthGate()
          : const _SetupNeededScreen(),
    );
  }
}

/// Shown when the app was started without Supabase credentials.
class _SetupNeededScreen extends StatelessWidget {
  const _SetupNeededScreen();

  @override
  Widget build(BuildContext context) {
    // Dark status bar icons on the light background (no app bar here).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.key, size: 48),
                const SizedBox(height: 12),
                Text(
                  context.t('er_notConfiguredTitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.t('er_notConfiguredBody')}\n'
                  'flutter run --dart-define-from-file=env.json',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
