import 'package:flutter/material.dart';

import '../app_language.dart';
import '../daily/daily_checkin_card.dart';
import '../data/home_content.dart';
import '../services/data_service.dart';
import '../theme.dart';
import 'food_detail_sheet.dart';

/// Home tab: the health check and today's check-in side by side, then food
/// recommendations, health suggestions and FAQs (dummy data for now, see
/// lib/data/home_content.dart).
class HomeScreen extends StatelessWidget {
  final Profile profile;
  final VoidCallback onStartCheck;

  const HomeScreen({
    super.key,
    required this.profile,
    required this.onStartCheck,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = (profile.fullName ?? '').trim().split(' ').first;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${context.t('greeting')}, $firstName 👋',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // Side by side on wide screens, stacked on phones.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final check = _CheckCard(onStart: onStartCheck);
              final daily = DailyCheckinCard(profile: profile);
              if (constraints.maxWidth < 620) {
                return Column(
                  children: [check, const SizedBox(height: 16), daily],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: check),
                  const SizedBox(width: 16),
                  Expanded(child: daily),
                ],
              );
            },
          ),
        ),
        _SectionTitle(context.t('foodSectionTitle')),
        SizedBox(
          height: 210,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: foodTips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _FoodCard(tip: foodTips[i]),
          ),
        ),
        _SectionTitle(context.t('tipsSectionTitle')),
        for (final tip in healthTips)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _HealthTipCard(tip: tip),
          ),
        _SectionTitle(context.t('faqSectionTitle')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final faq in faqs)
                  ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      faq.question,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(faq.answer)],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Gradient card that starts the health check, with a gently floating
/// stethoscope.
class _CheckCard extends StatefulWidget {
  final VoidCallback onStart;

  const _CheckCard({required this.onStart});

  @override
  State<_CheckCard> createState() => _CheckCardState();
}

class _CheckCardState extends State<_CheckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const organs = [
      '🍃 Liver',
      '❤️ Heart',
      '🫘 Kidneys',
      '🫁 Lungs',
      '🍬 Sugar',
    ];
    return Container(
      height: dailyCardHeight,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tealDark, tealLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tealDark.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('homeCheckCardTitle'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('homeCheckCardBody'),
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _float,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    0,
                    -8 * Curves.easeInOut.transform(_float.value),
                  ),
                  child: child,
                ),
                child: const Text('🩺', style: TextStyle(fontSize: 88)),
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in organs)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    o,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.onStart,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: tealDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                context.t('startCheck'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodTip tip;

  const _FoodCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final color = tip.recommended ? Colors.green : Colors.red;
    return SizedBox(
      width: 160,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showFoodDetail(context, tip),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tip.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.t(tip.recommended ? 'eatMore' : 'limitFood'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: color.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tip.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    tip.why,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.fade,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.t('viewDetails'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tealDark,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: tealDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthTipCard extends StatelessWidget {
  final HealthTip tip;

  const _HealthTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mintCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tip.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(tip.body, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
