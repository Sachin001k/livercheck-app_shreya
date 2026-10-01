import 'package:flutter/material.dart';

/// Shimmering placeholder shown while content loads, shaped like the
/// content that is coming (instead of a bare spinner).
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const Skeleton({super.key, this.width, required this.height, this.radius = 12});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final light = Theme.of(context).colorScheme.surfaceContainerLowest;
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, _) {
        final t = _shimmer.value * 3 - 1; // sweep from left to right
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
              colors: [base, light, base],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

/// A few skeleton cards stacked, for list-style screens.
class SkeletonList extends StatelessWidget {
  final List<double> heights;

  const SkeletonList({super.key, this.heights = const [120, 160, 90, 200]});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final h in heights) ...[
        Skeleton(height: h, radius: 20),
        const SizedBox(height: 16),
      ],
    ]);
  }
}
