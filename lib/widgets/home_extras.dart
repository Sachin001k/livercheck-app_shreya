import 'package:flutter/material.dart';

import '../app_language.dart';
import '../data/home_content.dart';
import '../rewards/reward_store.dart';
import '../rewards/special_survey_screen.dart';
import '../services/data_service.dart';
import '../survey/health_ui.dart';
import '../theme.dart';

/// Shows the newest open special survey, if any. Hidden otherwise.
class SpecialSurveyBanner extends StatefulWidget {
  const SpecialSurveyBanner({super.key});

  @override
  State<SpecialSurveyBanner> createState() => _SpecialSurveyBannerState();
}

class _SpecialSurveyBannerState extends State<SpecialSurveyBanner> {
  SpecialSurvey? _survey;

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
      final open = await RewardStore.openSurveys();
      if (mounted) setState(() => _survey = open.isEmpty ? null : open.first);
    } catch (_) {
      // No banner if surveys can't be loaded; the Rewards tab shows errors.
      if (mounted) setState(() => _survey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _survey;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: s == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SpecialSurveyScreen(survey: s)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const Text('📣', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(context.t('surveyNewBadge').toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Colors.indigo.shade700)),
                          Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          if (s.description != null)
                            Text(s.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Column(children: [
                        Text('+${s.rewardCoins}',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 18, color: Colors.amber.shade800)),
                        const Text('🪙'),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }
}

/// One health tip a day, rotating through `healthTips`.
class TipOfTheDayCard extends StatelessWidget {
  const TipOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final tip = healthTips[dayOfYear % healthTips.length];
    return SurfaceCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: mintCard, borderRadius: BorderRadius.circular(14)),
          child: Text(tip.emoji, style: const TextStyle(fontSize: 26)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('💡 ${context.t('tipOfTheDay')}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tealDark)),
            const SizedBox(height: 2),
            Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(tip.body, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      ]),
    );
  }
}
