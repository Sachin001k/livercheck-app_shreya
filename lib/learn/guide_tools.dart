import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_language.dart';
import '../survey/health_ui.dart';
import '../theme.dart';
import 'guide_blocks.dart';
import 'guide_content.dart';
import 'guide_store.dart';

// ------------------------------------------------------------ risk checklist

/// "Could you be at risk?" — tick boxes for the chosen age group. Not saved:
/// it is a reflection tool, not a test.
class RiskChecklist extends StatefulWidget {
  final ChecklistBlock b;
  const RiskChecklist(this.b, {super.key});

  @override
  State<RiskChecklist> createState() => _RiskChecklistState();
}

class _RiskChecklistState extends State<RiskChecklist> {
  final Map<AgeGroup, Set<int>> _ticked = {};

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: guideAgeGroup,
      builder: (context, g, _) {
        final qs = widget.b.questions[g] ?? const [];
        final ticked = _ticked.putIfAbsent(g, () => <int>{});
        final note = widget.b.notes[g];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AgeGroupChips(),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final (n, q) in qs.indexed)
                    CheckboxListTile(
                      value: ticked.contains(n),
                      activeColor: g.color,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        context.t(q),
                        style: const TextStyle(fontSize: 14.5),
                      ),
                      onChanged: (_) {
                        HapticFeedback.selectionClick();
                        setState(
                          () => ticked.contains(n)
                              ? ticked.remove(n)
                              : ticked.add(n),
                        );
                      },
                    ),
                ],
              ),
            ),
            if (note != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '👪 ${context.t(note)}',
                  style: TextStyle(color: g.color, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: InfoBox(
                key: ValueKey('${g.name}${ticked.length}'),
                ticked.isEmpty
                    ? const InfoBlock('🙂', 'gd_ckNone', tone: GuideTone.good)
                    : InfoBlock('🩺', 'gd_ckResult', tone: GuideTone.warn),
                args: {'n': ticked.length, 'total': qs.length},
              ),
            ),
          ],
        );
      },
    );
  }
}

// --------------------------------------------------------- 7-day challenge

/// "My 7-day liver health challenge": 8 habits × 7 days, this week.
class ChallengeTool extends StatefulWidget {
  final String userId;
  const ChallengeTool({super.key, required this.userId});

  @override
  State<ChallengeTool> createState() => _ChallengeToolState();
}

class _ChallengeToolState extends State<ChallengeTool> {
  late final DateTime _monday = GuideStore.weekStart(DateTime.now());
  late int _day = DateTime.now().weekday - 1;
  ChallengeWeek? _week;
  final _success = TextEditingController();
  final _improve = TextEditingController();

  @override
  void initState() {
    super.initState();
    GuideStore.loadWeek(widget.userId, _monday).then((w) {
      if (!mounted) return;
      _success.text = w.success;
      _improve.text = w.improve;
      setState(() => _week = w);
    });
  }

  @override
  void dispose() {
    _success.dispose();
    _improve.dispose();
    super.dispose();
  }

  void _save() {
    final w = _week;
    if (w == null) return;
    w.success = _success.text;
    w.improve = _improve.text;
    GuideStore.saveWeek(widget.userId, _monday, w);
  }

  @override
  Widget build(BuildContext context) {
    final w = _week;
    if (w == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final habits = challengeHabits;
    final total = habits.length * 7;
    final today = DateTime.now().weekday - 1;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                children: [
                  Text(
                    context.t('gd_chWeek'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    context.tf('gd_chDone', {'n': w.total, 'total': total}),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tealDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(end: w.total / total),
                duration: const Duration(milliseconds: 400),
                builder: (_, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    color: tealLight,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Day picker: one column per weekday with its count.
              Row(
                children: [
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _DayChip(
                          label: context.t('pf_wd${d + 1}'),
                          done: w.doneOn(d),
                          total: habits.length,
                          selected: d == _day,
                          isToday: d == today,
                          onTap: () => setState(() => _day = d),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.t('gd_chTapHint'),
                style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (final (n, h) in habits.indexed)
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => w.toggle(n, _day));
                    _save();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                    child: Row(
                      children: [
                        EmojiBadge(h.emoji, color: tealDark, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t(h.titleKey),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                              Text(
                                context.t(h.bodyKey!),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // This habit across the week.
                              Row(
                                children: [
                                  for (var d = 0; d < 7; d++)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: w.isTicked(n, d)
                                            ? kLow
                                            : cs.outlineVariant.withValues(
                                                alpha: 0.5,
                                              ),
                                        border: d == _day
                                            ? Border.all(
                                                color: tealDark,
                                                width: 1.5,
                                              )
                                            : null,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: w.isTicked(n, _day),
                          activeColor: kLow,
                          onChanged: (_) {
                            HapticFeedback.selectionClick();
                            setState(() => w.toggle(n, _day));
                            _save();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _NoteField(
          emoji: '🏆',
          titleKey: 'gd_chSuccessT',
          hintKey: 'gd_chSuccessH',
          controller: _success,
          onChanged: _save,
          color: kLow,
        ),
        const SizedBox(height: 12),
        _NoteField(
          emoji: '📈',
          titleKey: 'gd_chImproveT',
          hintKey: 'gd_chImproveH',
          controller: _improve,
          onChanged: _save,
          color: const Color(0xFFE07A2E),
        ),
        const _SavedOnPhone(),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.done,
    required this.total,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final full = done == total;
    return Material(
      color: selected
          ? tealDark
          : (full ? kLow.withValues(alpha: 0.15) : mintCard),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: selected ? Colors.white : tealDark,
                    decoration: isToday ? TextDecoration.underline : null,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(
                  full
                      ? '⭐'
                      : context.tf('gd_chDayDone', {'n': done, 'total': total}),
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white70 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------- personal plan

/// "My personal action plan": six short answers + next check date.
class PlanTool extends StatefulWidget {
  final String userId;
  const PlanTool({super.key, required this.userId});

  @override
  State<PlanTool> createState() => _PlanToolState();
}

class _PlanToolState extends State<PlanTool> {
  final Map<String, TextEditingController> _c = {
    for (final f in planFields) f.$2: TextEditingController(),
    'ask': TextEditingController(),
  };
  Map<String, String> _plan = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    GuideStore.loadPlan(widget.userId).then((p) {
      if (!mounted) return;
      for (final e in _c.entries) {
        e.value.text = p[e.key] ?? '';
      }
      setState(() {
        _plan = p;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    _plan = {..._plan, for (final e in _c.entries) e.key: e.value.text};
    GuideStore.savePlan(widget.userId, _plan);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_plan['date'] ?? '');
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    setState(() => _plan = {..._plan, 'date': picked.toIso8601String()});
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    const colors = [
      Color(0xFF1F7A6E),
      Color(0xFF2F6FD6),
      Color(0xFFB7791F),
      Color(0xFFD6455D),
      Color(0xFF7B57C2),
      Color(0xFF3E8E4F),
    ];
    final date = DateTime.tryParse(_plan['date'] ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (n, (emoji, titleKey, hintKey)) in planFields.indexed) ...[
          _NoteField(
            emoji: emoji,
            titleKey: titleKey,
            hintKey: hintKey,
            controller: _c[titleKey]!,
            onChanged: _save,
            color: colors[n],
            // Field 5 also has a date and "I will ask about".
            extra: titleKey != 'gd_pl5T'
                ? null
                : Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event),
                      label: Text(
                        date == null
                            ? context.t('gd_plPickDate')
                            : shortDate(context, date),
                      ),
                    ),
                  ),
            fieldLabelKey: titleKey == 'gd_pl5T' ? 'gd_pl5Ask' : null,
          ),
          const SizedBox(height: 12),
        ],
        const _SavedOnPhone(),
      ],
    );
  }
}

// ---------------------------------------------------------------- shared

class _NoteField extends StatelessWidget {
  final String emoji;
  final String titleKey;
  final String hintKey;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final Color color;
  final Widget? extra;
  final String? fieldLabelKey;

  const _NoteField({
    required this.emoji,
    required this.titleKey,
    required this.hintKey,
    required this.controller,
    required this.onChanged,
    required this.color,
    this.extra,
    this.fieldLabelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              EmojiBadge(emoji, color: color, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t(titleKey),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.t(hintKey),
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ?extra,
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: fieldLabelKey == null
                  ? null
                  : context.t(fieldLabelKey!),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedOnPhone extends StatelessWidget {
  const _SavedOnPhone();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.phone_android,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            context.t('gd_savedOnPhone'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}
