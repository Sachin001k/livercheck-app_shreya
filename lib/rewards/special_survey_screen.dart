import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_language.dart';
import '../services/auth_service.dart';
import '../survey/health_ui.dart';
import 'reward_store.dart';

/// Answers one special survey and claims its coins.
class SpecialSurveyScreen extends StatefulWidget {
  final SpecialSurvey survey;

  const SpecialSurveyScreen({super.key, required this.survey});

  @override
  State<SpecialSurveyScreen> createState() => _SpecialSurveyScreenState();
}

class _SpecialSurveyScreenState extends State<SpecialSurveyScreen> {
  final Map<String, dynamic> _answers = {};
  bool _saving = false;
  bool _done = false;
  String? _error;

  bool _answered(SurveyQuestion q) {
    final a = _answers[q.id];
    if (a == null) return false;
    if (a is String) return a.trim().isNotEmpty;
    if (a is List) return a.isNotEmpty;
    return true;
  }

  bool get _complete => widget.survey.questions.every(_answered);

  Future<void> _submit() async {
    if (!_complete) {
      setState(() => _error = context.t('surveyAnswerAll'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final coins = await RewardStore.submitSpecialSurvey(
        widget.survey,
        _answers,
      );
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _done = true);
      await showDialog<void>(
        context: context,
        builder: (_) => _RewardDialog(coins: coins),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = AuthService.describeError(e, context.t('genericError'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = widget.survey;
    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                SurfaceCard(
                  child: Row(
                    children: [
                      const Text('📣', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (s.description != null) Text(s.description!),
                            const SizedBox(height: 4),
                            Text(
                              '${context.t('surveyEarn')} 🪙 ${s.rewardCoins} · '
                              '${s.questions.length} questions',
                              style: TextStyle(
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final (i, q) in s.questions.indexed) ...[
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${i + 1}. ${q.title}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _input(q, cs),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: kHigh)),
                  ),
                _done
                    ? const SizedBox(
                        height: 56,
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            color: kLow,
                            size: 40,
                          ),
                        ),
                      )
                    : _saving
                    ? const SizedBox(
                        height: 56,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : BigButton(
                        label:
                            '${context.t('surveySubmit')}  ·  +${s.rewardCoins} 🪙',
                        onPressed: _complete ? _submit : null,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(SurveyQuestion q, ColorScheme cs) {
    switch (q.type) {
      case 'text':
        return TextField(
          maxLines: 3,
          onChanged: (v) => setState(() => _answers[q.id] = v),
          decoration: InputDecoration(
            hintText: context.t('surveyTypeAnswer'),
            border: const OutlineInputBorder(),
          ),
        );
      case 'scale':
        final value = _answers[q.id] as int?;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var n = 1; n <= 5; n++)
              ChoiceChip(
                label: Text('$n'),
                selected: value == n,
                onSelected: (_) => setState(() => _answers[q.id] = n),
              ),
          ],
        );
      case 'multi':
        final picked = List<String>.from(_answers[q.id] as List? ?? const []);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in q.options)
              FilterChip(
                label: Text('${o.emoji} ${o.label}'.trim()),
                selected: picked.contains(o.v),
                onSelected: (on) => setState(() {
                  on ? picked.add(o.v) : picked.remove(o.v);
                  _answers[q.id] = picked;
                }),
              ),
          ],
        );
      default: // 'choice'
        return Column(
          children: [
            for (final o in q.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: _answers[q.id] == o.v
                      ? cs.primaryContainer
                      : cs.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _answers[q.id] == o.v
                          ? cs.primary
                          : cs.outlineVariant,
                    ),
                  ),
                  child: ListTile(
                    leading: o.emoji.isEmpty
                        ? null
                        : Text(o.emoji, style: const TextStyle(fontSize: 22)),
                    title: Text(o.label),
                    trailing: _answers[q.id] == o.v
                        ? Icon(Icons.check_circle, color: cs.primary)
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _answers[q.id] = o.v);
                    },
                  ),
                ),
              ),
          ],
        );
    }
  }
}

/// "+N coins" celebration: the coin pops in, the number counts up.
class _RewardDialog extends StatelessWidget {
  final int coins;

  const _RewardDialog({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(
                scale: v,
                child: Transform.rotate(angle: (1 - v) * 1.5, child: child),
              ),
              child: Container(
                width: 110,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Text('🪙', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 18),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: coins.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, _) => Text(
                '+${v.round()}',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
            Text(
              context.t('surveyCoinsAdded'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('surveyThanks'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Collect',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
