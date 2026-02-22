import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A starry-sky gradient background used across all screens.
class GradientBackground extends StatefulWidget {
  final Widget child;
  final bool showStars;

  const GradientBackground({
    super.key,
    required this.child,
    this.showStars = true,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimary,
            AppColors.bgSecondary,
            AppColors.bgPrimary,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: widget.showStars
          ? Stack(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _StarPainter(
                      animationValue: _controller.value,
                    ),
                    size: Size.infinite,
                  ),
                ),
                widget.child,
              ],
            )
          : widget.child,
    );
  }
}

class _StarPainter extends CustomPainter {
  final double animationValue;
  static final List<_Star> _stars = _generateStars(60);

  _StarPainter({required this.animationValue});

  static List<_Star> _generateStars(int count) {
    final rng = Random(42);
    return List.generate(count, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 1.5 + 0.5,
        phase: rng.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final opacity =
          0.3 + 0.7 * ((sin(animationValue * 2 * pi + star.phase) + 1) / 2);
      final paint = Paint()
        ..color = AppColors.textPrimary.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.animationValue != animationValue;
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double phase;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
  });
}
