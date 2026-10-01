import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../streak.dart';
import '../survey/health_ui.dart';
import '../theme.dart';
import 'daily_items.dart';
import 'daily_store.dart';
import 'daily_targets.dart';

/// Height shared with the card beside it on the Home page.
const double dailyCardHeight = 440;

/// Home page daily check-in: check in (+1), then a swipeable card-by-card
/// log (+10, +20 bonus at 90+), with animated score, coins and streak.
class DailyCheckinCard extends StatefulWidget {
  final Profile profile;

  const DailyCheckinCard({super.key, required this.profile});

  @override
  State<DailyCheckinCard> createState() => _DailyCheckinCardState();
}

enum _Phase { overview, logging }

class _DailyCheckinCardState extends State<DailyCheckinCard>
    with SingleTickerProviderStateMixin {
  DailySummary? _summary;
  Object? _error;
  _Phase _phase = _Phase.overview;
  bool _busy = false;

  final _pages = PageController();
  int _page = 0;
  Map<String, double?> _values = valuesFromLog(null);

  /// Set right after coins are earned, to play the celebration.
  ({int coins, String message})? _celebration;
  Timer? _celebrationTimer;

  late final AnimationController _pulse;

  DailyTargets get _targets => targetsFor(
    gender: widget.profile.gender,
    age: widget.profile.age,
    heightCm: widget.profile.heightCm,
    weightKg: widget.profile.weightKg,
  );

  @override
  void initState() {
    super.initState();
    // Created here, not lazily: a lazy controller first touched in dispose()
    // would look up a deactivated widget and crash.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _load();
    DataService.changes.addListener(_load);
  }

  @override
  void dispose() {
    DataService.changes.removeListener(_load);
    _pages.dispose();
    _pulse.dispose();
    _celebrationTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await DailyStore.load();
      if (!mounted) return;
      setState(() {
        _summary = s;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _celebrate(int coins, String message) {
    _celebrationTimer?.cancel();
    setState(() => _celebration = (coins: coins, message: message));
    _celebrationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _celebration = null);
    });
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AuthService.describeError(e, 'Something went wrong')),
      ),
    );
  }

  Future<void> _checkIn() async {
    setState(() => _busy = true);
    try {
      final earned = await DailyStore.checkIn();
      if (earned) _celebrate(coinsForCheckin, 'Checked in!');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startLog() {
    setState(() {
      _values = valuesFromLog(_summary?.today?.log);
      _phase = _Phase.logging;
      _page = 0;
    });
  }

  void _goTo(int page) {
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final outcome = await DailyStore.saveLog(
        logFromValues(_values),
        _targets,
      );
      if (!mounted) return;
      setState(() => _phase = _Phase.overview);
      _celebrate(
        outcome.coinsEarned,
        outcome.score >= bonusScore
            ? 'Score ${outcome.score} · bonus!'
            : 'Score ${outcome.score}/100',
      );
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: dailyCardHeight,
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: _summary == null ? _loadingOrError() : _content(context),
              ),
              if (_celebration != null)
                _CelebrationOverlay(celebration: _celebration!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingOrError() {
    if (_error == null) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            'Could not load today.\n${AuthService.describeError(_error!, '')}',
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final s = _summary!;
    final streak = currentStreak(
      s.days.values.map((e) => e.day),
      DateTime.now(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daily check-in',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            _Pill(emoji: '🔥', value: streak, color: Colors.deepOrange),
            const SizedBox(width: 6),
            _Pill(
              emoji: '🪙',
              value: s.totalCoins,
              color: Colors.amber.shade800,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _phase == _Phase.overview
                ? KeyedSubtree(
                    key: const ValueKey('overview'),
                    child: _overview(context, s),
                  )
                : KeyedSubtree(
                    key: const ValueKey('logging'),
                    child: _logging(context),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Overview: check in, today's score, start/edit the log ──

  Widget _overview(BuildContext context, DailySummary s) {
    final cs = Theme.of(context).colorScheme;
    final today = s.today;
    final checkedIn = today?.checkedIn ?? false;
    final logged = today?.logged ?? false;
    final score = today?.score ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: logged
                ? _AnimatedScoreRing(score: score)
                : checkedIn
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✅', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 6),
                      Text(
                        'Checked in',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                : ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.07).animate(
                      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                    ),
                    child: FilledButton(
                      onPressed: _busy ? null : _checkIn,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(34),
                        backgroundColor: tealDark,
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('👋', style: TextStyle(fontSize: 30)),
                          SizedBox(height: 4),
                          Text(
                            'Check in',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '+$coinsForCheckin 🪙',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        if (logged) ...[
          _ItemDots(values: valuesFromLog(today!.log), targets: _targets),
          const SizedBox(height: 8),
          Text(
            score >= bonusScore
                ? 'Great day! Bonus earned 🎉'
                : 'Reach $bonusScore for +$coinsForBonus bonus coins',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ] else
          Text(
            '${dailyItems.length} quick questions · about 1 minute',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _busy ? null : _startLog,
          icon: Icon(logged ? Icons.edit : Icons.play_arrow),
          label: Text(
            logged ? "Edit today's log" : "Log today  ·  +$coinsForLog 🪙",
          ),
          style: FilledButton.styleFrom(
            backgroundColor: logged
                ? cs.secondaryContainer
                : Colors.amber.shade700,
            foregroundColor: logged ? cs.onSecondaryContainer : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  // ── Logging: one card per item, swipe or tap Next ──

  Widget _logging(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final result = scoreDay(logFromValues(_values), _targets);
    final last = _page == dailyItems.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Close',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _phase = _Phase.overview),
              icon: const Icon(Icons.close),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < dailyItems.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? tealDark
                            : _values[dailyItems[i].key] == null
                            ? cs.outlineVariant
                            : tealLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                result.items.isEmpty ? '—' : '${result.score}',
                key: ValueKey(result.score),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: PageView.builder(
            controller: _pages,
            itemCount: dailyItems.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _ItemPage(
              item: dailyItems[i],
              value: _values[dailyItems[i].key],
              targets: _targets,
              onChanged: (v) => setState(() => _values[dailyItems[i].key] = v),
            ),
          ),
        ),
        Row(
          children: [
            if (_page > 0)
              IconButton.outlined(
                tooltip: 'Back',
                onPressed: () => _goTo(_page - 1),
                icon: const Icon(Icons.chevron_left),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _busy
                    ? null
                    : last
                    ? (result.items.isEmpty ? null : _save)
                    : () => _goTo(_page + 1),
                style: FilledButton.styleFrom(
                  backgroundColor: last ? Colors.amber.shade700 : tealDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _busy
                      ? 'Saving…'
                      : last
                      ? 'Save  ·  +$coinsForLog 🪙'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One item of the log: big value, − / + buttons, slider and a progress
/// bar towards the goal.
class _ItemPage extends StatelessWidget {
  final DailyItem item;
  final double? value;
  final DailyTargets targets;
  final ValueChanged<double?> onChanged;

  const _ItemPage({
    required this.item,
    required this.value,
    required this.targets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final skipped = value == null;
    final v = value ?? item.startValue(targets);
    final goal = item.goal(targets);
    final progress = skipped
        ? 0.0
        : goal == null
        ? (v == 0 ? 1.0 : (1 - v / 3).clamp(0.0, 1.0))
        : (v / goal).clamp(0.0, 1.0);
    void set(double x) => onChanged(
      ((x / item.step).round() * item.step)
          .clamp(item.min, item.max)
          .toDouble(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(item.key),
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
          ),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            item.goalText(targets),
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () => set(v - item.tapStep),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Text.rich(
                    key: ValueKey('${item.key}$value'),
                    textAlign: TextAlign.center,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: skipped ? '—' : item.format(v),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: skipped ? cs.outline : null,
                          ),
                        ),
                        TextSpan(
                          text: ' ${item.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => set(v + item.tapStep),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 3),
            child: Slider(
              value: v.clamp(item.min, item.max),
              min: item.min,
              max: item.max,
              divisions: ((item.max - item.min) / item.step).round(),
              onChanged: set,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (_, p, _) => ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: p,
                minHeight: 6,
                color: p >= 0.99
                    ? kLow
                    : p >= 0.5
                    ? kMod
                    : kHigh,
                backgroundColor: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (item.hint != null)
                Expanded(
                  child: Text(
                    item.hint!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                )
              else
                const Spacer(),
              TextButton(
                onPressed: () =>
                    onChanged(skipped ? item.startValue(targets) : null),
                child: Text(skipped ? 'Add' : 'Skip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small coloured dots showing how each item went today.
class _ItemDots extends StatelessWidget {
  final Map<String, double?> values;
  final DailyTargets targets;

  const _ItemDots({required this.values, required this.targets});

  @override
  Widget build(BuildContext context) {
    final scores = {
      for (final s in scoreDay(logFromValues(values), targets).items)
        s.key: s.value,
    };
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in dailyItems)
          Builder(
            builder: (context) {
              final s = scores[item.key];
              final color = s == null
                  ? Theme.of(context).colorScheme.outlineVariant
                  : s >= 0.99
                  ? kLow
                  : s >= 0.5
                  ? kMod
                  : kHigh;
              return Tooltip(
                message: item.title,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(item.emoji, style: const TextStyle(fontSize: 14)),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _AnimatedScoreRing extends StatelessWidget {
  final int score;

  const _AnimatedScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) {
        final shown = (v * 100).round();
        final color = shown >= bonusScore
            ? kLow
            : shown >= 60
            ? cs.primary
            : shown >= 40
            ? kMod
            : kHigh;
        return SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: v,
                strokeWidth: 13,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$shown',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      "today's score",
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Streak / coin pill whose number counts up when it changes.
class _Pill extends StatelessWidget {
  final String emoji;
  final int value;
  final Color color;

  const _Pill({required this.emoji, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.toDouble()),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (_, v, _) => Text(
          '$emoji ${v.round()}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// "+11 🪙" that pops up and floats away after coins are earned.
class _CelebrationOverlay extends StatelessWidget {
  final ({int coins, String message}) celebration;

  const _CelebrationOverlay({required this.celebration});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 2000),
          builder: (_, t, _) {
            // Pop in (0–0.2), hold, then float up and fade (0.7–1).
            final scale = t < 0.2 ? Curves.elasticOut.transform(t / 0.2) : 1.0;
            final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
            final rise = t < 0.7 ? 0.0 : (t - 0.7) / 0.3 * 40;
            return Container(
              color: Colors.white.withValues(alpha: 0.75 * fade),
              alignment: Alignment.center,
              child: Opacity(
                opacity: fade.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, -rise),
                  child: Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 64)),
                        Text(
                          celebration.coins > 0
                              ? '+${celebration.coins} coins'
                              : 'Saved',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        Text(
                          celebration.message,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
