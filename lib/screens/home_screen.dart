import 'package:flutter/material.dart';

import '../app_language.dart';
import '../daily/daily_checkin_card.dart';
import '../data/home_content.dart' hide AgeGroup;
import '../learn/guide_blocks.dart';
import '../learn/guide_content.dart';
import '../learn/learn_screen.dart';
import '../survey/health_ui.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/tab_back.dart';
import '../widgets/home_extras.dart';
import 'food_detail_sheet.dart';

/// Home tab: the health check and today's check-in side by side, then the
/// guide card, food cards (dummy data, lib/data/home_content.dart), the
/// guidebook's 5 steps and FAQ.
class HomeScreen extends StatefulWidget {
  final Profile profile;
  final VoidCallback onStartCheck;

  /// Opens the Guide tab (hidden when null, e.g. in tests).
  final VoidCallback? onOpenGuide;

  /// Whether Home is the tab on screen (for Android back handling).
  final bool isActive;

  /// Lets Android back close the daily log before leaving Home.
  final TabBack? back;

  const HomeScreen({
    super.key,
    required this.profile,
    required this.onStartCheck,
    this.onOpenGuide,
    this.isActive = true,
    this.back,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keep both cards' state (an unsaved log, meal picks) when the layout
  // switches between stacked and side by side (rotation, split screen).
  final _checkKey = GlobalKey();
  final _dailyKey = GlobalKey<DailyCheckinCardState>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profile = widget.profile;
    final firstName = (profile.fullName ?? '').trim().split(' ').first;

    return RefreshIndicator(
      // Reloads every card that listens for saved data, and waits for the
      // daily card's reload so the spinner stops when it is done.
      onRefresh: () async {
        DataService.changes.value++;
        await _dailyKey.currentState?.latestLoad;
      },
      child: ListView(
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SpecialSurveyBanner(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Side by side on wide screens, stacked on phones.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final check = _CheckCard(
                  key: _checkKey,
                  onStart: widget.onStartCheck,
                );
                final daily = DailyCheckinCard(
                  key: _dailyKey,
                  profile: profile,
                  isActive: widget.isActive,
                  back: widget.back,
                );
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TipOfTheDayCard(),
          ),
          if (widget.onOpenGuide != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _GuideCard(onOpen: widget.onOpenGuide!),
            ),
          _SectionTitle(context.t('foodSectionTitle')),
          SizedBox(
            // Grows with the phone's text size so card text isn't cut off.
            height:
                210 *
                (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
                  1.0,
                  1.7,
                ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: foodTips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _FoodCard(tip: foodTips[i]),
            ),
          ),
          _SectionTitle(context.t('gd_homeStepsTitle')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GuideSteps(StepsBlock(fiveSteps), color: tealDark),
          ),
          _SectionTitle(context.t('faqSectionTitle')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The guidebook FAQ for the chosen age group.
                GuideFaq(
                  FaqBlock({for (final g in AgeGroup.values) g: faqFor(g)}),
                  onlySelected: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => openGuideTopic(context, profile.id, 'faq'),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(context.t('gd_homeFaqMore')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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

  const _CheckCard({super.key, required this.onStart});

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
    final organs = [
      '🍃 ${context.t('hm_ptLiver')}',
      '❤️ ${context.t('hm_ptHeart')}',
      '🫘 ${context.t('hm_ptKidneys')}',
      '🫁 ${context.t('hm_organLungs')}',
      '🍬 ${context.t('hm_organSugar')}',
    ];
    // A minimum (not fixed) height: the card matches the daily check-in
    // card beside it, but grows instead of overflowing with long
    // translations or large text. IntrinsicHeight lets the 🩺 area
    // (Expanded) fill whatever room is left.
    return Container(
      constraints: BoxConstraints(minHeight: dailyCardHeight(context)),
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
      child: IntrinsicHeight(
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
                // Own layer: the 🩺 bobs every frame, and without this the
                // whole card (gradient + blurred shadow) repaints with it,
                // which makes scrolling past it stutter.
                child: RepaintBoundary(
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
                  context.t(tip.nameKey),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    context.t(tip.whyKey),
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

/// Opens the Guide tab (the liver guidebook).
class _GuideCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _GuideCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const EmojiBadge('📖', color: Color(0xFF2F6FD6), size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('gd_homeCardTitle'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t('gd_homeCardBody'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: tealDark),
            ],
          ),
        ),
      ),
    );
  }
}
