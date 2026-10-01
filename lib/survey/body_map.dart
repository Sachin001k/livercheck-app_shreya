import 'package:flutter/material.dart';
import 'assess.dart';
import 'health_ui.dart';

// Tappable body outline with 5 organs, drawn in a 200 x 270 coordinate space.

Path _oval(double cx, double cy, double w, double h) =>
    Path()..addOval(Rect.fromCenter(center: Offset(cx, cy), width: w, height: h));

final Map<String, Path> organPaths = {
  'lungs': _oval(78, 112, 34, 60)..addPath(_oval(122, 112, 34, 60), Offset.zero),
  'heart': Path()
    ..moveTo(106, 110)
    ..cubicTo(112, 102, 124, 106, 122, 116)
    ..cubicTo(120, 125, 110, 131, 106, 135)
    ..cubicTo(102, 131, 92, 125, 90, 116)
    ..cubicTo(88, 106, 100, 102, 106, 110)
    ..close(),
  'liver': Path()
    ..moveTo(60, 152)
    ..cubicTo(62, 141, 90, 139, 118, 143)
    ..cubicTo(127, 145, 125, 153, 116, 157)
    ..cubicTo(100, 165, 80, 173, 67, 171)
    ..cubicTo(59, 167, 56, 158, 60, 152)
    ..close(),
  'pancreas': Path()
    ..moveTo(94, 178)
    ..cubicTo(104, 171, 126, 171, 135, 175)
    ..cubicTo(137, 180, 128, 183, 118, 183)
    ..cubicTo(108, 183, 100, 184, 94, 181)
    ..close(),
  'kidneys': _oval(78, 206, 18, 28)..addPath(_oval(122, 206, 18, 28), Offset.zero),
};

const _drawOrder = ['lungs', 'heart', 'liver', 'pancreas', 'kidneys'];

final Path _body = Path()
  ..addOval(Rect.fromCircle(center: const Offset(100, 34), radius: 21))
  ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(90, 50, 20, 14), const Radius.circular(4)))
  ..addPath(
      Path()
        ..moveTo(66, 62)
        ..quadraticBezierTo(100, 55, 134, 62)
        ..lineTo(152, 78)
        ..quadraticBezierTo(162, 92, 160, 132)
        ..lineTo(154, 232)
        ..quadraticBezierTo(151, 252, 130, 258)
        ..lineTo(70, 258)
        ..quadraticBezierTo(49, 252, 46, 232)
        ..lineTo(40, 132)
        ..quadraticBezierTo(38, 92, 48, 78)
        ..close(),
      Offset.zero);

class BodyMap extends StatelessWidget {
  final Map<String, OrganResult>? organs; // null = grey preview
  final String? selected;
  final ValueChanged<String>? onTap;
  const BodyMap({super.key, this.organs, this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 200 / 270,
      child: LayoutBuilder(builder: (ctx, c) {
        final scale = c.maxWidth / 200;
        return GestureDetector(
          onTapDown: onTap == null
              ? null
              : (d) {
                  final p = d.localPosition / scale;
                  for (final k in _drawOrder.reversed) {
                    if (organPaths[k]!.contains(p)) {
                      onTap!(k);
                      return;
                    }
                  }
                },
          child: CustomPaint(
            size: Size(c.maxWidth, c.maxHeight),
            painter: _BodyPainter(
              organs: organs,
              selected: selected,
              bodyColor: cs.surfaceContainerHighest,
              mutedColor: cs.onSurfaceVariant,
              outline: cs.onSurface,
            ),
          ),
        );
      }),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final Map<String, OrganResult>? organs;
  final String? selected;
  final Color bodyColor, mutedColor, outline;
  _BodyPainter({this.organs, this.selected, required this.bodyColor, required this.mutedColor, required this.outline});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200);
    canvas.drawPath(_body, Paint()..color = bodyColor);
    for (final k in _drawOrder) {
      final path = organPaths[k]!;
      final color = organs == null ? mutedColor.withAlpha(70) : levelColor(organs![k]!.level);
      canvas.drawPath(path, Paint()..color = color);
      if (k == selected) {
        canvas.drawPath(path, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = outline);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) => true;
}
