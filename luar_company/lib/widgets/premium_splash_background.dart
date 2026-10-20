import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Fundo premium do fluxo de arranque (splash e welcome).
///
/// Gradiente navy + orbes douradas com brilho suave que flutuam
/// devagar, garantindo um aspeto coerente entre os dois ecrãs.
class PremiumSplashBackground extends StatefulWidget {
  const PremiumSplashBackground({super.key, required this.child});

  final Widget child;

  @override
  State<PremiumSplashBackground> createState() =>
      _PremiumSplashBackgroundState();
}

class _PremiumSplashBackgroundState extends State<PremiumSplashBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) =>
                  CustomPaint(painter: _OrbsPainter(_controller.value)),
            ),
          ),
          RepaintBoundary(child: widget.child),
        ],
      ),
    );
  }
}

class _OrbsPainter extends CustomPainter {
  const _OrbsPainter(this.progress);

  final double progress;

  static const List<_Orb> _orbs = [
    _Orb(
      color: AppColors.goldLight,
      radiusFactor: 0.28,
      opacity: 0.16,
      centerX: 0.85,
      centerY: 0.12,
      driftX: 0.05,
      driftY: 0.07,
      speed: 1.0,
      phase: 0.0,
    ),
    _Orb(
      color: AppColors.gold,
      radiusFactor: 0.22,
      opacity: 0.10,
      centerX: 0.12,
      centerY: 0.78,
      driftX: 0.06,
      driftY: 0.05,
      speed: 0.7,
      phase: 1.7,
    ),
    _Orb(
      color: AppColors.navyLight,
      radiusFactor: 0.34,
      opacity: 0.20,
      centerX: 0.5,
      centerY: 0.45,
      driftX: 0.08,
      driftY: 0.04,
      speed: 0.5,
      phase: 3.1,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * 2 * math.pi;

    for (final orb in _orbs) {
      final radius = size.shortestSide * orb.radiusFactor;
      final dx =
          (orb.centerX + math.sin(angle * orb.speed + orb.phase) * orb.driftX) *
          size.width;
      final dy =
          (orb.centerY + math.cos(angle * orb.speed + orb.phase) * orb.driftY) *
          size.height;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withValues(alpha: orb.opacity),
            orb.color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Orb {
  const _Orb({
    required this.color,
    required this.radiusFactor,
    required this.opacity,
    required this.centerX,
    required this.centerY,
    required this.driftX,
    required this.driftY,
    required this.speed,
    required this.phase,
  });

  final Color color;
  final double radiusFactor;
  final double opacity;
  final double centerX;
  final double centerY;
  final double driftX;
  final double driftY;
  final double speed;
  final double phase;
}
