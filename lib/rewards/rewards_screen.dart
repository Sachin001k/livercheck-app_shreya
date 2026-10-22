import 'package:flutter/material.dart';

import '../app_language.dart';
import '../daily/daily_store.dart';
import '../services/data_service.dart';
import '../streak.dart';
import '../survey/health_ui.dart';
import '../survey/progress_store.dart';
import '../theme.dart';
import '../widgets/friendly_state.dart';
import '../widgets/skeleton.dart';
import 'badges.dart';
import 'reward_store.dart';
import 'special_survey_screen.dart';

const int coinsPerLevel = 100;

/// "5 Oct" style date in the current language.
String _shortDate(BuildContext context, DateTime d) =>
    '${d.day} ${monthShort(context, d.month)}';

/// Translated name of a coin source; unknown reasons show the code.
String _reasonName(BuildContext context, String reason) {
  final key = reasonLabels[reason]?.$2;
  return key == null ? reason : context.t(key);
}

class _Data {
  final RewardsData rewards;
  final List<Achievement> badges;

  const _Data(this.rewards, this.badges);
}

/// Rewards tab: coins and level, how to earn, special surveys, badges,
/// redeem (coming soon) and coin history.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  _Data? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
    DataService.changes.addListener(_load);
  }

  @override
  void dispose() {
    DataService.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        RewardStore.load(),
        ProgressStore.load(),
        DailyStore.load(days: 365),
        DataService.fetchAssessments(limit: 1),
      ]);
      final rewards = results[0] as RewardsData;
      final history = (results[1] as ProgressData).history;
      final daily = results[2] as DailySummary;
      final fib4 = results[3] as List<Assessment>;
      final days = [for (final e in daily.days.values) e.day];
      final badges = computeBadges(
        healthChecks: history.length,
        scoreImproved:
            history.length > 1 && history.last.score > history.first.score,
        longestStreak: longestStreak(days),
        bestDayScore: daily.days.values.fold(
          0,
          (m, e) => (e.score ?? 0) > m ? e.score! : m,
        ),
        coins: rewards.totalCoins,
        bloodReportAdded: fib4.isNotEmpty,
        specialSurveysDone: rewards.specialSurveysDone,
      );
      if (!mounted) return;
      setState(() {
        _data = _Data(rewards, badges);
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _openSurvey(SpecialSurvey s) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SpecialSurveyScreen(survey: s)));
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (data == null && _error != null)
            SurfaceCard(child: FriendlyState.error(_error!, onRetry: _load))
          else if (data == null)
            const SkeletonList(heights: [150, 200, 120, 220])
          else ...[
            _BalanceCard(coins: data.rewards.totalCoins),
            _title(context.t('rewardsHowToEarn')),
            _HowToEarn(rules: data.rewards.rules),
            _title(context.t('rewardsSpecialSurveys')),
            _SurveysList(surveys: data.rewards.surveys, onOpen: _openSurvey),
            _title(context.t('rewardsBadges')),
            BadgesGrid(badges: data.badges),
            _title(context.t('rewardsRedeem')),
            const _RedeemPlaceholder(),
            _title(context.t('rewardsHistory')),
            _CoinHistory(events: data.rewards.events),
          ],
        ],
      ),
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );
}

class _BalanceCard extends StatelessWidget {
  final int coins;

  const _BalanceCard({required this.coins});

  @override
  Widget build(BuildContext context) {
    final level = coins ~/ coinsPerLevel + 1;
    final into = coins % coinsPerLevel;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Deep amber/brown, dark enough for white text (the lighter
        // amber/orange failed contrast).
        gradient: const LinearGradient(
          colors: [Color(0xFF9A5B00), Color(0xFFB45309)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 56)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('rewardsYourCoins'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: coins.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (_, v, _) => Text(
                    '${v.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tf('rw_levelLine', {
                    'level': level,
                    'n': coinsPerLevel - into,
                  }),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: into / coinsPerLevel),
                  duration: const Duration(milliseconds: 900),
                  builder: (_, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 7,
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToEarn extends StatelessWidget {
  final List<RewardRule> rules;

  const _HowToEarn({required this.rules});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final r in rules)
            ListTile(
              leading: Text(
                reasonLabels[r.reason]?.$1 ?? '🪙',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                _reasonName(context, r.reason),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                ruleDescriptionKeys[r.reason] != null
                    ? context.t(ruleDescriptionKeys[r.reason]!)
                    : r.description,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              trailing: Text(
                r.reason == 'special_survey'
                    ? context.t('rewardsPerSurvey')
                    : '+${r.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SurveysList extends StatelessWidget {
  final List<SpecialSurvey> surveys;
  final ValueChanged<SpecialSurvey> onOpen;

  const _SurveysList({required this.surveys, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return SurfaceCard(
        child: FriendlyState(
          emoji: '📣',
          title: context.t('rewardsSpecialSurveys'),
          message: context.t('rewardsNoSurveys'),
        ),
      );
    }
    return Column(
      children: [
        for (final s in surveys)
          SurfaceCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  s.completed ? '✅' : '📣',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        s.completed
                            ? context.t('rewardsCompleted')
                            : '🪙 ${s.rewardCoins}'
                                  '${s.endsAt == null ? '' : ' · ${context.t('rewardsEnds')} ${_shortDate(context, s.endsAt!)}'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!s.completed)
                  FilledButton(
                    onPressed: () => onOpen(s),
                    child: Text(context.t('rewardsStart')),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Badge tiles, 3 per row on phones (5 on wide screens).
class BadgesGrid extends StatelessWidget {
  final List<Achievement> badges;

  const BadgesGrid({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((b) => b.unlocked).length;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tf('rw_badgesUnlocked', {
              'n': unlocked,
              'total': badges.length,
            }),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final columns = c.maxWidth > 480 ? 5 : 3;
              // Tile height from its content at the phone's text size (a
              // fixed aspect ratio overflowed above ~1.1× text): padding,
              // emoji, gap, one-line label, a two-line hint and some slack
              // (1.45 = the Material 3 body line height).
              final ts = MediaQuery.textScalerOf(context);
              final tileHeight =
                  16 +
                  ts.scale(28) * 1.45 +
                  6 +
                  ts.scale(11) * 1.45 +
                  ts.scale(9) * 1.45 * 2 +
                  6;
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: tileHeight,
                ),
                children: [
                  for (final b in badges)
                    Tooltip(
                      message: context.t(b.unlocked ? b.labelKey : b.hintKey),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: b.unlocked ? mintCard : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: b.unlocked ? 1 : 0.35,
                              child: Text(
                                b.unlocked ? b.emoji : '🔒',
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.t(b.labelKey),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: b.unlocked ? null : Colors.grey,
                              ),
                            ),
                            if (!b.unlocked)
                              Text(
                                context.t(b.hintKey),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Placeholder until there is something to spend coins on.
class _RedeemPlaceholder extends StatelessWidget {
  const _RedeemPlaceholder();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SurfaceCard(
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap so the "Coming soon" pill drops to the next line
                // instead of overflowing with long translations.
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      context.t('rewardsRedeem'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        context.t('comingSoon'),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('rewardsRedeemSoon'),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinHistory extends StatelessWidget {
  final List<CoinEvent> events;

  const _CoinHistory({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SurfaceCard(
        child: FriendlyState(
          emoji: '🪙',
          title: context.t('rewardsHistory'),
          message: context.t('rewardsNoHistory'),
        ),
      );
    }
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final e in events.take(30))
            ListTile(
              dense: true,
              leading: Text(
                reasonLabels[e.reason]?.$1 ?? '🪙',
                style: const TextStyle(fontSize: 20),
              ),
              title: Text(_reasonName(context, e.reason)),
              subtitle: Text(_shortDate(context, e.createdAt)),
              trailing: Text(
                '+${e.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
