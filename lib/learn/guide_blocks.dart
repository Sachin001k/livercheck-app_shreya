import 'package:flutter/material.dart';

import '../app_language.dart';
import '../survey/health_ui.dart';
import '../theme.dart';
import 'guide_content.dart';
import 'guide_store.dart';
import 'guide_tools.dart';

/// Draws one [GuideBlock]. [color] is the chapter colour; [userId] is used
/// by the interactive tools to save per user.
class GuideBlockView extends StatelessWidget {
  final GuideBlock block;
  final Color color;
  final String userId;

  const GuideBlockView({
    super.key,
    required this.block,
    required this.color,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      TextBlock(:final key) => Text(
        context.t(key),
        style: const TextStyle(fontSize: 15.5, height: 1.45),
      ),
      KeyBlock b => _KeyMessage(b, color),
      CardsBlock b => _Cards(b, color),
      CompareBlock b => _Compare(b),
      StagesBlock b => _Stages(b),
      InfoBlock b => InfoBox(b),
      AgeBlock b => _AgeAdvice(b),
      TestsBlock b => _Tests(b),
      SwapsBlock b => _Swaps(b),
      MythsBlock b => _Myths(b),
      FaqBlock b => GuideFaq(b),
      StepsBlock b => GuideSteps(b, color: color),
      SourcesBlock b => _Sources(b),
      ChecklistBlock b => RiskChecklist(b),
      ToolBlock(:final tool) => switch (tool) {
        GuideTool.challenge => ChallengeTool(userId: userId),
        GuideTool.plan => PlanTool(userId: userId),
      },
    };
  }
}

// ---------------------------------------------------------------- helpers

/// Rounded square with an emoji on a tinted background.
class EmojiBadge extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;

  const EmojiBadge(
    this.emoji, {
    super.key,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// Section heading inside a topic.
class GuideHeading extends StatelessWidget {
  final String text;
  const GuideHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
    ),
  );
}

/// Bold title + optional body, used by most item rows.
class _TitleBody extends StatelessWidget {
  final String title;
  final String? body;
  final Color? titleColor;

  const _TitleBody(this.title, this.body, {this.titleColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: titleColor,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 3),
          Text(
            body!,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// A row: emoji badge + title/body.
class GuideItemRow extends StatelessWidget {
  final GuideItem item;
  final Color color;

  const GuideItemRow(this.item, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    // A plain bullet (no icon) for title-only "•" items.
    if (item.emoji == '•') {
      return _Bullet(context.t(item.titleKey), color: color);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmojiBadge(item.emoji, color: item.color ?? color, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _TitleBody(
              context.t(item.titleKey),
              item.bodyKey == null ? null : context.t(item.bodyKey!),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Bullet(this.text, {required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 10),
          child: icon != null
              ? Icon(icon, size: 18, color: color)
              : Padding(
                  padding: const EdgeInsets.only(top: 5, left: 4, right: 2),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14.5, height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Lays out [children] two per row when there is room, else one per row.
class _TwoUp extends StatelessWidget {
  final List<Widget> children;
  final double minWidth;

  const _TwoUp(this.children, {this.minWidth = 520});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final two = c.maxWidth >= minWidth;
        final w = two ? (c.maxWidth - 12) / 2 : c.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: w, child: child),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- blocks

class _KeyMessage extends StatelessWidget {
  final KeyBlock b;
  final Color color;
  const _KeyMessage(this.b, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(b.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('gd_keyMessage').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.t(b.key),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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

class _Cards extends StatelessWidget {
  final CardsBlock b;
  final Color color;
  const _Cards(this.b, this.color);

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final i in b.items)
        SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: GuideItemRow(i, color: color),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b.titleKey != null) GuideHeading(context.t(b.titleKey!)),
        if (b.introKey != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              context.t(b.introKey!),
              style: const TextStyle(fontSize: 14.5),
            ),
          ),
        if (b.grid)
          _TwoUp(cards, minWidth: 480)
        else
          for (final (n, c) in cards.indexed) ...[
            if (n > 0) const SizedBox(height: 10),
            c,
          ],
      ],
    );
  }
}

class _Compare extends StatelessWidget {
  final CompareBlock b;
  const _Compare(this.b);

  Widget _side(BuildContext context, CompareSide s, bool good) {
    final c = good ? kLow : kHigh;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // A simple liver-coloured blob: red-brown when healthy,
              // yellowish when fatty (the animation comes later).
              Container(
                width: 44,
                height: 30,
                decoration: BoxDecoration(
                  color: good
                      ? const Color(0xFFC9655A)
                      : const Color(0xFFE8C15A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t(s.titleKey),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: c,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.t(s.bodyKey),
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
          const SizedBox(height: 10),
          for (final p in s.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _Bullet(
                context.t(p),
                color: c,
                icon: good ? Icons.check_circle : Icons.error,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TwoUp([_side(context, b.good, true), _side(context, b.bad, false)]);
  }
}

class _Stages extends StatelessWidget {
  final StagesBlock b;
  const _Stages(this.b);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b.titleKey != null) GuideHeading(context.t(b.titleKey!)),
        for (final (n, i) in b.items.indexed) ...[
          if (n > 0)
            b.arrows
                ? Icon(Icons.arrow_downward_rounded, color: i.color ?? tealDark)
                : const SizedBox(height: 10),
          _StageCard(i),
        ],
      ],
    );
  }
}

class _StageCard extends StatelessWidget {
  final GuideItem i;
  const _StageCard(this.i);

  @override
  Widget build(BuildContext context) {
    final c = i.color ?? tealDark;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: c,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmojiBadge(i.emoji, color: c, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TitleBody(
                            context.t(i.titleKey),
                            i.bodyKey == null ? null : context.t(i.bodyKey!),
                            titleColor: c == kMod ? kModDark : c,
                          ),
                          if (i.noteKey != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '🔑 ${context.t(i.noteKey!)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
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

/// Colours for each [GuideTone]: (background, accent).
(Color, Color) toneColors(GuideTone tone) => switch (tone) {
  GuideTone.info => (const Color(0xFFEEF4FD), const Color(0xFF2F5FA8)),
  GuideTone.good => (const Color(0xFFEAF6EF), const Color(0xFF2E7350)),
  GuideTone.warn => (const Color(0xFFFFF5E2), kModDark),
  GuideTone.urgent => (const Color(0xFFFDECEA), const Color(0xFFB3261E)),
};

class InfoBox extends StatelessWidget {
  final InfoBlock b;

  /// Values for `{name}` placeholders in the title and body.
  final Map<String, Object?> args;
  const InfoBox(this.b, {super.key, this.args = const {}});

  @override
  Widget build(BuildContext context) {
    final (bg, accent) = toneColors(b.tone);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tf(b.titleKey, args),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          if (b.bodyKey != null) ...[
            const SizedBox(height: 8),
            Text(
              context.tf(b.bodyKey!, args),
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
          ],
          for (final k in b.bullets) ...[
            const SizedBox(height: 8),
            _Bullet(context.t(k), color: accent),
          ],
          for (final i in b.items) ...[
            const SizedBox(height: 12),
            GuideItemRow(i, color: accent),
          ],
        ],
      ),
    );
  }
}

/// Chips to switch the age group (shared by every page).
class AgeGroupChips extends StatelessWidget {
  const AgeGroupChips({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: guideAgeGroup,
      builder: (context, selected, _) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final g in AgeGroup.values)
            ChoiceChip(
              selected: g == selected,
              onSelected: (_) => guideAgeGroup.value = g,
              avatar: Text(g.emoji),
              label: Text(context.t(g.shortKey)),
              showCheckmark: false,
              selectedColor: g.color.withValues(alpha: 0.18),
              side: BorderSide(color: g == selected ? g.color : Colors.black12),
              labelStyle: TextStyle(
                fontWeight: g == selected ? FontWeight.w800 : FontWeight.w500,
                color: g == selected ? g.color : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _AgeAdvice extends StatelessWidget {
  final AgeBlock b;
  const _AgeAdvice(this.b);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: guideAgeGroup,
      builder: (context, g, _) {
        final items = b.items[g] ?? const [];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: g.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: g.color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(b.titleKey),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: g.color,
                ),
              ),
              const SizedBox(height: 10),
              const AgeGroupChips(),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  key: ValueKey(g),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (n, i) in items.indexed) ...[
                      if (n > 0) const SizedBox(height: 12),
                      GuideItemRow(i, color: g.color),
                    ],
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

class _Tests extends StatelessWidget {
  final TestsBlock b;
  const _Tests(this.b);

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget label(String key, Color c) => Text(
      context.t(key).toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w800,
        color: c,
      ),
    );
    return Column(
      children: [
        for (final i in b.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmojiBadge(i.emoji, color: const Color(0xFF2F6FD6), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t(i.titleKey),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        label('gd_measures', const Color(0xFF1F7A6E)),
                        Text(
                          context.t(i.bodyKey!),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        label('gd_limits', const Color(0xFF7B57C2)),
                        Text(
                          context.t(i.noteKey!),
                          style: TextStyle(fontSize: 14, color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Swaps extends StatelessWidget {
  final SwapsBlock b;
  const _Swaps(this.b);

  Widget _cell(BuildContext context, GuideItem i, Color c) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: c.withValues(alpha: 0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(i.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          context.t(i.titleKey),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        if (i.bodyKey != null)
          Text(
            context.t(i.bodyKey!),
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    Widget head(String key, Color c) => Expanded(
      child: Text(
        context.t(key),
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800, color: c),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            head('gd_chooseLess', kHigh),
            const SizedBox(width: 28),
            head('gd_tryInstead', kLow),
          ],
        ),
        const SizedBox(height: 8),
        for (final (a, c) in b.swaps)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _cell(context, a, kHigh)),
                  const SizedBox(
                    width: 28,
                    child: Icon(Icons.arrow_forward_rounded, color: kLow),
                  ),
                  Expanded(child: _cell(context, c, kLow)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Myths extends StatelessWidget {
  final MythsBlock b;
  const _Myths(this.b);

  @override
  Widget build(BuildContext context) {
    Widget part(GuideItem i, bool myth) {
      final c = myth ? kHigh : kLow;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        color: c.withValues(alpha: myth ? 0.07 : 0.09),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  myth ? Icons.cancel : Icons.check_circle,
                  color: c,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  context.t(myth ? 'gd_myth' : 'gd_fact').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: c,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _TitleBody(context.t(i.titleKey), context.t(i.bodyKey!)),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final (m, f) in b.pairs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(children: [part(m, true), part(f, false)]),
              ),
            ),
          ),
      ],
    );
  }
}

/// FAQ grouped by age, the reader's group first and open.
class GuideFaq extends StatelessWidget {
  final FaqBlock b;

  /// Only the chosen age group (Home shows a short version).
  final bool onlySelected;

  const GuideFaq(this.b, {super.key, this.onlySelected = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: guideAgeGroup,
      builder: (context, g, _) {
        final groups = [
          g,
          ...AgeGroup.values.where((x) => x != g && !onlySelected),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!onlySelected) ...[
              const AgeGroupChips(),
              const SizedBox(height: 12),
            ],
            for (final group in groups) ...[
              if (!onlySelected)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Text(
                    '${group.emoji}  ${context.t(group.labelKey)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: group.color,
                    ),
                  ),
                ),
              SurfaceCard(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    for (final (n, q)
                        in (b.items[group] ?? const <GuideItem>[]).indexed)
                      ExpansionTile(
                        key: PageStorageKey('${group.name}-$n'),
                        shape: const Border(),
                        initiallyExpanded:
                            group == g && n == 0 && !onlySelected,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: group.color.withValues(alpha: 0.15),
                          child: Text(
                            'Q',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: group.color,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          context.t(q.titleKey),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t(q.bodyKey!),
                            style: const TextStyle(height: 1.4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Numbered steps (assessment pathway, 5 steps).
class GuideSteps extends StatelessWidget {
  final StepsBlock b;
  final Color color;
  const GuideSteps(this.b, {super.key, required this.color});

  static const _stepColors = [
    Color(0xFF3E8E4F),
    Color(0xFF2F6FD6),
    Color(0xFFB7791F),
    Color(0xFFD6455D),
    Color(0xFF7B57C2),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b.titleKey != null) GuideHeading(context.t(b.titleKey!)),
        for (final (n, i) in b.items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _stepColors[n % _stepColors.length],
                    child: Text(
                      '${n + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TitleBody(
                      '${i.emoji}  ${context.t(i.titleKey)}',
                      i.bodyKey == null ? null : context.t(i.bodyKey!),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Sources extends StatelessWidget {
  final SourcesBlock b;
  const _Sources(this.b);

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (n, k) in b.refs.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              b.refs.length > 1 ? '${n + 1}. ${context.t(k)}' : context.t(k),
              style: TextStyle(fontSize: 12.5, color: muted, height: 1.35),
            ),
          ),
      ],
    );
  }
}
