import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Turns a technical error into words a user understands.
String friendlyError(Object error) {
  final raw = AuthService.describeError(error, error.toString()).toLowerCase();
  if (raw.contains('failed to fetch') ||
      raw.contains('socket') ||
      raw.contains('network') ||
      raw.contains('connection')) {
    return 'No internet connection. Check your connection and try again.';
  }
  if (raw.contains('could not find the table') || raw.contains('column')) {
    return 'The app needs a database update. Please contact support.';
  }
  if (raw.contains('jwt') || raw.contains('not signed in')) {
    return 'Your session has ended. Please sign in again.';
  }
  return 'Something went wrong. Please try again.';
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

  const FriendlyState({
    super.key,
    required this.emoji,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.debugError,
  });

  /// Standard error state with a Retry button.
  factory FriendlyState.error(Object error, {VoidCallback? onRetry}) => FriendlyState(
        emoji: '😕',
        title: 'Could not load this',
        message: friendlyError(error),
        actionLabel: onRetry == null ? null : 'Try again',
        onAction: onRetry,
        debugError: error,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          Text(message!, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
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
          FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ]),
    );
  }
}
