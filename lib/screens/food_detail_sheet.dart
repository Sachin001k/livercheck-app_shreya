import 'package:flutter/material.dart';

import '../app_language.dart';
import '../data/home_content.dart';
import '../theme.dart';

/// Opens the pop-up for a food card on the home page.
Future<void> showFoodDetail(BuildContext context, FoodTip tip) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: tip.detail == null ? 0.4 : 0.85,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          _FoodDetailBody(tip: tip, scrollController: scrollController),
    ),
  );
}

class _FoodDetailBody extends StatelessWidget {
  final FoodTip tip;
  final ScrollController scrollController;

  const _FoodDetailBody({required this.tip, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final detail = tip.detail;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _Header(tip: tip),
        const SizedBox(height: 20),
        if (detail == null)
          Text(
            context.t('detailsComingSoon'),
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...[
          _NutritionCard(detail: detail),
          const SizedBox(height: 16),
          _IntakeCard(intake: detail.intake),
          const SizedBox(height: 16),
          if (detail.benefits.isNotEmpty) ...[
            _PointsCard(
              title: context.t('benefitsTitle'),
              icon: Icons.favorite,
              color: Colors.green,
              points: detail.benefits,
            ),
            const SizedBox(height: 16),
          ],
          _PointsCard(
            title: context.t('overconsumptionTitle'),
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            points: detail.overconsumption,
          ),
          const SizedBox(height: 16),
          if (detail.swaps.isNotEmpty) ...[
            _PointsCard(
              title: context.t('swapsTitle'),
              icon: Icons.swap_horiz,
              color: Colors.blue,
              points: detail.swaps,
            ),
            const SizedBox(height: 16),
          ],
          _PrecautionsCard(precautions: detail.precautions),
          const SizedBox(height: 16),
          Text(
            context.t('sampleContentNote'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final FoodTip tip;

  const _Header({required this.tip});

  @override
  Widget build(BuildContext context) {
    final color = tip.recommended ? Colors.green : Colors.red;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: mintCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(tip.emoji, style: const TextStyle(fontSize: 40)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _Pill(
                text: context.t(tip.recommended ? 'eatMore' : 'limitFood'),
                color: color,
              ),
              const SizedBox(height: 8),
              Text(tip.why),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final MaterialColor color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A titled card, shared by every section of the pop-up.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final FoodDetail detail;

  const _NutritionCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: context.t('nutritionTitle'),
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${detail.kcal}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                context.t('kcalUnit'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${context.t('perServing')} ${detail.serving}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Three columns on wide sheets, two on phones.
              final columns = constraints.maxWidth > 420 ? 3 : 2;
              const gap = 8.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final n in detail.nutrients)
                    Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tealLight.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.amount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: tealDark,
                            ),
                          ),
                          Text(
                            n.name,
                            style: Theme.of(context).textTheme.bodySmall,
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
    );
  }
}

class _IntakeCard extends StatelessWidget {
  final List<IntakeGuide> intake;

  const _IntakeCard({required this.intake});

  static const _emoji = {
    AgeGroup.children: '🧒',
    AgeGroup.adults: '🧑',
    AgeGroup.elders: '🧓',
  };

  static const _labelKey = {
    AgeGroup.children: 'ageChildren',
    AgeGroup.adults: 'ageAdults',
    AgeGroup.elders: 'ageElders',
  };

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: context.t('dailyAmountTitle'),
      icon: Icons.restaurant,
      color: tealDark,
      child: Column(
        children: [
          for (final guide in intake)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mintCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _emoji[guide.group]!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.t(_labelKey[guide.group]!)} · ${guide.ages}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          guide.amount,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (guide.note != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            guide.note!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
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

/// Benefits (green) or over-consumption risks (orange).
class _PointsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final MaterialColor color;
  final List<HealthPoint> points;

  const _PointsCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      icon: icon,
      color: color.shade700,
      child: Column(
        children: [
          for (final point in points)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: color, width: 3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          point.body,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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

class _PrecautionsCard extends StatelessWidget {
  final List<String> precautions;

  const _PrecautionsCard({required this.precautions});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: context.t('precautionsTitle'),
      icon: Icons.shield_outlined,
      color: Colors.indigo,
      child: Column(
        children: [
          for (final p in precautions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
