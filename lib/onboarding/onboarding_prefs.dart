import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-only flags for the first-run experience. Kept on the device (not
/// Supabase) because the welcome slides show before anyone signs in.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const _kSeenWelcome = 'seen_welcome_v1';
  static SharedPreferences? _prefs;

  /// Call once at start-up. Failures (e.g. storage blocked in a private
  /// browser window) just mean the slides show again.
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Onboarding prefs unavailable: $e');
    }
  }

  static bool get seenWelcome => _prefs?.getBool(_kSeenWelcome) ?? false;

  static Future<void> markWelcomeSeen() async {
    try {
      await _prefs?.setBool(_kSeenWelcome, true);
    } catch (e) {
      debugPrint('Could not save onboarding flag: $e');
    }
  }
}
