import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_language.dart';
import '../onboarding/consent_screen.dart';
import '../onboarding/onboarding_prefs.dart';
import '../onboarding/welcome_screen.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../translations.dart';
import '../widgets/friendly_state.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'profile_setup_screen.dart';

/// Decides what the user sees:
///   first launch on this device → [WelcomeScreen]
///   signed out                  → [LoginScreen]
///   signed in, no consent yet   → [ConsentScreen]
///   signed in, profile missing  → [ProfileSetupScreen]
///   signed in, profile complete → [MainShell]
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _subscription;
  Session? _session = AuthService.currentSession;
  bool _seenWelcome = OnboardingPrefs.seenWelcome;

  @override
  void initState() {
    super.initState();
    _subscription = AuthService.onAuthStateChange.listen(
      (state) {
        if (!mounted) return;
        setState(() => _session = state.session);
        if (state.event == AuthChangeEvent.passwordRecovery) {
          _showSetNewPassword();
        }
      },
      // Mostly a sign-in / reset link that has expired or was already
      // used. Without this handler the error is unhandled and silent.
      onError: (Object e) {
        debugPrint('Auth state error: $e');
        if (!mounted) return;
        final key = AuthService.errorKey(e) ?? 'au_codeExpired';
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(context.t(key))));
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _showSetNewPassword() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t('setNewPasswordTitle')),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(labelText: context.t('passwordLabel')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.t('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final updatedText = context.t('passwordUpdated');
              final errorText = context.t('genericError');
              final lang = context.lang;
              if (controller.text.length < 6) {
                messenger.showSnackBar(
                  SnackBar(content: Text(context.t('passwordLengthError'))),
                );
                return;
              }
              try {
                await AuthService.updatePassword(controller.text);
                messenger.showSnackBar(SnackBar(content: Text(updatedText)));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      AuthService.errorKey(e) == null
                          ? AuthService.describeError(e, errorText)
                          : tr(lang, AuthService.errorKey(e)!),
                    ),
                  ),
                );
              }
            },
            child: Text(context.t('save')),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      if (!_seenWelcome) {
        return WelcomeScreen(
          onDone: () {
            OnboardingPrefs.markWelcomeSeen();
            setState(() => _seenWelcome = true);
          },
        );
      }
      return const LoginScreen();
    }
    // Keyed by user so switching accounts reloads everything.
    return _ProfileGate(key: ValueKey(session.user.id));
  }
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate({super.key});

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  /// Last profile loaded successfully (null: none yet, or no row).
  Profile? _profile;
  bool _loaded = false;
  Object? _error;

  /// Bumped per load; an older load that finishes late is ignored.
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<Profile?> _load() async {
    var profile = await DataService.fetchProfile();
    if (profile != null) {
      final current = appLanguage.value;
      if (profile.consentAt == null &&
          current != AppLanguage.en &&
          profile.preferredLanguage != current) {
        // Brand-new account: keep the language picked before signing up
        // (the new profile row defaults to English) and save it.
        await DataService.saveLanguage(current);
        profile = Profile(
          id: profile.id,
          fullName: profile.fullName,
          age: profile.age,
          gender: profile.gender,
          heightCm: profile.heightCm,
          weightKg: profile.weightKg,
          preferredLanguage: current,
          createdAt: profile.createdAt,
          consentAt: profile.consentAt,
          consentVersion: profile.consentVersion,
        );
      } else {
        appLanguage.value = profile.preferredLanguage;
      }
    }
    // Counts today towards the streak. Failure here shouldn't block login.
    DataService.logActivityToday().catchError(
      (Object e) => debugPrint('Could not log activity: $e'),
    );
    return profile;
  }

  Future<void> _fetch() async {
    final request = ++_request;
    try {
      final profile = await _load();
      if (!mounted || request != _request) return;
      setState(() {
        _profile = profile;
        _loaded = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted || request != _request) return;
      if (_profile != null) {
        // Keep the app (and its tab state) on screen; just say so.
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(friendlyError(e, context.lang))),
        );
        return;
      }
      setState(() => _error = e);
    }
  }

  // Block body: an arrow `() => setState(...)` returning a Future is
  // rejected by Flutter ("setState() callback returned a Future").
  void _reload() {
    _fetch();
  }

  void _retry() {
    setState(() {
      _error = null;
      _loaded = false;
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    // Only a first load with nothing to show yet ends on the error screen.
    if (error != null && _profile == null) {
      return _LoadError(error: error, onRetry: _retry);
    }
    if (!_loaded) return const _Splash();
    final profile = _profile;
    if (profile == null || !profile.hasConsented) {
      return ConsentScreen(onAccepted: _reload);
    }
    if (!profile.isComplete) {
      return ProfileSetupScreen(initial: profile, onSaved: _reload);
    }
    return MainShell(profile: profile, onProfileChanged: _reload);
  }
}

/// Branded loading screen while the profile loads after sign-in.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status bar icons on the teal background.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: tealGradient),
          alignment: Alignment.center,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🩺', style: TextStyle(fontSize: 64)),
                SizedBox(height: 12),
                Text(
                  'LivrCheck',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _LoadError({required this.error, required this.onRetry});

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
                const Icon(Icons.cloud_off, size: 48, color: Colors.black38),
                const SizedBox(height: 12),
                Text(
                  context.t('loadProfileError'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // Most often: the migration in supabase/migrations/ hasn't been run yet.
                Text(
                  AuthService.describeError(error, error.toString()),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(context.t('retry')),
                ),
                TextButton(
                  onPressed: AuthService.signOut,
                  child: Text(context.t('signOut')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
