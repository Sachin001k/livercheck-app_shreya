import 'package:flutter/material.dart';

import '../app_language.dart';
import '../survey/health_ui.dart';

/// DRAFT privacy policy, written to India's Digital Personal Data
/// Protection (DPDP) Act 2023 principles. Must be reviewed by a lawyer and
/// the contact details filled in before public release.
const _contactEmail = 'privacy@livrcheck.example'; // TODO: real address
const _lastUpdated = '1 October 2026';

const _sections = [
  (
    'What we collect',
    'Account details (email, name). Profile details you enter (age, gender, '
        'height, weight, language). Your health check answers and results, '
        'blood test values if you enter them, and your daily logs (water, '
        'food, exercise, steps, sleep). Coins and streaks you earn.',
  ),
  (
    'Why we use it',
    'To calculate and show your results, track your progress over time, '
        'personalise your daily goals and run the coin rewards. We do not use '
        'it for advertising and we never sell it.',
  ),
  (
    'Where it is stored',
    'On secure servers run by our database provider (Supabase). Every '
        'record is protected so that only your account can read it.',
  ),
  (
    'Who can see it',
    'Only you. Our team does not look at individual records except to fix '
        'a problem you report, or where the law requires it.',
  ),
  (
    'How long we keep it',
    'For as long as you have an account. When you delete your account, your '
        'data is deleted within 30 days.',
  ),
  (
    'Your rights',
    'You can see and edit your profile in the app at any time. You can ask '
        'us for a copy of your data, to correct it, or to delete your account '
        'and all your data, by emailing $_contactEmail.',
  ),
  (
    'Not medical advice',
    'LivrCheck is a screening and wellness tool. It does not diagnose any '
        'condition. Always talk to a doctor about your health.',
  ),
  (
    'Changes',
    'If this policy changes we will ask you to agree again in the app.',
  ),
];

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('privacyTitle'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  'Last updated $_lastUpdated · Draft',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 12),
                for (final (title, body) in _sections)
                  SurfaceCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(body, style: const TextStyle(height: 1.4)),
                      ],
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
