import 'package:flutter/material.dart';
import 'assess.dart';
import 'body_map.dart';
import 'health_ui.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class ResultsScreen extends StatefulWidget {
  final AssessmentResult result;

  /// When the check was taken. Set when opened from the profile history.
  final DateTime? takenAt;

  /// Switches to the Profile tab. Null when opened from the history, which
  /// then shows a single Close button instead.
  final VoidCallback? onTrackHabits;

  /// Why saving to the profile failed, or null if it worked. Only used
  /// right after a check (not when reopening from the history).
  final String? saveError;

  /// Tries saving again; returns the new error, or null on success.
  final Future<String?> Function()? onRetrySave;

  const ResultsScreen({
    super.key,
    required this.result,
    this.takenAt,
    this.onTrackHabits,
    this.saveError,
    this.onRetrySave,
  });
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late String _sel;
  String _tab = 'eatMore';
  late String? _saveError = widget.saveError;
  bool _retrying = false;

  Future<void> _retrySave() async {
    setState(() => _retrying = true);
    final error = await widget.onRetrySave!();
    if (mounted) {
      setState(() {
        _saveError = error;
        _retrying = false;
      });
    }
  }

  static const _tabs = {
    'eatMore': 'Eat more',
    'eatLess': 'Eat less',
    'move': 'Exercise',
    'habits': 'Habits',
  };

  @override
  void initState() {
    super.initState();
    const order = {'high': 0, 'mod': 1, 'low': 2};
    final keys = widget.result.organs.keys.toList()
      ..sort(
        (x, y) => order[widget.result.organs[x]!.level]!.compareTo(
          order[widget.result.organs[y]!.level]!,
        ),
      );
    _sel = keys.first; // open the organ that needs the most attention
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final o = r.organs[_sel]!;
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final ringColor = r.score >= 80
        ? kLow
        : r.score >= 60
        ? cs.primary
        : r.score >= 40
        ? kMod
        : kHigh;
    final taken = widget.takenAt;
    Widget section(String s) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        s,
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          taken == null
              ? 'Your results'
              : 'Check on ${taken.day} ${_months[taken.month - 1]} ${taken.year}',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                if (widget.onRetrySave != null) ...[
                  _SaveBanner(
                    error: _saveError,
                    retrying: _retrying,
                    onRetry: _retrySave,
                  ),
                  const SizedBox(height: 12),
                ],
                SurfaceCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 118,
                        height: 118,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: r.score / 100,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              color: ringColor,
                              backgroundColor: cs.outlineVariant,
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${r.score}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    'of 100',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.tier,
                              style: t.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Your health score. BMI ${r.bmi.toStringAsFixed(1)}${r.waistEstimated ? ', waist estimated' : ''}.',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (r.seeDoctor)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kHigh.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        left: BorderSide(color: kHigh, width: 5),
                      ),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Please see a doctor in the next few weeks.\n',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                'One or more organs show high risk. Take the tests listed below with you.',
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final n in r.notes)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(n),
                  ),
                section('Tap an organ'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in r.organs.entries)
                      ChoiceChip(
                        avatar: CircleAvatar(
                          radius: 6,
                          backgroundColor: levelColor(e.value.level),
                        ),
                        label: Text(e.value.name.split(' ').first),
                        selected: e.key == _sel,
                        onSelected: (_) => setState(() => _sel = e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SurfaceCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 115,
                        child: BodyMap(
                          organs: r.organs,
                          selected: _sel,
                          onTap: (k) => setState(() => _sel = k),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: levelColor(o.level),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                levelText(o.level),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              o.does,
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final reason in o.reasons)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('•  '),
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '${o.confidence}${o.extra != null ? '. ${o.extra}.' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (r.tests.isNotEmpty) ...[
                  section('Tests to ask your doctor for'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tst in r.tests) Chip(label: Text(tst)),
                    ],
                  ),
                ],
                section('Your plan'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in _tabs.entries)
                      ChoiceChip(
                        label: Text(e.value),
                        selected: _tab == e.key,
                        onSelected: (_) => setState(() => _tab = e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final p in r.plan.byKey(_tab))
                  SurfaceCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                p.sub,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (widget.onTrackHabits != null) ...[
                  BigButton(
                    label: 'Track my habits',
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onTrackHabits!();
                    },
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    label: 'Take the check again',
                    outlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ] else
                  BigButton(
                    label: 'Close',
                    outlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                const SizedBox(height: 20),
                Text(
                  kDisclaimer,
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows whether this check was saved to the profile, with a retry.
class _SaveBanner extends StatelessWidget {
  final String? error;
  final bool retrying;
  final VoidCallback onRetry;

  const _SaveBanner({
    required this.error,
    required this.retrying,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final ok = error == null;
    final color = ok ? kLow : kHigh;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.cloud_done : Icons.cloud_off, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ok ? 'Saved to your profile' : 'Not saved: $error',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (!ok)
            retrying
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
