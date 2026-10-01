import 'package:flutter/material.dart';

const kLow = Color(0xFF3E8E6B);
const kMod = Color(0xFFD99A2B);
const kHigh = Color(0xFFC4513A);

Color levelColor(String level) =>
    level == 'low' ? kLow : level == 'mod' ? kMod : kHigh;

String levelText(String level) => level == 'low'
    ? 'Looking good'
    : level == 'mod'
        ? 'Needs attention'
        : 'High risk';

const kDisclaimer =
    'This is a screening tool, not a diagnosis. Always talk to a doctor about your results.';

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  const BigButton({super.key, required this.label, this.onPressed, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final text = Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, child: text)
          : FilledButton(onPressed: onPressed, child: text),
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
