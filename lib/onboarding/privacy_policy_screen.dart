import 'package:flutter/material.dart';

import '../app_language.dart';
import '../config.dart';
import '../survey/health_ui.dart';

/// DRAFT privacy policy, written to India's Digital Personal Data
/// Protection (DPDP) Act 2023 principles. Must be reviewed by a lawyer and
/// the contact details filled in before public release.
/// Date of the last change to the policy text.
final _lastUpdated = DateTime(2026, 10, 1);

/// Section title and body translation keys. The text itself lives in
/// `lib/translations/*.dart` (`pp_…`); the body of "Your rights" has an
/// `{email}` placeholder.
const _sections = [
  ('pp_collectTitle', 'pp_collectBody'),
  ('pp_whyTitle', 'pp_whyBody'),
  ('pp_whereTitle', 'pp_whereBody'),
  ('pp_whoTitle', 'pp_whoBody'),
  ('pp_keepTitle', 'pp_keepBody'),
  ('pp_rightsTitle', 'pp_rightsBody'),
  ('pp_medicalTitle', 'pp_medicalBody'),
  ('pp_changesTitle', 'pp_changesBody'),
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
                  context.tf('pp_lastUpdated', {
                    'date': shortDate(context, _lastUpdated),
                  }),
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
                          context.t(title),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tf(body, {'email': supportEmail}),
                          style: const TextStyle(height: 1.4),
                        ),
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
