import 'package:flutter/material.dart';

import '../app_language.dart';
import '../theme.dart';

class _Slide {
  final String emoji, titleKey, bodyKey;

  /// Small chips under the text, e.g. the organs checked.
  final List<String> chips;

  const _Slide(
    this.emoji,
    this.titleKey,
    this.bodyKey, [
    this.chips = const [],
  ]);
}

const _slides = [
  _Slide('🩺', 'welcome1Title', 'welcome1Body', [
    '🍃 Liver',
    '❤️ Heart',
    '🫘 Kidneys',
    '🫁 Lungs',
    '🍬 Sugar',
  ]),
  _Slide('📅', 'welcome2Title', 'welcome2Body', [
    '💧 Water',
    '🍽️ Food',
    '🏃 Exercise',
    '😴 Sleep',
  ]),
  _Slide('🪙', 'welcome3Title', 'welcome3Body', [
    '👋 +1',
    '📝 +10',
    '🎯 +20',
    '🔥 Streak',
  ]),
  _Slide('🔒', 'welcome4Title', 'welcome4Body'),
];

/// First-launch slides shown before the login screen.
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onDone;

  const WelcomeScreen({super.key, required this.onDone});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _pages = PageController();
  int _page = 0;
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
    _pages.dispose();
    _float.dispose();
    super.dispose();
  }

  bool get _last => _page == _slides.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: tealGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const LanguageDropdown(
                          textColor: Colors.white,
                          dropdownColor: tealDark,
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: _last ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: TextButton(
                            onPressed: _last ? null : widget.onDone,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: Text(context.t('welcomeSkip')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: _slides.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) =>
                          _SlideView(slide: _slides[i], float: _float),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: i == _page ? 1 : 0.4,
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: tealDark,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            context.t(_last ? 'welcomeStart' : 'welcomeNext'),
                            key: ValueKey(_last),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  final Animation<double> float;

  const _SlideView({required this.slide, required this.float});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Emoji pops in when the slide appears, then floats gently.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: AnimatedBuilder(
              animation: float,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  0,
                  -10 * Curves.easeInOut.transform(float.value),
                ),
                child: child,
              ),
              child: Container(
                width: 168,
                height: 168,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.12),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Text(slide.emoji, style: const TextStyle(fontSize: 84)),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            context.t(slide.titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.t(slide.bodyKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          if (slide.chips.isNotEmpty) ...[
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in slide.chips)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
