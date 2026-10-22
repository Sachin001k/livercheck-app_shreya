import 'package:flutter/material.dart';

import '../app_language.dart';
import '../daily/daily_store.dart';
import '../daily/daily_targets.dart';
import '../daily/weekly_summary.dart';
import '../fib4.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../streak.dart';
import '../survey/health_ui.dart';
import '../survey/progress_store.dart';
import '../survey/results_screen.dart';
import '../theme.dart';
import '../widgets/friendly_state.dart';
import '../widgets/skeleton.dart';
import 'settings_screen.dart';
import 'profile_setup_screen.dart';

// Matiks-style progress: health score, coins and levels, streak, an
// "Every day" history and badges. Data lives in Supabase (see ProgressStore
// and DailyStore).

String _time(BuildContext context, DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return context.tf(d.hour < 12 ? 'pf_timeAm' : 'pf_timePm', {
    't': '$h:${d.minute.toString().padLeft(2, '0')}',
  });
}

String _dayLabel(BuildContext context, DateTime d) {
  final now = DateTime.now();
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return context.t('pf_today');
  if (diff == 1) return context.t('pf_yesterday');
  return shortDate(context, d);
}

Color _scoreColor(int score, ColorScheme cs) => score >= 80
    ? kLow
    : score >= 60
    ? cs.primary
    : score >= 40
    ? kModDark
    : kHigh;

/// Coins needed per level.
const int _coinsPerLevel = 100;

class _ProfileData {
  final ProgressData progress;
  final List<Assessment> fib4Checks;
  final DailySummary daily;

  const _ProfileData(this.progress, this.fib4Checks, this.daily);
}

class ProfileScreen extends StatefulWidget {
  final Profile profile;
  final VoidCallback onProfileChanged;

  /// Switches the app to the Check tab.
  final VoidCallback onOpenCheck;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onOpenCheck,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfileData? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
    ProgressStore.changes.addListener(
      _load,
    ); // refresh when a check or habit is saved
  }

  @override
  void dispose() {
    ProgressStore.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ProgressStore.load(),
        DataService.fetchAssessments(),
        DailyStore.load(days: 365),
      ]);
      if (!mounted) return;
      setState(() {
        _data = _ProfileData(
          results[0] as ProgressData,
          results[1] as List<Assessment>,
          results[2] as DailySummary,
        );
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(onEditProfile: _editProfile),
      ),
    );
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
          initial: widget.profile,
          onSaved: widget.onProfileChanged,
        ),
      ),
    );
  }

  void _openResult(ScoreEntry e) {
    final result = e.result;
    if (result == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(result: result, takenAt: e.date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(
            profile: widget.profile,
            onEdit: _editProfile,
            onSettings: _openSettings,
          ),
          const SizedBox(height: 16),
          if (data == null && _error != null)
            SurfaceCard(child: FriendlyState.error(_error!, onRetry: _load))
          else if (data == null)
            const SkeletonList()
          else
            ..._buildBody(context, data),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, _ProfileData data) {
    final d = data.progress;
    final daily = data.daily;
    final now = DateTime.now();

    // A streak day = checked in or logged that day.
    final streakDays = [for (final e in daily.days.values) e.day];
    final streak = currentStreak(streakDays, now);
    final longest = longestStreak(streakDays);

    final coins = daily.totalCoins;
    final level = coins ~/ _coinsPerLevel + 1;
    final into = coins % _coinsPerLevel;

    final history = d.history;
    final last = history.isEmpty ? null : history.last;
    final prev = history.length > 1 ? history[history.length - 2] : null;
    final delta = (last != null && prev != null)
        ? last.score - prev.score
        : null;
    final latestFib4 = data.fib4Checks.isEmpty ? null : data.fib4Checks.first;
    final bmi = widget.profile.bmi;

    return [
      _ScoreCard(
        last: last,
        delta: delta,
        level: level,
        into: into,
        onOpenLast: last?.result == null ? null : () => _openResult(last!),
        onStartCheck: widget.onOpenCheck,
      ),
      const SizedBox(height: 16),
      _StreakCard(
        streak: streak,
        longest: longest,
        streakDays: streakDays,
        today: now,
      ),
      const SizedBox(height: 16),
      _WeeklyCard(summary: weeklySummary(daily.days.values, now)),
      const SizedBox(height: 16),
      StatGrid(
        children: [
          StatCard(
            icon: Icons.savings,
            label: context.t('pf_coins'),
            value: '$coins',
            caption: context.tf('pf_levelN', {'level': level}),
            color: Colors.amber.shade800,
          ),
          StatCard(
            icon: Icons.fact_check,
            label: context.t('checksDone'),
            value: '${history.length}',
            caption: context.t('pf_healthChecks'),
            color: tealDark,
          ),
          StatCard(
            icon: Icons.monitor_heart,
            label: context.t('latestFib4'),
            value: latestFib4?.score.toStringAsFixed(2) ?? '—',
            caption: latestFib4 == null
                ? context.t('pf_addBloodReport')
                : context.t(_tierKey(latestFib4.tier)),
            color: latestFib4 == null
                ? Colors.grey
                : _tierColor(latestFib4.tier),
          ),
          StatCard(
            icon: Icons.monitor_weight,
            label: context.t('bmiLabel'),
            value: bmi?.toStringAsFixed(1) ?? '—',
            caption: bmi == null
                ? context.t('noDataYet')
                : _bmiLabel(context, bmi),
            color: Colors.purple,
          ),
        ],
      ),
      if (history.length > 1) ...[
        _SectionTitle(context.t('pf_scoreHistory')),
        _ScoreChart(history: history),
      ],
      _SectionTitle(context.t('pf_everyDay')),
      _EverydayList(
        daily: daily,
        history: history,
        onOpen: _openResult,
        onStartCheck: widget.onOpenCheck,
      ),
      const SizedBox(height: 16),
      _ActivityCard(daily: daily, today: now),
    ];
  }

  String _bmiLabel(BuildContext context, double bmi) =>
      context.t(switch (bmiCategory(bmi)) {
        BmiCategory.underweight => 'bmiUnderweight',
        BmiCategory.normal => 'bmiNormal',
        BmiCategory.overweight => 'bmiOverweight',
        BmiCategory.obese => 'bmiObese',
      });
}

Color _tierColor(RiskTier tier) => switch (tier) {
  RiskTier.low => Colors.green,
  RiskTier.intermediate => Colors.orange,
  RiskTier.high => Colors.red,
};

String _tierKey(RiskTier tier) => switch (tier) {
  RiskTier.low => 'tierLow',
  RiskTier.intermediate => 'tierIntermediate',
  RiskTier.high => 'tierHigh',
};

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onEdit;
  final VoidCallback onSettings;

  const _HeaderCard({
    required this.profile,
    required this.onEdit,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final contact = user?.email?.isNotEmpty == true
        ? user!.email!
        : (user?.phone?.isNotEmpty == true ? '+${user!.phone}' : '');
    final name = profile.fullName?.trim() ?? '';
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    final since = profile.createdAt.toLocal();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [tealDark, tealLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Text(
              initials.isEmpty ? '🙂' : initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: tealDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (contact.isNotEmpty)
                  Text(contact, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  [
                    context.tf('pf_memberSinceDate', {
                      'm': monthShort(context, since.month),
                      'y': since.year,
                    }),
                    if (profile.age != null)
                      context.tf('pf_ageYears', {'n': profile.age}),
                  ].join(' · '),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: context.t('settingsTitle'),
                onPressed: onSettings,
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
              IconButton(
                tooltip: context.t('editProfile'),
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Latest health score ring, change since last check, and XP level bar.
class _ScoreCard extends StatelessWidget {
  final ScoreEntry? last;
  final int? delta;
  final int level;
  final int into;
  final VoidCallback? onOpenLast;
  final VoidCallback onStartCheck;

  const _ScoreCard({
    required this.last,
    required this.delta,
    required this.level,
    required this.into,
    required this.onOpenLast,
    required this.onStartCheck,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entry = last;
    if (entry == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('pf_getScoreTitle'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.t('pf_getScoreBody'),
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onStartCheck,
                child: Text(context.t('pf_startMyCheck')),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: entry.score / 100,
                    strokeWidth: 11,
                    strokeCap: StrokeCap.round,
                    color: _scoreColor(entry.score, cs),
                    backgroundColor: cs.outlineVariant,
                  ),
                  Center(
                    child: Text(
                      '${entry.score}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
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
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        entry.tier.isEmpty
                            ? context.t('pf_healthScore')
                            : tierText(context, entry.tier),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (delta != null)
                        Text(
                          context.tf('pf_sinceLastCheck', {
                            'n': '${delta! >= 0 ? '+' : ''}$delta',
                          }),
                          style: TextStyle(
                            color: delta! >= 0 ? kLow : kHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    context.tf('pf_levelProgress', {
                      'level': level,
                      'n': _coinsPerLevel - into,
                      'next': level + 1,
                    }),
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: into / _coinsPerLevel,
                      minHeight: 6,
                    ),
                  ),
                  if (onOpenLast != null)
                    TextButton(
                      onPressed: onOpenLast,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(context.t('pf_seeLastResults')),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bars for the last 10 health checks.
class _ScoreChart extends StatelessWidget {
  final List<ScoreEntry> history;

  const _ScoreChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shown = history.skip(history.length > 10 ? history.length - 10 : 0);
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        // Bars (max 80) plus room for the two labels at the phone's text size.
        height: 122 + MediaQuery.textScalerOf(context).scale(28),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final e in shown)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${e.score}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: 80 * e.score / 100,
                        decoration: BoxDecoration(
                          color: _scoreColor(e.score, cs),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Scales down instead of wrapping when ten bars
                      // share a narrow phone or the text is large.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${e.date.day}/${e.date.month}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One card per day, newest first: check-in, daily log score, coins
/// earned and any health checks taken that day (tap to reopen).
class _EverydayList extends StatelessWidget {
  final DailySummary daily;
  final List<ScoreEntry> history;
  final ValueChanged<ScoreEntry> onOpen;
  final VoidCallback onStartCheck;

  const _EverydayList({
    required this.daily,
    required this.history,
    required this.onOpen,
    required this.onStartCheck,
  });

  static const _maxDays = 14;

  @override
  Widget build(BuildContext context) {
    final checksByDay = <String, List<ScoreEntry>>{};
    for (final e in history.reversed) {
      checksByDay.putIfAbsent(dayKey(e.date), () => []).add(e);
    }
    final keys = {...daily.days.keys, ...checksByDay.keys}.toList()
      ..sort((a, b) => b.compareTo(a));

    if (keys.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.history),
          title: Text(context.t('pf_nothingYet')),
          subtitle: Text(context.t('pf_nothingYetBody')),
          trailing: TextButton(
            onPressed: onStartCheck,
            child: Text(context.t('rewardsStart')),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final key in keys.take(_maxDays))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DayCard(
              day: DateTime.parse(key),
              entry: daily.days[key],
              checks: checksByDay[key] ?? const [],
              onOpen: onOpen,
            ),
          ),
        if (keys.length > _maxDays)
          Text(
            context.tf('pf_showingLastDays', {'n': _maxDays}),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final DailyEntry? entry;
  final List<ScoreEntry> checks;
  final ValueChanged<ScoreEntry> onOpen;

  const _DayCard({
    required this.day,
    required this.entry,
    required this.checks,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final e = entry;
    final score = e != null && e.logged ? e.score : null;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _dayLabel(context, day),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (e != null && e.coins > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '🪙 +${e.coins}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DayChip(
                icon: e?.checkedIn == true
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: e?.checkedIn == true ? kLow : cs.outline,
                text: context.t(
                  e?.checkedIn == true ? 'pf_checkedIn' : 'pf_noCheckin',
                ),
              ),
              _DayChip(
                icon: Icons.today,
                color: score == null ? cs.outline : _scoreColor(score, cs),
                text: score == null
                    ? context.t('pf_noDailyLog')
                    : context.tf('pf_dailyLogScore', {'n': score}),
              ),
            ],
          ),
          for (final c in checks) _HistoryRow(entry: c, onTap: () => onOpen(c)),
          if (checks.isEmpty) const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _DayChip({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final ScoreEntry entry;
  final VoidCallback onTap;

  const _HistoryRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final result = entry.result;
    // The organ needing most attention, e.g. "Liver needs attention".
    String? concern;
    if (result != null) {
      final worst = result.organs.values.where((o) => o.level != 'low').toList()
        ..sort(
          (a, b) =>
              (a.level == 'high' ? 0 : 1).compareTo(b.level == 'high' ? 0 : 1),
        );
      concern = worst.isEmpty
          ? context.t('pf_allOrgansGood')
          : '${organName(context, worst.first.key)}: '
                '${levelText(worst.first.level, context).toLowerCase()}';
    }
    final color = _scoreColor(entry.score, cs);

    return ListTile(
      onTap: result == null ? null : onTap,
      leading: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: entry.score / 100,
              strokeWidth: 4,
              color: color,
              backgroundColor: cs.outlineVariant,
            ),
            Center(
              child: Text(
                '${entry.score}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.zero,
      title: Text(
        context.tf('pf_healthCheckTitle', {
          'tier': entry.tier.isEmpty
              ? '${entry.score}/100'
              : tierText(context, entry.tier),
        }),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text([_time(context, entry.date), ?concern].join(' · ')),
      trailing: result == null ? null : const Icon(Icons.chevron_right),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final int longest;
  final List<DateTime> streakDays;
  final DateTime today;

  const _StreakCard({
    required this.streak,
    required this.longest,
    required this.streakDays,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final active = streakDays
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    final last7 = [
      for (var i = 6; i >= 0; i--)
        DateTime(today.year, today.month, today.day - i),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: streak > 0 ? 40 : 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          height: 1,
                        ),
                      ),
                      Text(context.t('dayStreak')),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.t('longestStreak'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$longest ${context.t('daysUnit')}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in last7)
                  Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active.contains(day)
                              ? Colors.deepOrange
                              : Colors.grey.shade200,
                          border: day == last7.last
                              ? Border.all(color: Colors.deepOrange, width: 2)
                              : null,
                        ),
                        child: active.contains(day)
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.t('pf_wdLetter${day.weekday}'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.t('pf_streakHint'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Two stat cards per row. Rows size to their content (no fixed aspect
/// ratio), so cards never overflow on narrow phones or with large text;
/// both cards in a row share the taller height.
class StatGrid extends StatelessWidget {
  final List<Widget> children;

  const StatGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: gap),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One number on the Profile (coins, checks done, FIB-4, BMI).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Text(
              caption,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// GitHub-style grid: one column per week, one row per weekday. Light =
/// checked in, darker = logged the day, darkest = scored 90+.
class _ActivityCard extends StatelessWidget {
  final DailySummary daily;
  final DateTime today;

  const _ActivityCard({required this.daily, required this.today});

  static const _targetCell = 18.0;
  static const _gap = 4.0;

  Color _shade(DailyEntry? e) {
    if (e == null) return Colors.grey.shade200;
    if (!e.logged) return tealLight.withValues(alpha: 0.4);
    if ((e.score ?? 0) < bonusScore) return tealLight;
    return tealDark;
  }

  @override
  Widget build(BuildContext context) {
    final todayDay = DateTime(today.year, today.month, today.day);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('activityTitle'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = _gap;
                final weeks =
                    ((constraints.maxWidth + gap) / (_targetCell + gap))
                        .floor()
                        .clamp(4, 26);
                final cell = (constraints.maxWidth - gap * (weeks - 1)) / weeks;
                // Monday of the first week shown.
                final start = DateTime(
                  todayDay.year,
                  todayDay.month,
                  todayDay.day - (todayDay.weekday - 1) - (weeks - 1) * 7,
                );
                return Row(
                  children: [
                    for (var w = 0; w < weeks; w++)
                      Padding(
                        padding: EdgeInsets.only(
                          right: w == weeks - 1 ? 0 : gap,
                        ),
                        child: Column(
                          children: [
                            for (var d = 0; d < 7; d++)
                              Builder(
                                builder: (_) {
                                  final day = DateTime(
                                    start.year,
                                    start.month,
                                    start.day + w * 7 + d,
                                  );
                                  final isFuture = day.isAfter(todayDay);
                                  return Container(
                                    width: cell,
                                    height: cell,
                                    margin: const EdgeInsets.only(bottom: gap),
                                    decoration: BoxDecoration(
                                      color: isFuture
                                          ? Colors.transparent
                                          : _shade(daily.days[dayKey(day)]),
                                      borderRadius: BorderRadius.circular(3),
                                      border: day == todayDay
                                          ? Border.all(color: Colors.deepOrange)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// This week vs last week: average daily score, days logged, best day.
class _WeeklyCard extends StatelessWidget {
  final WeeklySummary summary;

  const _WeeklyCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = summary;
    if (s.averageScore == null) {
      return SurfaceCard(
        child: Row(
          children: [
            const Text('📊', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.t('weeklyEmpty'),
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }
    final change = s.change;
    Widget stat(String value, String label, {Color? color}) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('weeklyTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${change >= 0 ? '▲' : '▼'} '
                    '${context.tf('pf_vsLastWeek', {'n': change.abs()})}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: change >= 0 ? kLow : kHigh,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat(
                '${s.averageScore}',
                context.t('weeklyAverage'),
                color: _scoreColor(s.averageScore!, cs),
              ),
              stat('${s.daysLogged}/7', context.t('weeklyDaysLogged')),
              stat(
                s.bestDay == null
                    ? '—'
                    : context.t('pf_wd${s.bestDay!.weekday}'),
                '${context.t('weeklyBest')}${s.bestScore == null ? '' : ' · ${s.bestScore}'}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
