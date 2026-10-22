import 'package:flutter/material.dart';

import '../app_language.dart';

const kLow = Color(0xFF3E8E6B);
const kMod = Color(0xFFD99A2B);
const kHigh = Color(0xFFC4513A);

/// Darker amber for text or icons on white, and as a background behind
/// white text — [kMod] itself is too light for either (low contrast).
const kModDark = Color(0xFF8A5A00);

Color levelColor(String level) => level == 'low'
    ? kLow
    : level == 'mod'
    ? kMod
    : kHigh;

/// Label for an organ risk level ('low' / 'mod' / 'high'). Pass [context]
/// to get it in the app's language; without it, English.
String levelText(String level, [BuildContext? context]) {
  final key = levelKey(level);
  if (context != null) return context.t(key);
  return level == 'low'
      ? 'Looking good'
      : level == 'mod'
      ? 'Needs attention'
      : 'High risk';
}

/// Translation key for an organ risk level.
String levelKey(String level) => level == 'low'
    ? 'sv_levelLow'
    : level == 'mod'
    ? 'sv_levelMod'
    : 'sv_levelHigh';

/// The overall tier ('Thriving', 'Strong', 'Building', 'Needs care' — the
/// English values saved in survey_responses.tier) in the app's language.
String tierText(BuildContext context, String tier) {
  const keys = {
    'Thriving': 'sv_tierThriving',
    'Strong': 'sv_tierStrong',
    'Building': 'sv_tierBuilding',
    'Needs care': 'sv_tierNeedsCare',
  };
  final key = keys[tier];
  return key == null ? tier : context.t(key);
}

/// Organ name ('liver', 'heart', 'kidneys', 'lungs', 'pancreas') in the
/// app's language. [short] gives a one-word chip label.
String organName(BuildContext context, String organKey, {bool short = false}) {
  final k = organKey.isEmpty
      ? organKey
      : organKey[0].toUpperCase() + organKey.substring(1);
  return context.t(short ? 'sv_organShort$k' : 'sv_organ$k');
}

/// Shows a text reference from a health check result or question: a
/// translation key, optionally with `|name=value` placeholder values (see
/// `textRef()` in assess.dart). Plain text (e.g. English saved by older
/// app versions) is shown unchanged.
String trText(BuildContext context, String ref) {
  if (!ref.startsWith('sv_') || !ref.contains('|')) return context.t(ref);
  final parts = ref.split('|');
  final args = <String, Object?>{};
  for (final p in parts.skip(1)) {
    final i = p.indexOf('=');
    if (i > 0) args[p.substring(0, i)] = p.substring(i + 1);
  }
  return context.tf(parts.first, args);
}

/// Short month name (1–12) in the app's language.
String monthShort(BuildContext context, int month) =>
    context.t('sv_month$month');

/// "5 Oct 2026" style date in the app's language.
String shortDate(BuildContext context, DateTime d) =>
    '${d.day} ${monthShort(context, d.month)} ${d.year}';

/// Translation key for the screening disclaimer.
const kDisclaimer = 'sv_disclaimer';

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  const BigButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
    // At least 56 tall, but grows when a long label (or large text) wraps
    // to two lines instead of clipping it.
    const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 56,
        minWidth: double.infinity,
      ),
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: padding,
                minimumSize: const Size.fromHeight(56),
              ),
              child: text,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: padding,
                minimumSize: const Size.fromHeight(56),
              ),
              child: text,
            ),
    );
  }
}

/// White card with a soft border and shadow, so content stands out from
/// the tinted page background.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Transparent Material so ListTiles / InkWells inside show their
      // ripples (the white decoration would otherwise hide them).
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
