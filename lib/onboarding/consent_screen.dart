import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../survey/health_ui.dart';
import '../theme.dart';
import 'privacy_policy_screen.dart';

/// Shown once after sign-in (and again if the consent text changes):
/// explains how data is used and records the user's agreement.
class ConsentScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const ConsentScreen({super.key, required this.onAccepted});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  static const _checks = ['consentNotDiagnosis', 'consentStore'];
  final _ticked = <String>{};
  bool _saving = false;
  String? _error;

  bool get _allTicked => _ticked.length == _checks.length;

  Future<void> _agree() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await DataService.saveConsent();
      if (mounted) widget.onAccepted();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            '${context.t('consentSaveError')} ${AuthService.describeError(e, '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const points = [
      ('📋', 'consentCollectTitle', 'consentCollectBody'),
      ('🎯', 'consentWhyTitle', 'consentWhyBody'),
      ('🔒', 'consentWhoTitle', 'consentWhoBody'),
      ('🗑️', 'consentRightsTitle', 'consentRightsBody'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('consentTitle')),
        actions: [
          TextButton(
            onPressed: AuthService.signOut,
            child: Text(context.t('signOut')),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  context.t('consentIntro'),
                  style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final (emoji, title, body) in points)
                  SurfaceCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t(title),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.t(body),
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: Text(context.t('consentReadPolicy')),
                  ),
                ),
                const SizedBox(height: 4),
                SurfaceCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final key in _checks)
                        CheckboxListTile(
                          value: _ticked.contains(key),
                          onChanged: (v) => setState(
                            () => v == true
                                ? _ticked.add(key)
                                : _ticked.remove(key),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: tealDark,
                          title: Text(
                            context.t(key),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: kHigh)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _allTicked && !_saving ? _agree : null,
                    style: FilledButton.styleFrom(backgroundColor: tealDark),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.t('consentAgree'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
