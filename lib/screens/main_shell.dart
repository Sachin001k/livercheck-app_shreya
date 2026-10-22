import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/data_service.dart';
import '../survey/health_survey_screen.dart';
import '../widgets/tab_back.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../rewards/rewards_screen.dart';

/// The signed-in app: Home, Check (health survey), Rewards and Profile tabs.
class MainShell extends StatefulWidget {
  final Profile profile;
  final VoidCallback onProfileChanged;

  const MainShell({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Back handlers of the tabs that use the back button themselves.
  final _homeBack = TabBack();
  final _checkBack = TabBack();

  /// Android back: first the visible tab (close the daily log, previous
  /// question), then any other tab goes to Home. On Home the app closes.
  void _onBack(bool didPop, Object? _) {
    if (didPop) return;
    final handled = switch (_index) {
      0 => _homeBack.handle(),
      1 => _checkBack.handle(),
      _ => false,
    };
    if (!handled && _index != 0) setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      context.t('appTitle'),
      context.t('pf_healthCheck'),
      context.t('navRewards'),
      context.t('navProfile'),
    ];
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[_index]),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: LanguageDropdown(),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            // Keeps content readable on wide windows (web/desktop).
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              // IndexedStack keeps each tab's state (e.g. a half-filled form).
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(
                    profile: widget.profile,
                    onStartCheck: () => setState(() => _index = 1),
                    isActive: _index == 0,
                    back: _homeBack,
                  ),
                  HealthSurveyScreen(
                    profile: widget.profile,
                    onProfileChanged: widget.onProfileChanged,
                    onOpenProfile: () => setState(() => _index = 3),
                    isActive: _index == 1,
                    back: _checkBack,
                  ),
                  const RewardsScreen(),
                  ProfileScreen(
                    profile: widget.profile,
                    onProfileChanged: widget.onProfileChanged,
                    onOpenCheck: () => setState(() => _index = 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.t('navHome'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.monitor_heart_outlined),
              selectedIcon: const Icon(Icons.monitor_heart),
              label: context.t('navCheck'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.emoji_events_outlined),
              selectedIcon: const Icon(Icons.emoji_events),
              label: context.t('navRewards'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: context.t('navProfile'),
            ),
          ],
        ),
      ),
    );
  }
}
