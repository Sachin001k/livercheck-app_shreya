import 'package:flutter/material.dart';

import '../survey/health_ui.dart';
import '../theme.dart';
import 'meal_catalog.dart';

/// Opens the meal picker. Returns the picked foods ({id: portions}), or
/// null if the user closed it without saving.
Future<Map<String, int>?> showMealPicker(
  BuildContext context, {
  Map<String, int> initial = const {},
  required int targetKcal,
}) {
  return showModalBottomSheet<Map<String, int>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => _MealPicker(
        initial: initial,
        targetKcal: targetKcal,
        scrollController: controller,
      ),
    ),
  );
}

class _MealPicker extends StatefulWidget {
  final Map<String, int> initial;
  final int targetKcal;
  final ScrollController scrollController;

  const _MealPicker({
    required this.initial,
    required this.targetKcal,
    required this.scrollController,
  });

  @override
  State<_MealPicker> createState() => _MealPickerState();
}

class _MealPickerState extends State<_MealPicker> {
  late final Map<String, int> _picked = {...widget.initial};
  String _query = '';

  void _change(MealFood food, int delta) {
    setState(() {
      final next = (_picked[food.id] ?? 0) + delta;
      if (next <= 0) {
        _picked.remove(food.id);
      } else {
        _picked[food.id] = next.clamp(0, 20);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totals = mealTotals(_picked);
    final q = _query.trim().toLowerCase();
    final shown = mealFoods
        .where((f) => q.isEmpty || f.name.toLowerCase().contains(q))
        .toList();
    final ratio = totals.kcal / widget.targetKcal;

    return Column(
      children: [
        // Running total.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'What did you eat today?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: totals.kcal.toDouble()),
                duration: const Duration(milliseconds: 400),
                builder: (_, v, _) => Text(
                  '${v.round()} kcal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ratio > 1.1 ? kHigh : tealDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: ratio.clamp(0, 1).toDouble()),
                duration: const Duration(milliseconds: 400),
                builder: (_, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    color: ratio > 1.1
                        ? kHigh
                        : ratio >= 0.9
                        ? kLow
                        : tealLight,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Goal about ${widget.targetKcal} kcal',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (totals.items > 0)
                    Text(
                      '${totals.items} item${totals.items == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search foods',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  fillColor: cs.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              for (final category in MealCategory.values)
                if (shown.any((f) => f.category == category)) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                    child: Text(
                      mealCategoryLabels[category]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final food in shown.where(
                          (f) => f.category == category,
                        ))
                          _FoodRow(
                            food: food,
                            count: _picked[food.id] ?? 0,
                            onChange: (d) => _change(food, d),
                          ),
                      ],
                    ),
                  ),
                ],
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No food called "$_query" yet. Pick the closest one.',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                if (_picked.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_picked.clear),
                    child: const Text('Clear'),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: BigButton(
                    label: _picked.isEmpty
                        ? 'Pick at least one food'
                        : 'Use ${totals.kcal} kcal',
                    onPressed: _picked.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_picked),
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

class _FoodRow extends StatelessWidget {
  final MealFood food;
  final int count;
  final ValueChanged<int> onChange;

  const _FoodRow({
    required this.food,
    required this.count,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final picked = count > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: picked
          ? cs.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(food.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${food.portion} · ${food.kcal} kcal',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, a) =>
                ScaleTransition(scale: a, child: child),
            child: picked
                ? IconButton(
                    key: const ValueKey('minus'),
                    tooltip: 'Less ${food.name}',
                    onPressed: () => onChange(-1),
                    icon: const Icon(Icons.remove_circle_outline),
                  )
                : const SizedBox(width: 48, key: ValueKey('none')),
          ),
          SizedBox(
            width: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                picked ? '$count' : '',
                key: ValueKey(count),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'More ${food.name}',
            onPressed: () => onChange(1),
            icon: Icon(Icons.add_circle, color: tealDark),
          ),
        ],
      ),
    );
  }
}
