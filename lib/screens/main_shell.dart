import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/data_service.dart';
import '../survey/health_survey_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// The signed-in app: Home, Check (health survey) and Profile tabs.
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

  @override
  Widget build(BuildContext context) {
    final titles = [context.t('appTitle'), 'Health check', context.t('navProfile')];
    return Scaffold(
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
                ),
                HealthSurveyScreen(
                  profile: widget.profile,
                  onProfileChanged: widget.onProfileChanged,
                  onOpenProfile: () => setState(() => _index = 2),
                ),
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
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.t('navProfile'),
          ),
        ],
      ),
    );
  }
}
