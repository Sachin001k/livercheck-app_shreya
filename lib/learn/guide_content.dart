import 'package:flutter/material.dart';

/// The liver guide (Guide tab), following the LivrCheck fatty liver
/// guidebook chapter by chapter. Every text is a translation key; the
/// English text lives in `translations/en_guide.dart`.
///
/// A topic is a list of [GuideBlock]s, drawn by `topic_screen.dart`.

// ------------------------------------------------------------ age groups

/// The guidebook's three audiences.
enum AgeGroup {
  children('gd_ageChildren', 'gd_ageChildrenShort', '🧒', Color(0xFF3E8E4F)),
  adults('gd_ageAdults', 'gd_ageAdultsShort', '🧑', Color(0xFF2F6FD6)),
  older('gd_ageOlder', 'gd_ageOlderShort', '🧓', Color(0xFF7B57C2));

  final String labelKey;
  final String shortKey;
  final String emoji;
  final Color color;

  const AgeGroup(this.labelKey, this.shortKey, this.emoji, this.color);
}

/// Children under 18, older adults 65+, adults otherwise (and when the age
/// is unknown).
AgeGroup ageGroupFor(int? age) {
  if (age == null) return AgeGroup.adults;
  if (age < 18) return AgeGroup.children;
  if (age >= 65) return AgeGroup.older;
  return AgeGroup.adults;
}

// ---------------------------------------------------------------- model

/// An icon + title (+ body, + note). Bodies and notes are optional.
class GuideItem {
  final String emoji;
  final String titleKey;
  final String? bodyKey;
  final String? noteKey;
  final Color? color;

  const GuideItem(
    this.emoji,
    this.titleKey, {
    this.bodyKey,
    this.noteKey,
    this.color,
  });

  Iterable<String> get keys => [titleKey, ?bodyKey, ?noteKey];
}

/// Item from a key stem: `gd_lm1` → title `gd_lm1T`, body `gd_lm1B`
/// (and note `gd_lm1N` when [note]).
GuideItem _i(
  String emoji,
  String stem, {
  bool body = true,
  bool note = false,
  Color? color,
}) => GuideItem(
  emoji,
  '${stem}T',
  bodyKey: body ? '${stem}B' : null,
  noteKey: note ? '${stem}N' : null,
  color: color,
);

/// Title-only item (a bullet).
GuideItem _b(String key, [String emoji = '•']) => GuideItem(emoji, key);

/// Colour of an information box.
enum GuideTone { info, good, warn, urgent }

sealed class GuideBlock {
  const GuideBlock();

  /// Every translation key the block uses (checked by a test).
  Iterable<String> get keys;
}

/// A plain paragraph.
class TextBlock extends GuideBlock {
  final String key;
  const TextBlock(this.key);
  @override
  Iterable<String> get keys => [key];
}

/// The guidebook's "key message" banner.
class KeyBlock extends GuideBlock {
  final String key;
  final String emoji;
  const KeyBlock(this.key, {this.emoji = '🔑'});
  @override
  Iterable<String> get keys => [key];
}

/// A list of icon cards, with an optional heading and intro.
class CardsBlock extends GuideBlock {
  final String? titleKey;
  final String? introKey;
  final List<GuideItem> items;

  /// Two cards per row on wide enough screens.
  final bool grid;
  const CardsBlock(
    this.items, {
    this.titleKey,
    this.introKey,
    this.grid = false,
  });
  @override
  Iterable<String> get keys => [
    ?titleKey,
    ?introKey,
    for (final i in items) ...i.keys,
  ];
}

/// Healthy vs unhealthy, side by side (stacked on phones).
class CompareBlock extends GuideBlock {
  final CompareSide good;
  final CompareSide bad;
  const CompareBlock(this.good, this.bad);
  @override
  Iterable<String> get keys => [...good.keys, ...bad.keys];
}

class CompareSide {
  final String emoji;
  final String titleKey;
  final String bodyKey;
  final List<String> points;
  const CompareSide(this.emoji, this.titleKey, this.bodyKey, this.points);
  Iterable<String> get keys => [titleKey, bodyKey, ...points];
}

/// Coloured steps joined by arrows (disease stages, FIB-4 ranges, types).
class StagesBlock extends GuideBlock {
  final String? titleKey;
  final List<GuideItem> items;

  /// Draws a ↓ between items (a progression), or just spacing.
  final bool arrows;
  const StagesBlock(this.items, {this.titleKey, this.arrows = true});
  @override
  Iterable<String> get keys => [?titleKey, for (final i in items) ...i.keys];
}

/// Coloured box: title, optional text, bullets and/or icon items.
class InfoBlock extends GuideBlock {
  final String emoji;
  final String titleKey;
  final String? bodyKey;
  final List<String> bullets;
  final List<GuideItem> items;
  final GuideTone tone;
  const InfoBlock(
    this.emoji,
    this.titleKey, {
    this.bodyKey,
    this.bullets = const [],
    this.items = const [],
    this.tone = GuideTone.info,
  });
  @override
  Iterable<String> get keys => [
    titleKey,
    ?bodyKey,
    ...bullets,
    for (final i in items) ...i.keys,
  ];
}

/// Advice for each age group; shows the chosen group (switchable).
class AgeBlock extends GuideBlock {
  final String titleKey;
  final Map<AgeGroup, List<GuideItem>> items;
  const AgeBlock(this.items, {this.titleKey = 'gd_forAge'});
  @override
  Iterable<String> get keys => [
    titleKey,
    for (final list in items.values)
      for (final i in list) ...i.keys,
  ];
}

/// Test → what it measures → limitations (title / body / note per item).
class TestsBlock extends GuideBlock {
  final List<GuideItem> items;
  const TestsBlock(this.items);
  @override
  Iterable<String> get keys => [
    'gd_measures',
    'gd_limits',
    for (final i in items) ...i.keys,
  ];
}

/// "Choose less often" → "Try instead".
class SwapsBlock extends GuideBlock {
  final List<(GuideItem, GuideItem)> swaps;
  const SwapsBlock(this.swaps);
  @override
  Iterable<String> get keys => [
    'gd_chooseLess',
    'gd_tryInstead',
    for (final (a, b) in swaps) ...[...a.keys, ...b.keys],
  ];
}

/// Myth / fact pairs.
class MythsBlock extends GuideBlock {
  final List<(GuideItem, GuideItem)> pairs;
  const MythsBlock(this.pairs);
  @override
  Iterable<String> get keys => [
    'gd_myth',
    'gd_fact',
    for (final (a, b) in pairs) ...[...a.keys, ...b.keys],
  ];
}

/// Questions and answers, grouped by age (your group first).
class FaqBlock extends GuideBlock {
  final Map<AgeGroup, List<GuideItem>> items;
  const FaqBlock(this.items);
  @override
  Iterable<String> get keys => [
    for (final list in items.values)
      for (final i in list) ...i.keys,
  ];
}

/// Numbered steps.
class StepsBlock extends GuideBlock {
  final String? titleKey;
  final List<GuideItem> items;
  const StepsBlock(this.items, {this.titleKey});
  @override
  Iterable<String> get keys => [?titleKey, for (final i in items) ...i.keys];
}

/// Small print: sources and references.
class SourcesBlock extends GuideBlock {
  final List<String> refs;
  const SourcesBlock(this.refs);
  @override
  Iterable<String> get keys => refs;
}

/// Tick-box risk checklist for the chosen age group.
class ChecklistBlock extends GuideBlock {
  final Map<AgeGroup, List<String>> questions;
  final Map<AgeGroup, String> notes;
  const ChecklistBlock(this.questions, {this.notes = const {}});
  @override
  Iterable<String> get keys => [
    'gd_ckNone',
    'gd_ckResult',
    for (final list in questions.values) ...list,
    ...notes.values,
  ];
}

/// Interactive tools from chapter 5.
enum GuideTool { challenge, plan }

class ToolBlock extends GuideBlock {
  final GuideTool tool;
  const ToolBlock(this.tool);
  @override
  Iterable<String> get keys => const [];
}

class GuideTopic {
  final String id;
  final String emoji;
  final String titleKey;
  final List<GuideBlock> blocks;
  const GuideTopic(this.id, this.emoji, this.titleKey, this.blocks);
}

class GuideChapter {
  final int number;
  final String emoji;
  final String titleKey;
  final String bodyKey;
  final Color color;
  final List<GuideTopic> topics;
  const GuideChapter(
    this.number,
    this.emoji,
    this.titleKey,
    this.bodyKey,
    this.color,
    this.topics,
  );
}

// --------------------------------------------------------------- colours

const _cLiver = Color(0xFF2F6FD6);
const _cRisk = Color(0xFF3E8E4F);
const _cCheck = Color(0xFFB7791F);
const _cAction = Color(0xFF7B57C2);
const _cPlan = Color(0xFFD6455D);
const _cHelp = Color(0xFF1F7A6E);

const _green = Color(0xFF3E8E6B);
const _amber = Color(0xFFD99A2B);
const _orange = Color(0xFFE07A2E);
const _red = Color(0xFFC4513A);
const _purple = Color(0xFF7B57C2);
const _blue = Color(0xFF2F6FD6);

// --------------------------------------------------------------- content

/// "In practice" age advice where each group is a list of bullet keys.
Map<AgeGroup, List<GuideItem>> _ages(
  List<String> children,
  List<String> adults,
  List<String> older,
) => {
  AgeGroup.children: [for (final k in children) _b(k)],
  AgeGroup.adults: [for (final k in adults) _b(k)],
  AgeGroup.older: [for (final k in older) _b(k)],
};

final List<GuideChapter> guideChapters = [
  // ======================================================= 1. KNOW YOUR LIVER
  GuideChapter(1, '🍃', 'gd_c1T', 'gd_c1B', _cLiver, [
    GuideTopic('liver-matters', '💪', 'gd_lmT', [
      const TextBlock('gd_lmIntro'),
      CardsBlock(grid: true, [
        _i('🍴', 'gd_lm1'),
        _i('⚡', 'gd_lm2'),
        _i('💧', 'gd_lm3'),
        _i('🛡️', 'gd_lm4'),
        _i('🗄️', 'gd_lm5'),
        _i('🧬', 'gd_lm6'),
      ]),
      AgeBlock(_ages(['gd_lmC'], ['gd_lmA'], ['gd_lmO'])),
      const KeyBlock('gd_lmKey', emoji: '⏱️'),
    ]),
    GuideTopic('what-is-fatty-liver', '🔍', 'gd_flT', [
      const TextBlock('gd_flIntro'),
      const InfoBlock('❓', 'gd_flNormalT', bodyKey: 'gd_flNormalB'),
      const CompareBlock(
        CompareSide('🟥', 'gd_flGoodT', 'gd_flGoodB', [
          'gd_flGood1',
          'gd_flGood2',
          'gd_flGood3',
        ]),
        CompareSide('🟨', 'gd_flBadT', 'gd_flBadB', [
          'gd_flBad1',
          'gd_flBad2',
          'gd_flBad3',
          'gd_flBad4',
        ]),
      ),
      AgeBlock(_ages(['gd_flC'], ['gd_flA'], ['gd_flO'])),
      const KeyBlock('gd_flKey', emoji: '🌍'),
      const SourcesBlock(['gd_flSrc']),
    ]),
    GuideTopic('types', '🗂️', 'gd_tyT', [
      const InfoBlock('❓', 'gd_tyWhyT', bodyKey: 'gd_tyWhyB'),
      StagesBlock(arrows: false, [
        _i('1️⃣', 'gd_ty1', note: true, color: _green),
        _i('2️⃣', 'gd_ty2', note: true, color: _orange),
        _i('3️⃣', 'gd_ty3', note: true, color: _blue),
        _i('4️⃣', 'gd_ty4', note: true, color: _purple),
      ]),
      AgeBlock(_ages(['gd_tyC'], ['gd_tyA'], ['gd_tyO'])),
      const KeyBlock('gd_tyKey', emoji: '🩺'),
    ]),
    GuideTopic('stages', '📉', 'gd_stT', [
      const TextBlock('gd_stIntro'),
      StagesBlock([
        _i('🟡', 'gd_st1', color: _amber),
        _i('🟠', 'gd_st2', color: _orange),
        _i('🟤', 'gd_st3', color: _red),
        _i('🟣', 'gd_st4', color: _purple),
      ]),
      const InfoBlock(
        'ℹ️',
        'gd_stDiffT',
        bullets: ['gd_stDiff1', 'gd_stDiff2'],
      ),
      const InfoBlock(
        '🔄',
        'gd_stSeqT',
        bullets: ['gd_stSeq1', 'gd_stSeq2', 'gd_stSeq3', 'gd_stSeq4'],
        tone: GuideTone.good,
      ),
      const TextBlock('gd_stAll'),
      const KeyBlock('gd_stKey', emoji: '📋'),
    ]),
  ]),

  // ======================================================== 2. KNOW YOUR RISK
  GuideChapter(2, '⚖️', 'gd_c2T', 'gd_c2B', _cRisk, [
    GuideTopic('who-is-at-risk', '👥', 'gd_rkT', [
      const TextBlock('gd_rkIntro'),
      AgeBlock({
        AgeGroup.children: [
          _i('👪', 'gd_rkC1', body: false),
          _i('⚖️', 'gd_rkC2'),
          _i('🏃', 'gd_rkC3'),
          _i('😴', 'gd_rkC4'),
        ],
        AgeGroup.adults: [
          _i('🩸', 'gd_rkA1', body: false),
          _i('📏', 'gd_rkA2'),
          _i('❤️', 'gd_rkA3', body: false),
          _i('💤', 'gd_rkA4'),
        ],
        AgeGroup.older: [
          _i('🩸', 'gd_rkA1', body: false),
          GuideItem('⚙️', 'gd_rkO2T', bodyKey: 'gd_rkC2B'),
          _i('❤️', 'gd_rkA3', body: false),
          _i('🛏️', 'gd_rkO4'),
        ],
      }),
      const InfoBlock('🧍', 'gd_rkLeanT', bodyKey: 'gd_rkLeanB'),
      const InfoBlock(
        '🇮🇳',
        'gd_rkSaT',
        bodyKey: 'gd_rkSaB',
        bullets: ['gd_rkSa1', 'gd_rkSa2'],
        tone: GuideTone.warn,
      ),
      const KeyBlock('gd_rkKey', emoji: '📏'),
    ]),
    GuideTopic('checklist', '✅', 'gd_ckT', [
      const TextBlock('gd_ckIntro'),
      const ChecklistBlock(
        {
          AgeGroup.children: [
            'gd_ckC1',
            'gd_ckC2',
            'gd_ckC3',
            'gd_ckC4',
            'gd_ckC5',
          ],
          AgeGroup.adults: [
            'gd_ckA1',
            'gd_ckA2',
            'gd_ckA3',
            'gd_ckA4',
            'gd_ckA5',
            'gd_ckA6',
          ],
          AgeGroup.older: [
            'gd_ckO1',
            'gd_ckO2',
            'gd_ckO3',
            'gd_ckO4',
            'gd_ckO5',
          ],
        },
        notes: {AgeGroup.children: 'gd_ckCNote'},
      ),
      const KeyBlock('gd_ckKey', emoji: '🩺'),
    ]),
    GuideTopic('symptoms', '🤒', 'gd_syT', [
      const TextBlock('gd_syIntro'),
      CardsBlock(titleKey: 'gd_syEarlyT', introKey: 'gd_syEarlyB', [
        _i('😩', 'gd_sy1'),
        _i('🤕', 'gd_sy2'),
        _i('😔', 'gd_sy3'),
      ]),
      InfoBlock(
        '⚠️',
        'gd_syLateT',
        bodyKey: 'gd_syLateB',
        items: [_i('👁️', 'gd_sy4'), _i('🦵', 'gd_sy5')],
        tone: GuideTone.warn,
      ),
      AgeBlock(
        _ages(['gd_syC1', 'gd_syC2'], ['gd_syA1', 'gd_syA2'], [
          'gd_syO1',
          'gd_syO2',
        ]),
      ),
      const InfoBlock(
        '⚖️',
        'gd_syWeightT',
        bodyKey: 'gd_syWeightB',
        tone: GuideTone.urgent,
      ),
    ]),
    GuideTopic('see-a-doctor', '👩‍⚕️', 'gd_drT', [
      const TextBlock('gd_drIntro'),
      InfoBlock(
        '📅',
        'gd_drApptT',
        items: [
          _i('🙍', 'gd_dr1'),
          _i('🧪', 'gd_dr2'),
          _i('📋', 'gd_dr3'),
          _i('❓', 'gd_dr4'),
        ],
        tone: GuideTone.good,
      ),
      InfoBlock(
        '🚨',
        'gd_drUrgentT',
        items: [
          _i('🩸', 'gd_dr5'),
          _i('⚫', 'gd_dr6'),
          _i('😵', 'gd_dr7'),
          _i('💉', 'gd_dr8'),
          _i('⏫', 'gd_dr9'),
        ],
        tone: GuideTone.urgent,
      ),
      AgeBlock(
        _ages(['gd_drC1', 'gd_drC2'], ['gd_drA1', 'gd_drA2'], [
          'gd_drO1',
          'gd_drO2',
        ]),
      ),
      const KeyBlock('gd_drKey', emoji: '⏳'),
    ]),
  ]),

  // =========================================================== 3. GET CHECKED
  GuideChapter(3, '🧪', 'gd_c3T', 'gd_c3B', _cCheck, [
    GuideTopic('detection', '🔬', 'gd_dtT', [
      const TextBlock('gd_dtIntro'),
      StepsBlock(titleKey: 'gd_dtPathT', [
        _i('📋', 'gd_dt1'),
        _i('🩺', 'gd_dt2'),
        _i('🧪', 'gd_dt3'),
        _i('🖥️', 'gd_dt4'),
      ]),
      AgeBlock({
        AgeGroup.children: [
          _i('📋', 'gd_dtC1'),
          _i('📏', 'gd_dtC2'),
          _i('🧪', 'gd_dtC3'),
        ],
        AgeGroup.adults: [
          _i('🩸', 'gd_dtA1'),
          _i('🧪', 'gd_dtA2'),
          _i('📊', 'gd_dtA3'),
        ],
        AgeGroup.older: [
          _i('🩸', 'gd_dtA1'),
          _i('🧪', 'gd_dtA2'),
          _i('💊', 'gd_dtO3'),
        ],
      }),
      const KeyBlock('gd_dtKey', emoji: '🎯'),
    ]),
    GuideTopic('fib4', '🧮', 'gd_f4T', [
      const TextBlock('gd_f4Intro'),
      CardsBlock(grid: true, titleKey: 'gd_f4InT', [
        _i('📅', 'gd_f4In1'),
        _i('🧪', 'gd_f4In2'),
        _i('🧪', 'gd_f4In3'),
        _i('🔴', 'gd_f4In4'),
      ]),
      StagesBlock(titleKey: 'gd_f4ResT', arrows: false, [
        GuideItem('✅', 'gd_f4LowT', bodyKey: 'gd_f4LowB', color: _green),
        GuideItem('❔', 'gd_f4MidT', bodyKey: 'gd_f4MidB', color: _amber),
        GuideItem('❗', 'gd_f4HighT', bodyKey: 'gd_f4HighB', color: _red),
      ]),
      AgeBlock(_ages(['gd_f4C'], ['gd_f4A'], ['gd_f4O'])),
      const InfoBlock(
        '⚠️',
        'gd_f4LimT',
        bodyKey: 'gd_f4LimB',
        tone: GuideTone.warn,
      ),
      const KeyBlock('gd_f4Key', emoji: '🩺'),
    ]),
    GuideTopic('test-results', '📄', 'gd_tsT', [
      const TextBlock('gd_tsIntro'),
      TestsBlock([
        _i('🩸', 'gd_ts1', note: true),
        _i('🍬', 'gd_ts2', note: true),
        _i('🖥️', 'gd_ts3', note: true),
        _i('📡', 'gd_ts4', note: true),
        _i('🟡', 'gd_ts5', note: true),
        _i('🧲', 'gd_ts6', note: true),
        _i('💉', 'gd_ts7', note: true),
      ]),
      AgeBlock(_ages(['gd_tsC'], ['gd_tsA'], ['gd_tsO'])),
      const KeyBlock('gd_tsKey', emoji: '⚠️'),
    ]),
    GuideTopic('after-testing', '➡️', 'gd_afT', [
      const TextBlock('gd_afIntro'),
      AgeBlock({
        AgeGroup.children: [
          _i('🩺', 'gd_afC1', body: false),
          _i('🧪', 'gd_afC2'),
          _i('👩‍⚕️', 'gd_afC3'),
        ],
        AgeGroup.adults: [
          _i('🔍', 'gd_afA1'),
          _i('🖥️', 'gd_afA2'),
          _i('📅', 'gd_afA3'),
        ],
        AgeGroup.older: [
          _i('📋', 'gd_afO1'),
          _i('🖥️', 'gd_afO2'),
          _i('🔄', 'gd_afO3'),
        ],
      }),
      const InfoBlock(
        '💬',
        'gd_afAskT',
        bullets: [
          'gd_afAsk1',
          'gd_afAsk2',
          'gd_afAsk3',
          'gd_afAsk4',
          'gd_afAsk5',
        ],
        tone: GuideTone.good,
      ),
      const InfoBlock('🏥', 'gd_afSpecT', bodyKey: 'gd_afSpecB'),
    ]),
    GuideTopic('follow-up', '📅', 'gd_fuT', [
      const TextBlock('gd_fuIntro'),
      AgeBlock({
        for (final (g, s) in [
          (AgeGroup.children, 'C'),
          (AgeGroup.adults, 'A'),
          (AgeGroup.older, 'O'),
        ])
          g: [
            GuideItem('🔬', 'gd_fuWhatT', bodyKey: 'gd_fu${s}What'),
            GuideItem('👩‍⚕️', 'gd_fuWhoT', bodyKey: 'gd_fu${s}Who'),
            GuideItem('📅', 'gd_fuWhenT', bodyKey: 'gd_fu${s}When'),
          ],
      }),
      const InfoBlock('🗒️', 'gd_fuRecT', bodyKey: 'gd_fuRecB'),
      const KeyBlock('gd_fuKey', emoji: '🔍'),
    ]),
  ]),

  // ========================================================== 4. TAKE ACTION
  GuideChapter(4, '🏃', 'gd_c4T', 'gd_c4B', _cAction, [
    GuideTopic('food', '🍽️', 'gd_fdT', [
      const KeyBlock('gd_fdKeyTop', emoji: '🥗'),
      CardsBlock([_i('🥦', 'gd_fd1'), _i('🌾', 'gd_fd2'), _i('🍳', 'gd_fd3')]),
      const InfoBlock(
        '🇮🇳',
        'gd_fdIndT',
        bullets: [
          'gd_fdInd1',
          'gd_fdInd2',
          'gd_fdInd3',
          'gd_fdInd4',
          'gd_fdInd5',
        ],
        tone: GuideTone.good,
      ),
      AgeBlock(
        _ages(['gd_fdC1', 'gd_fdC2'], ['gd_fdA1', 'gd_fdA2', 'gd_fdA3'], [
          'gd_fdO1',
          'gd_fdO2',
        ]),
      ),
      const KeyBlock('gd_fdKey', emoji: '💧'),
    ]),
    GuideTopic('limit', '🚫', 'gd_ltT', [
      const TextBlock('gd_ltIntro'),
      SwapsBlock([
        (_i('🥤', 'gd_lt1'), _i('💧', 'gd_lt1s')),
        (_i('🧃', 'gd_lt2'), _i('🍎', 'gd_lt2s')),
        (_i('🥟', 'gd_lt3'), _i('🫘', 'gd_lt3s')),
        (_i('🍔', 'gd_lt4'), _i('🍛', 'gd_lt4s')),
      ]),
      AgeBlock(
        _ages(['gd_ltC1', 'gd_ltC2'], ['gd_ltA1', 'gd_ltA2'], [
          'gd_ltO1',
          'gd_ltO2',
        ]),
      ),
      const KeyBlock('gd_ltKey', emoji: '🎯'),
    ]),
    GuideTopic('activity', '🚶', 'gd_acT', [
      const TextBlock('gd_acIntro'),
      AgeBlock({
        AgeGroup.children: [
          _i('⚽', 'gd_acC1', body: false),
          _i('⏱️', 'gd_acC2', body: false),
        ],
        AgeGroup.adults: [
          _i('🚴', 'gd_acA1', body: false),
          _i('⏱️', 'gd_acA2'),
          _i('🏋️', 'gd_acA3', body: false),
        ],
        AgeGroup.older: [
          _i('🚶', 'gd_acO1', body: false),
          _i('⏱️', 'gd_acO2', body: false),
          _i('🏋️', 'gd_acO3', body: false),
        ],
      }),
      const InfoBlock('🛡️', 'gd_acSafeT', bodyKey: 'gd_acSafeB'),
      const SourcesBlock(['gd_acSrc1', 'gd_acSrc2']),
    ]),
    GuideTopic('sleep', '😴', 'gd_slT', [
      const TextBlock('gd_slIntro'),
      AgeBlock({
        AgeGroup.children: [
          _i('🛏️', 'gd_slC1'),
          _i('📺', 'gd_slC2'),
          _i('🌙', 'gd_slC3'),
        ],
        AgeGroup.adults: [
          _i('🛏️', 'gd_slA1'),
          _i('🚶', 'gd_slA2'),
          _i('😮‍💨', 'gd_slA3'),
        ],
        AgeGroup.older: [
          _i('🛏️', 'gd_slO1'),
          _i('🚶', 'gd_slO2'),
          _i('🩺', 'gd_slO3'),
        ],
      }),
      CardsBlock(titleKey: 'gd_slHabT', [
        _b('gd_slHab1', '📵'),
        _b('gd_slHab2', '🌳'),
        _b('gd_slHab3', '🗓️'),
      ]),
      const InfoBlock(
        '7️⃣',
        'gd_slChT',
        bodyKey: 'gd_slChB',
        tone: GuideTone.good,
      ),
    ]),
    GuideTopic('weight', '⚖️', 'gd_wtT', [
      const TextBlock('gd_wtIntro'),
      AgeBlock({
        AgeGroup.children: [
          _b('gd_wtC1', '📏'),
          _b('gd_wtC2', '🥗'),
          _b('gd_wtC3', '🏃'),
          _b('gd_wtC4', '🩺'),
        ],
        AgeGroup.adults: [_b('gd_wtA1', '📋'), _b('gd_wtA2', '📉')],
        AgeGroup.older: [
          _b('gd_wtO1', '💪'),
          _b('gd_wtO2', '🥚'),
          _b('gd_wtO3', '🦯'),
          _b('gd_wtO4', '🩺'),
        ],
      }),
      const InfoBlock(
        '🚫',
        'gd_wtCrashT',
        bodyKey: 'gd_wtCrashB',
        tone: GuideTone.urgent,
      ),
    ]),
    GuideTopic('metabolic', '🩸', 'gd_mbT', [
      const TextBlock('gd_mbIntro'),
      CardsBlock([_i('🩸', 'gd_mb1'), _i('🧈', 'gd_mb2'), _i('❤️', 'gd_mb3')]),
      AgeBlock(_ages(['gd_mbC'], ['gd_mbA'], ['gd_mbO'])),
    ]),
    GuideTopic('medicines', '💊', 'gd_mdT', [
      const TextBlock('gd_mdIntro'),
      CardsBlock(titleKey: 'gd_mdOverT', [
        _i('🥗', 'gd_md1'),
        _i('🩸', 'gd_md2'),
        _i('💊', 'gd_md3'),
      ]),
      AgeBlock(_ages(['gd_mdC1', 'gd_mdC2'], ['gd_mdA'], ['gd_mdO'])),
      const InfoBlock(
        '⛔',
        'gd_mdSelfT',
        bodyKey: 'gd_mdSelfB',
        tone: GuideTone.urgent,
      ),
    ]),
  ]),

  // ================================================ 5. YOUR LIVER HEALTH PLAN
  GuideChapter(5, '📝', 'gd_c5T', 'gd_c5B', _cPlan, [
    const GuideTopic('challenge', '🗓️', 'gd_chT', [
      TextBlock('gd_chIntro'),
      ToolBlock(GuideTool.challenge),
      InfoBlock(
        '💡',
        'gd_rememberT',
        bodyKey: 'gd_rememberB',
        tone: GuideTone.good,
      ),
    ]),
    GuideTopic('action-plan', '🎯', 'gd_plT', [
      const TextBlock('gd_plIntro'),
      const ToolBlock(GuideTool.plan),
      CardsBlock(titleKey: 'gd_plTipsT', [
        _i('✅', 'gd_plTip1'),
        _i('📈', 'gd_plTip2'),
        _i('🗓️', 'gd_plTip3'),
        _i('🔄', 'gd_plTip4'),
        _i('👥', 'gd_plTip5'),
      ]),
      const InfoBlock(
        '💡',
        'gd_plExT',
        bullets: ['gd_plEx1', 'gd_plEx2', 'gd_plEx3', 'gd_plEx4', 'gd_plEx5'],
        tone: GuideTone.warn,
      ),
      const InfoBlock(
        '❗',
        'gd_rememberT',
        bodyKey: 'gd_rememberB',
        tone: GuideTone.urgent,
      ),
    ]),
    GuideTopic('myths', '🤔', 'gd_myT', [
      const TextBlock('gd_myIntro'),
      MythsBlock([
        for (var n = 1; n <= 6; n++)
          (_i('❌', 'gd_my$n'), _i('✅', 'gd_my${n}f')),
      ]),
      const KeyBlock('gd_myKey', emoji: '💡'),
    ]),
    GuideTopic('faq', '❓', 'gd_fqT', [
      const TextBlock('gd_fqIntro'),
      FaqBlock({
        AgeGroup.children: [for (var n = 1; n <= 3; n++) _i('❓', 'gd_fqC$n')],
        AgeGroup.adults: [for (var n = 1; n <= 3; n++) _i('❓', 'gd_fqA$n')],
        AgeGroup.older: [for (var n = 1; n <= 3; n++) _i('❓', 'gd_fqO$n')],
      }),
      const InfoBlock(
        '❗',
        'gd_fqNoteT',
        bodyKey: 'gd_fqNoteB',
        tone: GuideTone.urgent,
      ),
    ]),
    GuideTopic('five-steps', '🖐️', 'gd_5sT', [
      const TextBlock('gd_5sIntro'),
      StepsBlock(fiveSteps),
      AgeBlock(
        titleKey: 'gd_5sInPractice',
        _ages(
          ['gd_5sC1', 'gd_5sC2', 'gd_5sC3'],
          ['gd_5sA1', 'gd_5sA2', 'gd_5sA3'],
          ['gd_5sO1', 'gd_5sO2', 'gd_5sO3'],
        ),
      ),
      const KeyBlock('gd_5sKey', emoji: '💚'),
    ]),
  ]),

  // ====================================================== 6. WHERE TO GET HELP
  GuideChapter(6, '🏥', 'gd_c6T', 'gd_c6B', _cHelp, [
    GuideTopic('get-help', '🩺', 'gd_hpT', [
      const TextBlock('gd_hpIntro'),
      const InfoBlock(
        '❗',
        'gd_hpWhenT',
        bullets: ['gd_hpWhen1', 'gd_hpWhen2', 'gd_hpWhen3'],
        tone: GuideTone.warn,
      ),
      AgeBlock(_ages(['gd_hpC'], ['gd_hpA'], ['gd_hpO'])),
      const KeyBlock('gd_hpKey', emoji: '🙌'),
    ]),
    const GuideTopic('references', '📚', 'gd_rfT', [
      SourcesBlock([
        'gd_rf1',
        'gd_rf2',
        'gd_rf3',
        'gd_rf4',
        'gd_rf5',
        'gd_rf6',
      ]),
    ]),
  ]),
];

/// "Remember these 5 steps" — also shown on Home.
final List<GuideItem> fiveSteps = [
  _i('📋', 'gd_5s1'),
  _i('📅', 'gd_5s2'),
  _i('🏥', 'gd_5s3'),
  _i('🥗', 'gd_5s4'),
  _i('⛰️', 'gd_5s5'),
];

/// The guidebook FAQ for one age group — Home shows the user's three.
List<GuideItem> faqFor(AgeGroup group) => guideChapters
    .expand((c) => c.topics)
    .expand((t) => t.blocks)
    .whereType<FaqBlock>()
    .first
    .items[group]!;

/// Finds a topic and its chapter by id (for links from Home).
(GuideChapter, GuideTopic)? findTopic(String id) {
  for (final c in guideChapters) {
    for (final t in c.topics) {
      if (t.id == id) return (c, t);
    }
  }
  return null;
}

/// Tip of the day on Home: the 5 steps, then the 6 facts.
final List<GuideItem> guideTips = [
  ...fiveSteps,
  for (var n = 1; n <= 6; n++) _i('💡', 'gd_my${n}f'),
];

/// The 7-day challenge habits (guidebook p. 21).
final List<GuideItem> challengeHabits = [
  _i('💧', 'gd_ch1'),
  _i('🥗', 'gd_ch2'),
  _i('🍎', 'gd_ch3'),
  _i('🍔', 'gd_ch4'),
  _i('🚶', 'gd_ch5'),
  _i('🪑', 'gd_ch6'),
  _i('😴', 'gd_ch7'),
  _i('💊', 'gd_ch8'),
];

/// The personal action plan fields (guidebook p. 22): title + hint keys.
const List<(String emoji, String titleKey, String hintKey)> planFields = [
  ('🎯', 'gd_pl1T', 'gd_pl1H'),
  ('🥗', 'gd_pl2T', 'gd_pl2H'),
  ('👟', 'gd_pl3T', 'gd_pl3H'),
  ('🚫', 'gd_pl4T', 'gd_pl4H'),
  ('🩺', 'gd_pl5T', 'gd_pl5H'),
  ('👥', 'gd_pl6T', 'gd_pl6H'),
];
