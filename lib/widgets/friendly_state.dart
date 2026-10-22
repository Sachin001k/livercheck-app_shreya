import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/auth_service.dart';
import '../translations.dart';

/// Turns a technical error into words a user understands, in [lang]
/// (defaults to the app's current language).
String friendlyError(Object error, [AppLanguage? lang]) {
  final l = lang ?? appLanguage.value;
  final raw = AuthService.describeError(error, error.toString()).toLowerCase();
  if (raw.contains('failed to fetch') ||
      raw.contains('socket') ||
      raw.contains('network') ||
      raw.contains('connection')) {
    return tr(l, 'er_noInternet');
  }
  if (raw.contains('could not find the table') || raw.contains('column')) {
    return tr(l, 'er_needsUpdate');
  }
  if (raw.contains('jwt') || raw.contains('not signed in')) {
    return tr(l, 'er_sessionEnded');
  }
  return tr(l, 'genericError');
}

/// Emoji + message + optional action, for empty and error states.
class FriendlyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shown under the message in debug builds only, to help diagnose.
  final Object? debugError;

  /// Set by [FriendlyState.error]: title, message and button text are
  /// translated at build time, so they follow the current language.
  final Object? _error;

  const FriendlyState({
    super.key,
    required this.emoji,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.debugError,
  }) : _error = null;

  const FriendlyState._error(Object error, {this.onAction})
    : emoji = '😕',
      title = '',
      message = null,
      actionLabel = null,
      debugError = error,
      _error = error;

  /// Standard error state with a Retry button.
  factory FriendlyState.error(Object error, {VoidCallback? onRetry}) =>
      FriendlyState._error(error, onAction: onRetry);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final error = _error;
    final title = error == null ? this.title : context.t('er_couldNotLoad');
    final message =
        error == null ? this.message : friendlyError(error, context.lang);
    final actionLabel =
        error == null ? this.actionLabel : context.t('er_tryAgain');
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 44)),
        const SizedBox(height: 10),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        if (message != null) ...[
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
        if (debugError != null && kDebugMode) ...[
          const SizedBox(height: 6),
          Text(
            AuthService.describeError(debugError!, debugError.toString()),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: cs.outline),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
        ],
      ]),
    );
  }
}
