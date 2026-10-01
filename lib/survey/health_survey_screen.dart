import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'assess.dart';
import 'body_map.dart';
import 'health_ui.dart';
import 'progress_store.dart';
import 'questions.dart';
import 'results_screen.dart';

/// One-question-per-screen health check. Lives in the "Check" tab.
class HealthSurveyScreen extends StatefulWidget {
  final Profile profile;

  /// Called after a check is saved, so the app reloads the updated profile.
  final VoidCallback onProfileChanged;

  /// Switches the app to the Profile tab.
  final VoidCallback onOpenProfile;

  const HealthSurveyScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onOpenProfile,
  });
  @override
  State<HealthSurveyScreen> createState() => _HealthSurveyScreenState();
}

class _HealthSurveyScreenState extends State<HealthSurveyScreen> {
  bool _started = false;
  int _step = 0;
  bool _advancing = false;
  bool _saving = false;
  final Answers _a = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill what the profile already knows; the user only confirms.
    final p = widget.profile;
    if (p.gender == 'male') _a['sex'] = 'm';
    if (p.gender == 'female') _a['sex'] = 'f';
    if (p.age != null) _a['age'] = p.age!.clamp(18, 90).toDouble();
    final h = p.heightCm, w = p.weightKg;
    if (h != null) _a['height'] = h.clamp(130, 210).roundToDouble();
    if (w != null) _a['weight'] = w.clamp(30, 180).roundToDouble();
  }

  List<Question> get _visible =>
      healthQuestions.where((q) => q.showIf == null || q.showIf!(_a)).toList();

  void _start() => setState(() {
    // Keep earlier lifestyle answers for a quick re-check, but always
    // ask about the blood report again.
    _a.remove('hasReport');
    _a.remove('labs');
    _started = true;
    _step = 0;
  });

  void _back() => setState(() {
    if (_step == 0) {
      _started = false;
    } else {
      _step--;
    }
  });

  void _next() {
    if (_step >= _visible.length - 1) {
      _finish();
    } else {
      setState(() => _step++);
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    final input = Map<String, dynamic>.from(_a);
    if (input['hasReport'] != 'yes') input.remove('labs');
    final result = assess(input);

    setState(() => _saving = true);
    Future<String?> save() async {
      try {
        await ProgressStore.saveResult(result, input);
        widget.onProfileChanged();
        return null;
      } catch (e) {
        return AuthService.describeError(e, 'Unknown error');
      }
    }

    final error = await save();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _started = false;
      _step = 0;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          result: result,
          onTrackHabits: widget.onOpenProfile,
          saveError: error,
          onRetrySave: save,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_saving) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Saving your results…'),
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _started ? _question(context) : _intro(context),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    const points = [
      'About 2 minutes, one question at a time',
      'See which organs need care: liver, heart, kidneys, lungs and blood sugar',
      'Get a food and exercise plan made for you',
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How is your body doing?',
                          style: t.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Answer by tapping. No blood report needed.',
                          style: t.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(width: 110, child: BodyMap()),
                ],
              ),
              const SizedBox(height: 20),
              for (final s in points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: 10),
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: cs.primary,
                        ),
                      ),
                      Expanded(child: Text(s, style: t.bodyLarge)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              BigButton(label: 'Start my check', onPressed: _start),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          kDisclaimer,
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _question(BuildContext context) {
    final v = _visible;
    if (_step >= v.length) _step = v.length - 1;
    final q = v[_step];
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget body;
    switch (q.type) {
      case QType.choice:
        body = _choice(q);
        break;
      case QType.multi:
        body = _multi(q);
        break;
      case QType.slider:
        body = _slider(q, cs);
        break;
      case QType.labs:
        _a['labs'] ??= <String, dynamic>{
          'ast': null,
          'alt': null,
          'plt': null,
          'unit': 'lakh',
          'skip': <String, bool>{},
        };
        body = _LabsStep(
          labs: _a['labs'] as Map<String, dynamic>,
          onDone: _finish,
        );
        break;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: _back,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Back',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _step / v.length,
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('${_step + 1} of ${v.length}', style: t.bodySmall),
          ],
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                q.title,
                style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (q.why != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    q.why!,
                    style: TextStyle(color: cs.onSecondaryContainer),
                  ),
                ),
              const SizedBox(height: 18),
              body,
            ],
          ),
        ),
      ],
    );
  }

  Widget _choice(Question q) {
    final opts = q.options!(_a);
    return Column(
      children: [
        for (final o in opts)
          _OptionCard(
            opt: o,
            selected: _a[q.id] == o.v,
            onTap: () async {
              if (_advancing) return;
              HapticFeedback.selectionClick();
              setState(() => _a[q.id] = o.v);
              _advancing = true;
              await Future.delayed(
                const Duration(milliseconds: 220),
              ); // let the tick show
              _advancing = false;
              if (mounted) _next();
            },
          ),
      ],
    );
  }

  Widget _multi(Question q) {
    final opts = q.options!(_a);
    // Drop earlier picks that are no longer offered (e.g. PCOS after
    // changing sex to male).
    final cur = List<String>.from(_a[q.id] ?? const <String>[])
      ..removeWhere((x) => !opts.any((o) => o.v == x));
    return Column(
      children: [
        for (final o in opts)
          _OptionCard(
            opt: o,
            selected: cur.contains(o.v),
            onTap: () => setState(() {
              var next = List<String>.from(cur);
              if (next.contains(o.v)) {
                next.remove(o.v);
              } else if (o.exclusive) {
                next = [o.v];
              } else {
                next.removeWhere(
                  (x) => opts.any((p) => p.v == x && p.exclusive),
                );
                next.add(o.v);
              }
              _a[q.id] = next;
            }),
          ),
        const SizedBox(height: 12),
        BigButton(
          label: 'Continue',
          onPressed: cur.isEmpty
              ? null
              : () {
                  _a[q.id] = cur;
                  _next();
                },
        ),
      ],
    );
  }

  Widget _slider(Question q, ColorScheme cs) {
    if (!_a.containsKey(q.id)) _a[q.id] = q.def;
    final raw = _a[q.id] as num?;
    final unknown = raw == null;
    final v = (raw ?? q.def).toDouble();
    String fmt(double x) =>
        q.step < 1 ? x.toStringAsFixed(1) : x.round().toString();
    void update(double x) =>
        setState(() => _a[q.id] = x.clamp(q.min, q.max).toDouble());

    return Column(
      children: [
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: unknown ? '?' : fmt(v),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (!unknown)
                TextSpan(
                  text: ' ${q.unit}',
                  style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          unknown
              ? 'We will estimate it from your height and weight'
              : (q.alt?.call(v) ?? ''),
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton.outlined(
              onPressed: () => update(v - q.step),
              icon: const Icon(Icons.remove),
              tooltip: 'Less',
            ),
            Expanded(
              child: Slider(
                value: v,
                min: q.min,
                max: q.max,
                divisions: ((q.max - q.min) / q.step).round(),
                label: fmt(v),
                onChanged: update,
              ),
            ),
            IconButton.outlined(
              onPressed: () => update(v + q.step),
              icon: const Icon(Icons.add),
              tooltip: 'More',
            ),
          ],
        ),
        const SizedBox(height: 20),
        BigButton(
          label: 'Continue',
          onPressed: () {
            if (_a[q.id] == null) _a[q.id] = q.def;
            _next();
          },
        ),
        if (q.unknownLabel != null) ...[
          const SizedBox(height: 10),
          BigButton(
            label: q.unknownLabel!,
            outlined: true,
            onPressed: () {
              _a[q.id] = null;
              _next();
            },
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final Opt opt;
  final bool selected;
  final VoidCallback onTap;
  const _OptionCard({
    required this.opt,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(18);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? cs.primary : cs.outlineVariant,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    opt.emoji,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (opt.sub != null)
                        Text(
                          opt.sub!,
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabsStep extends StatefulWidget {
  final Map<String, dynamic> labs;
  final VoidCallback onDone;
  const _LabsStep({required this.labs, required this.onDone});
  @override
  State<_LabsStep> createState() => _LabsStepState();
}

class _LabsStepState extends State<_LabsStep> {
  static const _keys = ['ast', 'alt', 'plt'];
  static const _warnText =
      'This looks unusual. Please check the number on your report.';
  late final Map<String, TextEditingController> _c = {
    for (final k in _keys)
      k: TextEditingController(text: widget.labs[k]?.toString() ?? ''),
  };
  final Map<String, String?> _warn = {};

  Map<String, dynamic> get L => widget.labs;
  Map get _skip => L['skip'] as Map;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed(String k, String text) {
    final v = double.tryParse(text.trim());
    setState(() {
      L[k] = v;
      String? w;
      if (v != null) {
        if (k == 'plt') {
          // Guess the unit from the size of the number: 2.5 → lakh, 250000 → per µL
          L['unit'] = v < 20
              ? 'lakh'
              : v > 20000
              ? 'ul'
              : 'g';
          final g = plateletsToG(v, L['unit'] as String);
          if (g < 20 || g > 1000) w = _warnText;
        } else if (v < 5 || v > 1000) {
          w = _warnText;
        }
      }
      _warn[k] = w;
    });
  }

  Widget _field(String k, String label, String hint, String example) {
    final cs = Theme.of(context).colorScheme;
    final skip = _skip[k] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          Text(
            hint,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _c[k],
                  enabled: !skip,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: example,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (s) => _changed(k, s),
                ),
              ),
              if (k == 'plt') ...[
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: L['unit'] as String,
                  onChanged: skip ? null : (u) => setState(() => L['unit'] = u),
                  items: const [
                    DropdownMenuItem(value: 'lakh', child: Text('lakh/cmm')),
                    DropdownMenuItem(value: 'ul', child: Text('/µL')),
                    DropdownMenuItem(value: 'g', child: Text('×10⁹/L')),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          FilterChip(
            label: const Text("I don't have this"),
            selected: skip,
            onSelected: (s) => setState(() {
              _skip[k] = s;
              if (s) {
                L[k] = null;
                _c[k]!.clear();
                _warn[k] = null;
              }
            }),
          ),
          if (_warn[k] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_warn[k]!, style: const TextStyle(color: kHigh)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field(
          'ast',
          'AST (also called SGOT)',
          'In the Liver Function Test section',
          'e.g. 32',
        ),
        _field(
          'alt',
          'ALT (also called SGPT)',
          'Right next to AST on most reports',
          'e.g. 40',
        ),
        _field(
          'plt',
          'Platelet count',
          'In the CBC section. Type it exactly as printed, we pick the unit.',
          'e.g. 2.5',
        ),
        const SizedBox(height: 8),
        BigButton(label: 'See my results', onPressed: widget.onDone),
      ],
    );
  }
}
