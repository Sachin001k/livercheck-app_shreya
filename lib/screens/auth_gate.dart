import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_language.dart';
import '../onboarding/consent_screen.dart';
import '../onboarding/onboarding_prefs.dart';
import '../onboarding/welcome_screen.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme.dart';
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
    _subscription = AuthService.onAuthStateChange.listen((state) {
      if (!mounted) return;
      setState(() => _session = state.session);
      if (state.event == AuthChangeEvent.passwordRecovery) {
        _showSetNewPassword();
      }
    });
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
                    content: Text(AuthService.describeError(e, errorText)),
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
  late Future<Profile?> _profile = _load();

  Future<Profile?> _load() async {
    final profile = await DataService.fetchProfile();
    if (profile != null) appLanguage.value = profile.preferredLanguage;
    // Counts today towards the streak. Failure here shouldn't block login.
    DataService.logActivityToday().catchError(
      (Object e) => debugPrint('Could not log activity: $e'),
    );
    return profile;
  }

  // Block body: an arrow `() => _profile = _load()` would return the Future
  // to setState, which Flutter rejects ("setState() callback returned a
  // Future") — that made saves look like they had failed.
  void _reload() {
    final next = _load();
    setState(() {
      _profile = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile?>(
      future: _profile,
      builder: (context, snapshot) {
        // On reload, keep showing the previous profile instead of a spinner.
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return const _Splash();
        }
        if (snapshot.hasError) {
          return _LoadError(error: snapshot.error!, onRetry: _reload);
        }
        final profile = snapshot.data;
        if (profile == null || !profile.hasConsented) {
          return ConsentScreen(onAccepted: _reload);
        }
        if (!profile.isComplete) {
          return ProfileSetupScreen(initial: profile, onSaved: _reload);
        }
        return MainShell(profile: profile, onProfileChanged: _reload);
      },
    );
  }
}

/// Branded loading screen while the profile loads after sign-in.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class _LoadError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _LoadError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              FilledButton(onPressed: onRetry, child: Text(context.t('retry'))),
              TextButton(
                onPressed: AuthService.signOut,
                child: Text(context.t('signOut')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
