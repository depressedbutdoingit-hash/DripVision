import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GalaxyBackground extends StatefulWidget {
  final Widget child;
  const GalaxyBackground({super.key, required this.child});

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaController;
  late AnimationController _pulseController;

  final List<_Star> _stars = [];
  final List<_Nebula> _nebulae = [];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _generateStars();
    _generateNebulae();
  }

  void _generateStars() {
    final random = Random();
    for (int i = 0; i < 150; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.5 + 0.5,
        opacity: random.nextDouble() * 0.8 + 0.2,
        speed: random.nextDouble() * 0.3 + 0.1,
        twinkleSpeed: random.nextDouble() * 3 + 1,
      ));
    }
  }

  void _generateNebulae() {
    final random = Random();
    for (int i = 0; i < 5; i++) {
      _nebulae.add(_Nebula(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 200 + 100,
        color: [
          DripTheme.cosmicTeal.withOpacity(0.15),
          DripTheme.nebulaCyan.withOpacity(0.1),
          const Color(0xFF6C5CE7).withOpacity(0.08),
          const Color(0xFF00B894).withOpacity(0.12),
        ][random.nextInt(4)],
        driftX: (random.nextDouble() - 0.5) * 0.02,
        driftY: (random.nextDouble() - 0.5) * 0.02,
      ));
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _nebulaController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF02040A),
                Color(0xFF0A1628),
                Color(0xFF0D1B2A),
                Color(0xFF02040A),
              ],
            ),
          ),
        ),
        // Animated nebulae
        AnimatedBuilder(
          animation: _nebulaController,
          builder: (context, child) {
            return CustomPaint(
              painter: _NebulaPainter(
                nebulae: _nebulae,
                animation: _nebulaController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Animated stars
        AnimatedBuilder(
          animation: _starController,
          builder: (context, child) {
            return CustomPaint(
              painter: _StarFieldPainter(
                stars: _stars,
                animation: _starController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Shooting stars
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ShootingStarPainter(
                animation: _pulseController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;
  final double twinkleSpeed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.twinkleSpeed,
  });
}

class _Nebula {
  final double x;
  final double y;
  final double radius;
  final Color color;
  final double driftX;
  final double driftY;

  _Nebula({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.driftX,
    required this.driftY,
  });
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double animation;

  _StarFieldPainter({required this.stars, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = sin(animation * pi * 2 * star.twinkleSpeed) * 0.3 + 0.7;
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );

      // Glow for larger stars
      if (star.size > 1.8) {
        final glowPaint = Paint()
          ..color = DripTheme.cosmicTeal.withOpacity(0.15 * twinkle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.size * 4,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NebulaPainter extends CustomPainter {
  final List<_Nebula> nebulae;
  final double animation;

  _NebulaPainter({required this.nebulae, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final nebula in nebulae) {
      final offsetX = sin(animation * 2 * pi) * nebula.driftX * size.width;
      final offsetY = cos(animation * 2 * pi) * nebula.driftY * size.height;

      final paint = Paint()
        ..color = nebula.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, nebula.radius * 0.5);

      canvas.drawCircle(
        Offset(
          nebula.x * size.width + offsetX,
          nebula.y * size.height + offsetY,
        ),
        nebula.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => true;
}

class _ShootingStarPainter extends CustomPainter {
  final double animation;

  _ShootingStarPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent shooting stars
    for (int i = 0; i < 3; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height * 0.5;
      final length = random.nextDouble() * 80 + 40;
      final angle = pi / 4 + random.nextDouble() * 0.3;

      final progress = (animation * 3 + i * 0.33) % 1.0;
      if (progress > 0.7) continue;

      final currentX = startX + cos(angle) * length * progress;
      final currentY = startY + sin(angle) * length * progress;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(1 - progress),
            DripTheme.cosmicTeal.withOpacity(0.5 * (1 - progress)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(
          Offset(currentX, currentY),
          Offset(currentX - cos(angle) * 30, currentY - sin(angle) * 30),
        ))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX - cos(angle) * 30, currentY - sin(angle) * 30),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => true;
}
