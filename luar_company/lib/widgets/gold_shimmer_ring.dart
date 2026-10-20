import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Anel dourado com varredura de brilho (shimmer) à volta de um conteúdo
/// com o mesmo border radius (tipicamente o logo do arranque).
class GoldShimmerRing extends StatefulWidget {
  const GoldShimmerRing({
    super.key,
    required this.size,
    required this.child,
    this.radius = 28,
    this.borderWidth = 2,
  });

  final double size;
  final Widget child;
  final double radius;
  final double borderWidth;

  @override
  State<GoldShimmerRing> createState() => _GoldShimmerRingState();
}

class _GoldShimmerRingState extends State<GoldShimmerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: widget.child,
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(
                  progress: _controller.value,
                  radius: widget.radius,
                  borderWidth: widget.borderWidth,
                  repaint: _controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.radius,
    required this.borderWidth,
    super.repaint,
  });

  final double progress;
  final double radius;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final start = progress * 2 * math.pi;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: [
          AppColors.goldDark.withValues(alpha: 0.35),
          AppColors.goldLight,
          AppColors.gold,
          AppColors.goldDark.withValues(alpha: 0.35),
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.radius != radius ||
      oldDelegate.borderWidth != borderWidth;
}
