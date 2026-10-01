import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_language.dart';
import '../config.dart';
import '../onboarding/privacy_policy_screen.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../survey/health_ui.dart';
import '../widgets/friendly_state.dart';
import 'delete_account_dialog.dart';

/// Settings: language, reminders (coming soon), account, privacy & data,
/// about. Opened from the gear on the Profile header.
class SettingsScreen extends StatelessWidget {
  final VoidCallback onEditProfile;

  const SettingsScreen({super.key, required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final email = AuthService.currentUser?.email ?? '';

    Widget section(String title, List<Widget> tiles) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: tiles),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.t('settingsTitle'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                section(context.t('settingsLanguage'), [
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: Text(context.t('settingsLanguage')),
                    trailing: const LanguageDropdown(),
                  ),
                ]),
                section(context.t('settingsReminder'), [
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(context.t('settingsReminder')),
                    subtitle: Text(context.t('settingsReminderSoon')),
                    trailing: const Switch(value: false, onChanged: null),
                  ),
                ]),
                section(context.t('settingsAccount'), [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(context.t('editProfile')),
                    subtitle: email.isEmpty ? null : Text(email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: onEditProfile,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(context.t('signOut')),
                    onTap: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      AuthService.signOut();
                    },
                  ),
                ]),
                section(context.t('settingsPrivacyData'), [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(context.t('privacyTitle')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text(context.t('settingsDownload')),
                    subtitle: Text(context.t('settingsDownloadBody')),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _ExportDialog(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever_outlined,
                      color: kHigh,
                    ),
                    title: Text(
                      context.t('deleteAccount'),
                      style: const TextStyle(color: kHigh),
                    ),
                    onTap: () => showDeleteAccountDialog(context),
                  ),
                ]),
                section(context.t('settingsAbout'), [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('LivrCheck'),
                    subtitle: Text(
                      '${context.t('settingsVersion')} $appVersion',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(context.t('settingsContact')),
                    subtitle: const Text(supportEmail),
                    onTap: () => launchUrl(
                      Uri.parse('mailto:$supportEmail?subject=LivrCheck'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Download my data": fetches everything stored for the user and lets
/// them copy it (works the same on web, Android and iOS).
class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  late final Future<Map<String, dynamic>> _data = DataService.exportMyData();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t('settingsDownload')),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _data,
          builder: (context, snap) {
            if (snap.hasError) return FriendlyState.error(snap.error!);
            if (!snap.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final data = snap.data!;
            final counts = [
              for (final e in data.entries)
                if (e.value is List) '${e.key}: ${(e.value as List).length}',
            ];
            final json = const JsonEncoder.withIndent('  ').convert(data);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.t('settingsDownloadBody')),
                const SizedBox(height: 8),
                Text(counts.join(' · '), style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      json,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.copy),
                  label: Text(context.t('settingsCopy')),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final copied = context.t('settingsCopied');
                    await Clipboard.setData(ClipboardData(text: json));
                    messenger.showSnackBar(SnackBar(content: Text(copied)));
                  },
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t('close')),
        ),
      ],
    );
  }
}
