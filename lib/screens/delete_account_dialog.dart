import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/auth_service.dart';
import '../survey/health_ui.dart';

/// Asks the user to type DELETE, then permanently deletes their account.
/// On success the auth listener sends them back to the login screen.
Future<void> showDeleteAccountDialog(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final doneText = context.t('deleteAccountDone');
  final deleted = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  if (deleted == true) {
    // Close Settings etc. so the login screen is visible.
    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(SnackBar(content: Text(doneText)));
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _deleting = false;
  String? _error;

  bool get _confirmed => _controller.text.trim().toUpperCase() == 'DELETE';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await AuthService.deleteAccount();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error =
            '${context.t('deleteAccountFailed')} ${AuthService.describeError(e, '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: kHigh, size: 36),
      title: Text(context.t('deleteAccountTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.t('deleteAccountBody')),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_deleting,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.t('deleteAccountTypeToConfirm'),
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: kHigh)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(false),
          child: Text(context.t('cancel')),
        ),
        FilledButton(
          onPressed: _confirmed && !_deleting ? _delete : null,
          style: FilledButton.styleFrom(backgroundColor: kHigh),
          child: _deleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(context.t('deleteAccountConfirm')),
        ),
      ],
    );
  }
}
