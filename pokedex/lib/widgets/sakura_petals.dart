import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Capa decorativa sutil: los pétalos se generan con un CustomPainter.
class SakuraPetals extends StatefulWidget {
  const SakuraPetals({super.key});
  @override
  State<SakuraPetals> createState() => _SakuraPetalsState();
}

class _SakuraPetalsState extends State<SakuraPetals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        painter: _PetalsPainter(_controller.value),
        size: Size.infinite,
      ),
    ),
  );
}

class _PetalsPainter extends CustomPainter {
  _PetalsPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x99FFFFFF);
    for (var i = 0; i < 18; i++) {
      final seed = i * 37.0;
      final x = (seed * 1.73) % size.width;
      final y =
          ((seed * 2.41 + progress * (size.height + 100)) %
              (size.height + 100)) -
          50;
      canvas.save();
      canvas.translate(x + math.sin(progress * 2 * math.pi + i) * 18, y);
      canvas.rotate(progress * math.pi + i);
      final path = Path()
        ..moveTo(0, -5)
        ..quadraticBezierTo(8, -2, 5, 5)
        ..quadraticBezierTo(0, 8, -5, 5)
        ..quadraticBezierTo(-8, -2, 0, -5);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
