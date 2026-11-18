import 'package:flutter/material.dart';

import '../app_language.dart';
import '../services/data_service.dart';
import '../survey/health_ui.dart';
import '../theme.dart';
import 'guide_blocks.dart';
import 'guide_content.dart';

/// Opens a guide topic (from Home or anywhere else).
void openGuideTopic(BuildContext context, String userId, String topicId) {
  final found = findTopic(topicId);
  if (found == null) return;
  final (chapter, topic) = found;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TopicScreen(
        chapter: chapter,
        index: chapter.topics.indexOf(topic),
        userId: userId,
      ),
    ),
  );
}

/// Guide tab: the guidebook's chapters, with an age-group switch.
/// The age group starts from the profile age (set by MainShell).
class LearnScreen extends StatelessWidget {
  final Profile profile;
  const LearnScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const _Hero(),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('gd_showFor'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const AgeGroupChips(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final c in guideChapters)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChapterCard(
              chapter: c,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChapterScreen(chapter: c, userId: profile.id),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const InfoBox(
          InfoBlock(
            '❗',
            'gd_important',
            bodyKey: 'gd_disclaimer',
            tone: GuideTone.urgent,
          ),
        ),
        const SizedBox(height: 12),
        const InfoBox(InfoBlock('🩺', 'gd_tabTitle', bodyKey: 'gd_reviewed')),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D3F8A), tealDark],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('gd_heroTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('gd_heroSub'),
                  style: const TextStyle(
                    color: Color(0xFFBFF0E6),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('gd_heroBody'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('📖', style: TextStyle(fontSize: 54)),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final GuideChapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = chapter.color;
    return Material(
      color: c.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: c,
                child: Text(
                  '${chapter.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${chapter.emoji}  ${context.t(chapter.titleKey)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.t(chapter.bodyKey),
                      style: const TextStyle(fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tf('gd_topics', {'n': chapter.topics.length}),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a pushed guide page: tinted app bar, width capped like the tabs.
class _GuidePage extends StatelessWidget {
  final GuideChapter chapter;
  final String title;
  final Widget child;

  const _GuidePage({
    required this.chapter,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Color.alphaBlend(
          chapter.color.withValues(alpha: 0.12),
          Theme.of(context).colorScheme.surface,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// One chapter: its topics, numbered like the guidebook.
class ChapterScreen extends StatelessWidget {
  final GuideChapter chapter;
  final String userId;

  const ChapterScreen({super.key, required this.chapter, required this.userId});

  @override
  Widget build(BuildContext context) {
    final c = chapter.color;
    return _GuidePage(
      chapter: chapter,
      title: context.tf('gd_chapter', {'n': chapter.number}),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            '${chapter.emoji}  ${context.t(chapter.titleKey)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: c,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t(chapter.bodyKey),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 18),
          for (final (n, t) in chapter.topics.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: EmojiBadge(t.emoji, color: c),
                  title: Text(
                    context.t(t.titleKey),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  subtitle: Text(
                    '${chapter.number}.${n + 1}',
                    style: TextStyle(color: c, fontWeight: FontWeight.w700),
                  ),
                  trailing: Icon(Icons.chevron_right, color: c),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TopicScreen(
                        chapter: chapter,
                        index: n,
                        userId: userId,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One topic page, with "Next" to the following topic in the chapter.
class TopicScreen extends StatelessWidget {
  final GuideChapter chapter;
  final int index;
  final String userId;

  const TopicScreen({
    super.key,
    required this.chapter,
    required this.index,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final topic = chapter.topics[index];
    final next = index + 1 < chapter.topics.length
        ? chapter.topics[index + 1]
        : null;
    final c = chapter.color;
    return _GuidePage(
      chapter: chapter,
      title: context.t(chapter.titleKey),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Row(
            children: [
              EmojiBadge(topic.emoji, color: c, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${chapter.number}.${index + 1} · ${context.t(chapter.titleKey).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t(topic.titleKey),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final b in topic.blocks) ...[
            GuideBlockView(block: b, color: c, userId: userId),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          if (next != null)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: c,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TopicScreen(
                    chapter: chapter,
                    index: index + 1,
                    userId: userId,
                  ),
                ),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                context.tf('gd_next', {'title': context.t(next.titleKey)}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.t('gd_backToChapter')),
            ),
        ],
      ),
    );
  }
}
